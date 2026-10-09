# Montaj

Montaj is a desktop video editor your AI drives. With this plugin, Claude can create projects, cut takes, add captions and overlays, and render videos in the Montaj app on your computer.

## Requirements

The Montaj app for macOS or Windows, from [montaj.ag](https://montaj.ag). Install it and open it once. The editor is free.

## What the plugin runs

The plugin contains one skill and one local MCP server entry. The server command, `scripts/montaj-mcp` (or `montaj-mcp.cmd` on Windows), starts the launcher the Montaj app writes when it opens: `~/Library/Application Support/Montaj/mcp-launch.sh` on macOS, `%APPDATA%\Montaj\mcp-launch.cmd` on Windows. If the app isn't installed, it prints a message and exits. The plugin itself downloads nothing and stores nothing.

## Data

Editing and rendering run on your computer. The Montaj app talks to `api.montaj.ag` for sign-in and paid features. With "Share usage data" on in Montaj's Settings, the app records each instruction your AI sends and its result, with file paths reduced to file names and secret-shaped values removed. Steps that use your own provider keys send their inputs to that provider. Details: [montaj.ag/privacy](https://montaj.ag/privacy).
