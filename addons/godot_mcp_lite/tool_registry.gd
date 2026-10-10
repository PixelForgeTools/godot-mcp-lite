@tool
extends RefCounted
class_name McpToolRegistry
## Registry of exactly 10 minimal tools. Short names + tiny schemas so 8B local models do not choke.
## GDScript, Godot 4.3+.

var _plugin: EditorPlugin

func _init(plugin: EditorPlugin) -> void:
	_plugin = plugin

func list_tools() -> Array:
	return [
		{"name":"get_project_info","description":"Get project name, Godot version and main scene","inputSchema":{"type":"object","properties":{}}},
		{"name":"get_scene_tree","description":"List nodes in current scene","inputSchema":{"type":"object","properties":{}}},
		{"name":"create_scene","description":"Create a new scene file","inputSchema":{"type":"object","properties":{"path":{"type":"string"},"root_type":{"type":"string"}},"required":["path"]}},
		{"name":"open_scene","description":"Open a scene file in editor","inputSchema":{"type":"object","properties":{"path":{"type":"string"}},"required":["path"]}},
		{"name":"save_scene","description":"Save current scene","inputSchema":{"type":"object","properties":{}}},
		{"name":"add_node","description":"Add a node to current scene","inputSchema":{"type":"object","properties":{"type":{"type":"string"},"name":{"type":"string"},"parent_path":{"type":"string"}},"required":["type","name"]}},
		{"name":"set_node_property","description":"Set a property on a node","inputSchema":{"type":"object","properties":{"node_path":{"type":"string"},"property":{"type":"string"},"value":{}},"required":["node_path","property","value"]}},
		{"name":"get_editor_errors","description":"Get recent editor errors captured by plugin","inputSchema":{"type":"object","properties":{}}},
		{"name":"run_scene","description":"Play current/main scene","inputSchema":{"type":"object","properties":{"mode":{"type":"string"}}}},
		{"name":"stop_scene","description":"Stop playing scene","inputSchema":{"type":"object","properties":{}}},
	]

func call_tool(tool_name: String, args: Dictionary) -> Dictionary:
	match tool_name:
		"get_project_info": return _get_project_info()
		"get_scene_tree": return _get_scene_tree()
		"create_scene": return _create_scene(args)
		"open_scene": return _open_scene(args)
		"save_scene": return _save_scene()
		"add_node": return _add_node(args)
		"set_node_property": return _set_node_property(args)
		"get_editor_errors": return _get_editor_errors()
		"run_scene": return _run_scene(args)
		"stop_scene": return _stop_scene()
	return {"error":"unknown tool: "+tool_name}

func _ok(data: Variant) -> Dictionary:
	return {"content":[{"type":"text","text":JSON.stringify(data)}]}

func _get_project_info() -> Dictionary:
	var info := {
		"name": ProjectSettings.get_setting("application/config/name",""),
		"godot_version": Engine.get_version_info().get("string",""),
		"main_scene": ProjectSettings.get_setting("application/run/main_scene",""),
	}
	return _ok(info)

func _get_scene_tree() -> Dictionary:
	var root: Node = _plugin.get_editor_interface().get_edited_scene_root()
	if root == null:
		return {"error":"no scene open"}
	var nodes: Array = []
	_collect(root, root, nodes)
	return _ok(nodes)

func _collect(root: Node, n: Node, out: Array) -> void:
	out.append({"path": str(root.get_path_to(n)), "type": n.get_class(), "name": n.name})
	for c in n.get_children():
		_collect(root, c, out)

func _create_scene(args: Dictionary) -> Dictionary:
	var path: String = args.get("path","")
	var root_type: String = args.get("root_type","Node2D")
	if path == "":
		return {"error":"path required"}
	if not ClassDB.class_exists(root_type):
		return {"error":"unknown type: "+root_type}
	var root: Object = ClassDB.instantiate(root_type)
	if not (root is Node):
		return {"error":"root_type is not a Node"}
	var scene := PackedScene.new()
	var err := scene.pack(root)
	if err != OK:
		return {"error":"pack failed: "+str(err)}
	err = ResourceSaver.save(scene, path)
	(root as Node).free()
	if err != OK:
		return {"error":"save failed: "+str(err)}
	return _ok({"created":path,"root_type":root_type})

func _open_scene(args: Dictionary) -> Dictionary:
	var path: String = args.get("path","")
	if path == "":
		return {"error":"path required"}
	_plugin.get_editor_interface().open_scene_from_path(path)
	return _ok({"opened":path})

func _save_scene() -> Dictionary:
	_plugin.get_editor_interface().save_scene()
	return _ok({"saved":true})

func _add_node(args: Dictionary) -> Dictionary:
	var root: Node = _plugin.get_editor_interface().get_edited_scene_root()
	if root == null:
		return {"error":"no scene open"}
	var type_name: String = args.get("type","")
	var node_name: String = args.get("name","Node")
	var parent_path: String = args.get("parent_path",".")
	if not ClassDB.class_exists(type_name):
		return {"error":"unknown type: "+type_name}
	var parent: Node = root if parent_path in [".",""] else root.get_node_or_null(parent_path)
	if parent == null:
		return {"error":"parent not found: "+parent_path}
	var obj: Object = ClassDB.instantiate(type_name)
	if not (obj is Node):
		return {"error":"type is not a Node"}
	var node: Node = obj as Node
	node.name = node_name
	var ur: EditorUndoRedoManager = _plugin.get_undo_redo()
	ur.create_action("MCP Add Node")
	ur.add_do_method(parent, "add_child", node)
	ur.add_do_method(node, "set_owner", root)
	ur.add_undo_method(parent, "remove_child", node)
	ur.commit_action()
	return _ok({"added":str(root.get_path_to(node)),"type":type_name})

func _set_node_property(args: Dictionary) -> Dictionary:
	var root: Node = _plugin.get_editor_interface().get_edited_scene_root()
	if root == null:
		return {"error":"no scene open"}
	var node_path: String = args.get("node_path",".")
	var prop: String = args.get("property","")
	var value: Variant = args.get("value", null)
	var node: Node = root if node_path in [".",""] else root.get_node_or_null(node_path)
	if node == null:
		return {"error":"node not found: "+node_path}
	# Coerce common string-encoded vectors, e.g. "Vector2(10,20)" is NOT parsed (unsafe); accept arrays for Vector2/3.
	if typeof(value) == TYPE_ARRAY:
		var a: Array = value
		if a.size() == 2:
			value = Vector2(float(a[0]), float(a[1]))
		elif a.size() == 3:
			value = Vector3(float(a[0]), float(a[1]), float(a[2]))
	var ur: EditorUndoRedoManager = _plugin.get_undo_redo()
	ur.create_action("MCP Set Property")
	ur.add_do_property(node, prop, value)
	ur.add_undo_property(node, prop, node.get(prop))
	ur.commit_action()
	return _ok({"set":prop,"node":node_path})

func _get_editor_errors() -> Dictionary:
	# TODO: Godot 4 has no public EditorPlugin API to read the Debugger/Errors dock.
	# We return errors captured by this plugin (connection/tool errors) stored on plugin meta.
	var errs: Array = _plugin.get_meta("mcp_errors", [])
	return _ok({"errors":errs,"note":"Full debugger dock errors require Godot API not exposed to plugins; showing plugin-captured errors."})

func _run_scene(args: Dictionary) -> Dictionary:
	var mode: String = args.get("mode","current")
	var ei := _plugin.get_editor_interface()
	if mode == "main":
		ei.play_main_scene()
	else:
		ei.play_current_scene()
	return _ok({"playing":mode})

func _stop_scene() -> Dictionary:
	_plugin.get_editor_interface().stop_playing_scene()
	return _ok({"stopped":true})
