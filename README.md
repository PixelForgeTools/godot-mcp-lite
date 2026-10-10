# Godot MCP Lite (Free)

Let an AI assistant work inside your Godot 4 editor — in 5 minutes, with no extra programs to install.

Copy one folder, click Enable, talk to your AI: "add a player node", "open the level scene", "run the game".

**Free Lite = 10 tools.** Small on purpose: small local models (Ollama / LM Studio, 8B) can actually use all 10 without getting confused. Big tools with 160+ commands choke small models — that's the #1 complaint we heard from buyers of other MCP tools.

Works with: Claude Code, Cursor, and local models via Ollama / LM Studio (using the included bridge).

## What's inside
- `addons/godot_mcp_lite/` — the plugin (Godot 4.3–4.7)
- `presets/` — ready-made configs for Claude Code, Cursor, Ollama, LM Studio
- `bridge/bridge.py` — tiny bridge for tools that need a command instead of a web address (uses only Python 3 standard library)
- `demo_project/` — a small project to try it immediately

## The 10 tools
get_project_info, get_scene_tree, create_scene, open_scene, save_scene, add_node, set_node_property, get_editor_errors, run_scene, stop_scene

## Free vs Paid
Free Lite (this): 10 tools, scene basics, local-model presets.
Full ($15, $12 at launch): 25–30 tools, screenshot + playtest (AI sees and plays your game), check-code-before-saving, more node/property helpers, priority updates.

## Setup
See SETUP.md — plain English, 4 steps.

License: see LICENSE — pay once for Full, use in commercial games, don't resell the tool itself.

Support: use the itch.io comments. We answer setup questions there.
