---
sidebar_position: 2
---

# Examples
## Client → Server
```lua
-- Context: Client
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Postie = require(ReplicatedStorage.Packages.Postie)

local isOk, newPart = Postie.invokeServer("createPart", 5, Color3.fromRGB(255, 0, 0), Vector3.new(0, 25, -20))

if isOk then
	print("The server created the requested part:", newPart)
else
	print("The server wasn't able to create the part...")
end
```
```lua
-- Context: Server
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Postie = require(ReplicatedStorage.Packages.Postie)

local function onCreatePart(player, partColor, partPosition)
	local newPart = Instance.new("Part")
	newPart.Color = partColor
	newPart.Position = partPosition
	newPart.Parent = workspace
	return newPart
end

Postie.setCallback("createPart", onCreatePart)
```