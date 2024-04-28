--!strict

--[[
	Postie must be required atleast once from the server-side for RemoteEvents
	to be properly initialized.
]]

--<< Services >>--

local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

--<< Types >>--

type Dictionary<I, V> = { [I]: V }
type Callback = (...any) -> ...any
type Listener = (Player?, boolean, ...any) -> ()

--<< Variables >>--

local callbackById = {}
local listenerByUuid = {}

local isRunning = RunService:IsRunning()
local isServer = RunService:IsServer()
local isClient = RunService:IsClient()

local sent -- RemoteEvent created at runtime
local received -- RemoteEvent created at runtime

--<< Module >>--

--[=[
	@class Postie

	Postie is a safe alternative to RemoteFunctions with a time-out.
]=]
local Postie = {}

--[=[
	Invoke client with sent data. If the invocation reaches the client, but the
	client doesn't have a corresponding callback, return before timeOut
	regardless but return false.

	@param player Player -- The client player to invoke.
	@param id string -- The identification for the invocation.
	@param timeOut number -- Yield until timeOut (given in seconds) is reached.
	@param ... any -- Additional data to send to the client.

	@yields
	@server

	@return boolean -- Returns true if the server received a response, false otherwise.
	@return ... -- Additional data returned from the the client.
]=]
function Postie.invokeClient(player: Player, id: string, timeOut: number, ...: any): (boolean, ...any)
	assert(isServer, "Postie.invokeClient can only be called from the server")

	local thread = coroutine.running()
	local isResumed = false
	local uuid = HttpService:GenerateGUID(false)

	local function listener(playerWhoFired: Player?, didInvokeCallback: boolean, ...: any): ()
		if playerWhoFired ~= player then
			-- The client lied about the UUID.
			return
		end
		isResumed = true
		listenerByUuid[uuid] = nil
		if didInvokeCallback then
			task.spawn(thread, true, ...)
		else
			task.spawn(thread, false)
		end
	end

	-- We await a signal from the client.
	listenerByUuid[uuid] = listener

	-- We await the time-out.
	task.delay(timeOut, function(): ()
		if isResumed then return end
		listenerByUuid[uuid] = nil
		task.spawn(thread, false)
	end)

	-- Finally, we send the signal to the client and await either the client's
	-- response or the time-out.
	sent:FireClient(player, id, uuid, ...)
	return coroutine.yield()
end

--[=[
	Invoke the server with sent data. If the invocation reaches the server, but
	the server doesn't have a corresponding callback, return before timeOut
	regardless but return false.

	@param id string -- The identification for the invocation.
	@param timeOut number -- Yield until timeOut (given in seconds) is reached.
	@param ... any -- Additional data to send to the server.

	@yields
	@client

	@return boolean -- Returns true if the client received a response, false otherwise.
	@return ... -- Additional data returned from the server.
]=]
function Postie.invokeServer(id: string, timeOut: number, ...: any): (boolean, ...any)
	assert(isClient, "Postie.invokeServer can only be called from the client")

	local thread = coroutine.running()
	local isResumed = false
	local uuid = HttpService:GenerateGUID(false)

	-- Player will always be `nil` on the client listeners.
	local function listener(_: Player?, didInvokeCallback: boolean, ...: any): ()
		isResumed = true
		listenerByUuid[uuid] = nil
		if didInvokeCallback then
			task.spawn(thread, true, ...)
		else
			task.spawn(thread, false)
		end
	end

	-- We await a signal from the client.
	listenerByUuid[uuid] = listener

	-- We await the time-out.
	task.delay(timeOut, function(): ()
		if isResumed then return end
		listenerByUuid[uuid] = nil
		task.spawn(thread, false)
	end)

	-- Finally, we send the signal to the client and await either the client's
	-- response or the time-out.
	sent:FireServer(id, uuid, ...)
	return coroutine.yield()
end

--[=[
	Set the callback that is invoked when an invocation identified by id is
	sent. Data sent with the invocation are passed to the callback. If on
	the server, the player who invoked is implicitly received as the first
	argument.

	@param id string -- The identification for the invocation.

	@param callback Callback? -- The callback function to set.
]=]
function Postie.setCallback(id: string, callback: Callback?): ()
	callbackById[id] = callback
end

--[=[
	Return the callback corresponding with id.

	@param id string -- The identification for the callback.
	
	@return callback -- The corresponding callback function, if it exists.
]=]
function Postie.getCallback(id: string): Callback?
	return callbackById[id]
end

if isRunning then
	if isServer then
		-- Handle responses received from the client.
		local function onRecieveEvent(player: Player, uuid: string, didInvokeCallback: boolean, ...: any): ()
			local listener = listenerByUuid[uuid]
			if not listener then return end
			listener(player, didInvokeCallback, ...)
		end

		received = Instance.new("RemoteEvent")
		received.Name = "Received"
		received.OnServerEvent:Connect(onRecieveEvent)
		received.Parent = script

		-- Handle requests sent by the client.
		local function onSentEvent(player: Player, id: string, uuid: string, ...: any): ()
			local callback = callbackById[id]
			if callback then
				received:FireClient(player, uuid, true, callback(player, ...))
			else
				received:FireClient(player, uuid, false)
			end
		end

		sent = Instance.new("RemoteEvent")
		sent.Name = "Sent"
		sent.OnServerEvent:Connect(onSentEvent)
		sent.Parent = script
	elseif isClient then
		-- Handle responses received from the server.
		local function onRecieveEvent(uuid: string, didInvokeCallback: boolean, ...: any): ()
			local listener = listenerByUuid[uuid]
			if not listener then return end
			listener(nil, didInvokeCallback, ...)
		end

		-- Handle requests sent by the server.
		local function onSentEvent(id: string, uuid: string, ...: any): ()
			local callback = callbackById[id]
			if callback then
				received:FireServer(uuid, true, callback(...))
			else
				received:FireServer(uuid, false)
			end
		end

		received = script:WaitForChild("Received") :: RemoteEvent
		sent = script:WaitForChild("Sent") :: RemoteEvent

		received.OnClientEvent:Connect(onRecieveEvent)
		sent.OnClientEvent:Connect(onSentEvent)
	end
end

return Postie
