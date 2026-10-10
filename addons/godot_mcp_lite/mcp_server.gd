@tool
extends RefCounted
class_name McpServer
## Minimal MCP over TCP: newline-delimited JSON-RPC 2.0 on 127.0.0.1:6506.
## Supports initialize, tools/list, tools/call, ping. No external deps.

const PORT := 6506
var _tcp := TCPServer.new()
var _peers: Array[StreamPeerTCP] = []
var _buffers: Dictionary = {} # peer -> String
var _registry: McpToolRegistry
var _plugin: EditorPlugin

func _init(plugin: EditorPlugin, registry: McpToolRegistry) -> void:
	_plugin = plugin
	_registry = registry

func start() -> Error:
	var err := _tcp.listen(PORT, "127.0.0.1")
	if err != OK:
		push_warning("Godot MCP Lite: could not listen on %d (%s)" % [PORT, err])
	return err

func stop() -> void:
	for p in _peers:
		p.disconnect_from_host()
	_peers.clear()
	_tcp.stop()

func poll() -> void:
	while _tcp.is_connection_available():
		var peer := _tcp.take_connection()
		if peer:
			_peers.append(peer)
			_buffers[peer] = ""
	for peer in _peers.duplicate():
		peer.poll()
		if peer.get_status() != StreamPeerTCP.STATUS_CONNECTED:
			_peers.erase(peer); _buffers.erase(peer); continue
		var avail: int = peer.get_available_bytes()
		if avail > 0:
			var bytes := peer.get_data(avail)[1] as PackedByteArray
			var text := bytes.get_string_from_utf8()
			_buffers[peer] = str(_buffers[peer]) + text
			var buf: String = _buffers[peer]
			while buf.contains("\n"):
				var idx := buf.find("\n")
				var line := buf.substr(0, idx).strip_edges()
				buf = buf.substr(idx+1)
				if line != "":
					_handle_line(peer, line)
			_buffers[peer] = buf

func _send(peer: StreamPeerTCP, obj: Dictionary) -> void:
	peer.put_data(JSON.stringify(obj).to_utf8_buffer() + "\n".to_utf8_buffer())

func _handle_line(peer: StreamPeerTCP, line: String) -> void:
	var parsed: Variant = JSON.parse_string(line)
	if typeof(parsed) != TYPE_DICTIONARY:
		_send(peer, {"jsonrpc":"2.0","id":null,"error":{"code":-32700,"message":"parse error"}})
		return
	var req: Dictionary = parsed
	var method: String = req.get("method","")
	var id: Variant = req.get("id", null)
	var params: Dictionary = req.get("params", {}) if typeof(req.get("params"))==TYPE_DICTIONARY else {}
	var result: Variant = null
	var err_obj: Variant = null
	match method:
		"initialize":
			result = {"protocolVersion":"2024-11-05","capabilities":{"tools":{}},"serverInfo":{"name":"godot-mcp-lite","version":"0.1.0"}}
		"ping":
			result = {}
		"tools/list":
			result = {"tools":_registry.list_tools()}
		"tools/call":
			var tname: String = params.get("name","")
			var targs: Dictionary = params.get("arguments",{}) if typeof(params.get("arguments"))==TYPE_DICTIONARY else {}
			result = _registry.call_tool(tname, targs)
		"notifications/initialized":
			return
		_:
			err_obj = {"code":-32601,"message":"method not found: "+method}
	if err_obj != null:
		_send(peer, {"jsonrpc":"2.0","id":id,"error":err_obj})
	else:
		_send(peer, {"jsonrpc":"2.0","id":id,"result":result})
