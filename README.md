# aoc2022

To run the solutions use Neovim.

Normal usage:
```sh
nvim
# then inside nvim
:source minimal_init.lua
# and to run given task
:edit 01.lua
:AocRun
```

Minimal version interactive:
```sh
nvim --noplugin -u minimal_init.lua
# then inside nvim
:edit 01.lua
:AocRun
```

Minimal version, run given task:
```sh
nvim --noplugin -u minimal_init.lua -c 'luafile 01.lua'
```
