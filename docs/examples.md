---
sidebar_position: 3
---

# Examples
## Client → Server
```lua title="client.luau"
-- Context: Client
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Postie = require(ReplicatedStorage.Packages.Postie)

local timeout = 5
local withColor = Color3.fromRGB(255, 0, 0)
local atPosition = Vector3.new(0, 25, -20)

local isOk, newPart = Postie.invokeServer("createPart", timeout, withColor, atPosition)

if isOk then
	print("The server created the requested part:", newPart)
else
	print("The server wasn't able to create the part...")
end
```
```lua title="server.luau"
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