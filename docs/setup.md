---
sidebar_position: 2
---

# Installation

1. Install [Wally](https://wally.run) by following [these instructions](https://wally.run/install).
2. Copy the latest version of Postie from the [package page](https://wally.run/package/superbithious/postie), and paste it as a dependency into `wally.toml`.
```toml title="wally.toml"
# This is a truncated wally.toml file!
# Learn more about the wally manifest format: 
# https://github.com/UpliftGames/wally?tab=readme-ov-file#manifest-format

[dependencies]
# highlight-next-line
postie = "superbithious/postie@X.X.X"
#                              ^ ^ ^
# Remember to get the latest package version from the wally website.
# https://wally.run/package/superbithious/postie
```
3. Run `wally install` to fetch the packages.
4. Sync the `Packages` folder using [Rojo](https://rojo.space/).

# Setup

For Postie to work, you need to require it atleast ONCE on the server side.

```lua
-- A Script in ServerScriptService 
local ReplicatedStorage = game:GetService("ReplicatedStorage")
# highlight-next-line
local Postie = require(path.to.Postie)
```