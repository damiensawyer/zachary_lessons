#!/bin/bash
# Helper script to run Lua code with correct paths

# Set up luarocks paths
eval $(luarocks path --local)

# Add src to Lua module path
export LUA_PATH="src/?.lua;$LUA_PATH"

# Run command
"$@"
