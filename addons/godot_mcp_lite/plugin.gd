@tool
extends EditorPlugin
## Godot MCP Lite — Free Lite (10 tools). Copy folder, enable plugin, works.
## Architecture: this plugin hosts a TCP JSON-RPC (MCP) endpoint on 127.0.0.1:6506.
## The bridge (bridge/bridge.py) exposes it as stdio for Ollama/LM Studio tooling that needs stdio.

const McpServerScript := preload("res://addons/godot_mcp_lite/mcp_server.gd")
const McpToolRegistryScript := preload("res://addons/godot_mcp_lite/tool_registry.gd")
const McpConfigWriterScript := preload("res://addons/godot_mcp_lite/config_writer.gd")

var _server: McpServer
var _registry: McpToolRegistry

func _enter_tree() -> void:
	set_meta("mcp_errors", [])
	_registry = McpToolRegistryScript.new(self)
	_server = McpServerScript.new(self, _registry)
	var err: Error = _server.start()
	if err == OK:
		print("Godot MCP Lite: listening on 127.0.0.1:6506")
	else:
		var errs: Array = get_meta("mcp_errors", [])
		errs.append("listen failed: "+str(err)); set_meta("mcp_errors", errs)
	var res: Dictionary = McpConfigWriterScript.write_all()
	print("Godot MCP Lite: wrote config ", res.get("written", []))
	add_tool_menu_item("MCP Lite: Copy Claude Config", _copy_claude_config)

func _exit_tree() -> void:
	remove_tool_menu_item("MCP Lite: Copy Claude Config")
	if _server:
		_server.stop()

func _process(_delta: float) -> void:
	if _server:
		_server.poll()

func _copy_claude_config() -> void:
	DisplayServer.clipboard_set(McpConfigWriterScript.claude_snippet())
	print("Godot MCP Lite: Claude config copied to clipboard")
