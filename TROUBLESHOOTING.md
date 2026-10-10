# Troubleshooting

**Nothing happens / AI can't connect**
- Is Godot open with your project, and the plugin Enabled? The Output panel must say `listening on 127.0.0.1:6506`.
- Is another program using port 6506? Close other MCP servers for Godot (Godot MCP Pro, Beckett, etc. use nearby ports — don't run two at once).
- Restart Godot after enabling the plugin the first time.

**"no scene open"**
Open a scene first (double-click a `.tscn` file), then ask again. add_node / set_node_property need an open scene.

**"unknown type" when adding a node**
Use exact Godot class names: `Node2D`, `Sprite2D`, `ColorRect`, `Label`, `CharacterBody2D` (capitalisation matters).

**Local model (Ollama/LM Studio) is confused or loops**
- Make sure you're on the 10-tool Lite profile (presets in `presets/`), not a 100+ tool profile from another tool.
- Use short, one-step instructions: "add a Label" not "build a whole menu system".
- 8B models handle single steps; for chained steps ("add X, then set Y, then run") a 14B+ model works better.

**Bridge error: cannot connect**
Godot isn't running or the plugin isn't enabled. Open Godot first, then start your AI tool.

**Godot 4.2 or older**
Lite needs Godot 4.3+. The editor APIs we use were added in 4.3. Upgrade your project or use Godot 4.4/4.5 (free).

**Still stuck?**
Post in the itch.io comments with: Godot version, your AI tool name, and the exact error from Godot's Output panel. We reply there.
