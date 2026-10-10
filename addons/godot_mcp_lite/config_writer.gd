@tool
extends RefCounted
class_name McpConfigWriter
## Writes .mcp.json in project root + preset files. Plain-English: no manual JSON editing for buyer.

const SERVER_URL := "http://127.0.0.1:6506"

static func write_all() -> Dictionary:
	var written: Array[String] = []
	var base := ProjectSettings.globalize_path("res://")
	# Claude Code / generic MCP clients that read .mcp.json
	var cfg := {"mcpServers":{"godot":{"url":SERVER_URL,"type":"http"}}}
	var f := FileAccess.open("res://.mcp.json", FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(cfg, "\t")); f.close(); written.append(base+".mcp.json")
	# Keep a copy of presets folder note
	return {"written":written,"server_url":SERVER_URL}

static func claude_snippet() -> String:
	return JSON.stringify({"mcpServers":{"godot":{"url":SERVER_URL,"type":"http"}}}, "\t")

static func cursor_snippet() -> String:
	return claude_snippet()
