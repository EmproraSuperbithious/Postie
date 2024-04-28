
# Postie

Postie is a simple Roblox Luau library for client-server communication, providing a safe alternative to [RemoteFunction](https://create.roblox.com/docs/reference/engine/classes/RemoteFunction) with a timeout.

Typed with Luau annotations, Postie is written to prevent mistakes from misuse of the API. For more information, view the [documentation](https://superbithious.github.io/Postie).

## Usage
### Client → Server
```lua
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
```lua
-- Context: Server
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Postie = require(ReplicatedStorage.Packages.Postie)

local function onCreatePart(player: Player, partColor: Color3, partPosition: Vector3)
	local newPart = Instance.new("Part")
	newPart.Color = partColor
	newPart.Position = partPosition
	newPart.Parent = workspace
	return newPart
end

Postie.setCallback("createPart", onCreatePart)
```



## License

Postie is released under the terms of the [MIT License](https://opensource.org/licenses/MIT). View the [LICENSE](LICENSE) file for specific details.