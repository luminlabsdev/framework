-- Variables

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Reliable: RemoteEvent = ReplicatedStorage:WaitForChild("FrameworkReliable")
local Unreliable: UnreliableRemoteEvent = ReplicatedStorage:WaitForChild("FrameworkUnreliable")

local RemotePacketSizeCounter = require(script.Parent.Parent.Parent.remotepacketsizecounter)

local Listeners: { [string]: (Player, { any }) -> () } = {}
local Outgoing: {
	[Player]: {
		Unreliable: { [string]: { { any } } },
		Reliable: { [string]: { { any } } },
		Call: { [string]: { any } },
	},
} =
	{}

-- Functions

local function CreateOutgoingForPlayer(player: Player)
	Outgoing[player] = {
		Unreliable = {},
		Reliable = {},
		Call = {},
	}
end

local function SendReliable(player: Player, id: string, args: { any })
	local OutgoingForPlayer = Outgoing[player]

	if not OutgoingForPlayer then
		CreateOutgoingForPlayer(player)
	end

	OutgoingForPlayer = Outgoing[player]

	if not OutgoingForPlayer.Reliable[id] then
		OutgoingForPlayer.Reliable[id] = {}
	end

	table.insert(OutgoingForPlayer.Reliable[id], args)
end

local function SendReliableNow(player: Player, id: string, args: { any })
	Reliable:FireClient(player, { [id] = { args } })
end

local function SendUnreliable(player: Player, id: string, args: { any })
	local PacketSize = RemotePacketSizeCounter.GetPacketSize({
		RunContext = "Server",
		RemoteType = "RemoteEvent",
		PacketData = args,
	})

	if PacketSize >= 840 then
		Unreliable:FireClient(player, { [id] = { args } })
	else
		local OutgoingForPlayer = Outgoing[player]

		if not OutgoingForPlayer then
			CreateOutgoingForPlayer(player)
		end

		if not OutgoingForPlayer.Unreliable[id] then
			OutgoingForPlayer.Unreliable[id] = {}
		end

		table.insert(OutgoingForPlayer.Unreliable[id], args)
	end
end

local function SendUnreliableNow(player: Player, id: string, args: { any })
	Unreliable:FireClient(player, { [id] = { args } })
end

local function SendReliableCallReturn(player: Player, id: string, args: { any })
	local OutgoingForPlayer = Outgoing[player]

	if not OutgoingForPlayer then
		CreateOutgoingForPlayer(player)
	end

	OutgoingForPlayer = Outgoing[player]
	OutgoingForPlayer.Call[id] = args
end

local function Listen(id: string, callback: (Player, { any }) -> ())
	Listeners[id] = callback
end

local function Init()
	Reliable.OnServerEvent:Connect(function(player, incomingFires, incomingCalls)
		-- reliable remote events
		for id, callList in incomingFires do
			if type(id) ~= "string" then
				continue
			end
			local Callback = Listeners[id]
			if Callback then
				for _, call in callList do
					Callback(player, call)
				end
			end
		end
		-- remote functions
		for id, callList in incomingCalls do
			local Callback = Listeners[id]
			if Callback then
				for _, call in callList do
					Callback(player, call)
				end
			else
				for _, call in callList do
					SendReliableCallReturn(player, call[1], { false, "Event has no listener" })
				end
			end
		end
	end)

	Unreliable.OnServerEvent:Connect(function(player, incomingFires)
		-- unreliable remote events
		for id, callList in incomingFires do
			if type(id) ~= "string" then
				continue
			end
			local Callback = Listeners[id]
			if Callback then
				for _, call in callList do
					Callback(player, call)
				end
			end
		end
	end)

	RunService.Heartbeat:Connect(function()
		for player, outgoingItems in Outgoing do
			if next(outgoingItems.Reliable) or next(outgoingItems.Call) then
				Reliable:FireClient(player, outgoingItems.Reliable, outgoingItems.Call)
			end

			if next(outgoingItems.Unreliable) then
				Unreliable:FireClient(player, outgoingItems.Unreliable)
			end

			Outgoing[player] = nil
		end
	end)
end

return {
	Init = Init,
	Listen = Listen,

	SendReliable = SendReliable,
	SendReliableNow = SendReliableNow,

	SendUnreliable = SendUnreliable,
	SendUnreliableNow = SendUnreliableNow,

	SendReliableCallReturn = SendReliableCallReturn,
}
