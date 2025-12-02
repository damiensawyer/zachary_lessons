#!/bin/bash
luarocks install --local busted
luarocks install --local lsqlite3
luarocks install --local luacov

## Source environment per session.
source <(echo 'eval $(luarocks path --local); export LUA_PATH="./src/?.lua;$LUA_PATH"')
