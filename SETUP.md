# Setup — plain English (5 minutes)

You need: Godot 4.3 or newer, and an AI assistant (Claude Code, Cursor, Ollama, or LM Studio).

## Step 1 — Put the plugin in your game
1. Download and unzip Godot MCP Lite.
2. Copy the folder `addons/godot_mcp_lite` into your Godot project's `addons/` folder.
   Your project should now have: `addons/godot_mcp_lite/plugin.cfg`
3. If you want to just try it first, open the included `demo_project` instead — it already has the plugin.

## Step 2 — Turn it on in Godot
1. Open your project in Godot.
2. Top menu: **Project → Project Settings → Plugins**
3. Find **Godot MCP Lite** and tick **Enable**.
4. You should see in the bottom Output panel: `Godot MCP Lite: listening on 127.0.0.1:6506`
   That means it's working and waiting for your AI.

The plugin automatically creates a file called `.mcp.json` in your project. Most tools can use it directly.

## Step 3 — Connect your AI

**Claude Code:** In your project folder, run Claude Code as normal. It reads `.mcp.json` automatically. If not, copy the contents of `presets/claude-code.json` into your Claude config.

**Cursor:** Open Cursor settings → MCP → Add server, and paste the contents of `presets/cursor.json`. Or copy `.mcp.json` to your project root — Cursor reads it.

**Ollama / LM Studio (local models, no cloud):**
- Use `presets/lmstudio.json` in LM Studio's MCP settings. It starts `bridge/bridge.py` for you.
- You need Python 3 (most computers already have it). No pip installs — the bridge uses only built-in parts.
- Recommended small model: an 8B model is fine because there are only 10 tools. Bigger (14B+) follows multi-step instructions better.

Tip in Godot: **Project → Tools → MCP Lite: Copy Claude Config** copies the config to your clipboard.

## Step 4 — Try it
With Godot open and your AI connected, say:
- "What project is open and what's the main scene?" (get_project_info)
- "Show me the scene tree" (get_scene_tree)
- "Add a ColorRect called Background" (add_node)
- "Run the scene" (run_scene)

If it works, you're done. If not, see TROUBLESHOOTING.md.
