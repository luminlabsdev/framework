local CanaryScript = { }

--[=[
	CanaryEngine's server-sided interface.
	
	@server
	@class CanaryEngineServer
]=]
local CanaryEngineServer = { }

--[=[
	A reference to the Media folder on the Server, also gives access to replicated media.

	@prop Media {Server: Folder, Replicated: Folder}
	@readonly

	@within CanaryEngineServer
]=]

--[=[
	A reference to the Packages folder on the Server, also gives access to replicated Packages.

	@prop Packages {Server: Folder, Replicated: Folder}
	@readonly

	@within CanaryEngineServer
]=]

--[=[
	CanaryEngine's client-sided interface.
	
	@client
	@class CanaryEngineClient
]=]
local CanaryEngineClient = { }

--[=[
	A simple reference to the [Players.LocalPlayer].

	@prop Player Player
	@readonly

	@within CanaryEngineClient
]=]

--[=[
	A simple reference to the [Player.PlayerGui], useful for automatic typing and API simplicity.

	@prop PlayerGui StarterGui
	@readonly

	@within CanaryEngineClient
]=]

--[=[
	A simple reference to the player's [Backpack], useful for automatic typing and API simplicity.

	@prop PlayerBackpack StarterPack
	@readonly

	@within CanaryEngineClient
]=]

--[=[
	Local objects of the player.

	@prop LocalObjects dictionary
	@readonly
	@deprecated v2 -- Use PlayerBackpack and PlayerGui instead.

	@within CanaryEngineClient
]=]

--[=[
	A reference to the Media folder on the client, also gives access to replicated media.

	@prop Media {Client: Folder, Replicated: Folder}
	@readonly

	@within CanaryEngineClient
]=]

--[=[
	A reference to the Packages folder on the client, also gives access to replicated Packages.

	@prop Packages {Client: Folder, Replicated: Folder}
	@readonly

	@within CanaryEngineClient
]=]

-- // Types

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local PlayerService = game:GetService("Players")
local CanaryEngine = require(script.Parent)

local Debugger = require(script.Parent.Vendor.Debugger)
local RuntimeContext = require(script.Parent.Vendor.Runtime).Context

local Network = script.Parent.Vendor.Network
local Data = script.Parent.Vendor.Data

-- // Functions

--[=[
	Gets the server-sided interface of CanaryEngine
	
	@server
	@return EngineServer?
]=]
function CanaryScript.GetEngineServer()
	if RuntimeContext.Server then
		local EngineServer = ServerStorage:WaitForChild("EngineServer")
		local EngineReplicated = ReplicatedStorage:WaitForChild("EngineReplicated")

		CanaryEngineServer.Packages = {
			Server = require(EngineServer[".intellisense"]),
			Replicated = require(EngineReplicated[".intellisense"]),
		}

		CanaryEngineServer.Matchmaking = require(Network.MatchmakingService)
		CanaryEngineServer.Moderation = nil
		CanaryEngineServer.Data = require(Data.EasyProfile)

		CanaryEngineServer.Media = {
			Server = EngineServer.Media,
			Replicated = EngineReplicated.Media,
		}

		return CanaryEngineServer
	else
		Debugger.error("Failed to fetch 'EngineServer', context must be server")
		return nil
	end
end

--[=[
	Gets the client-sided interface of CanaryEngine
	
	@yields
	@client
	@return EngineClient?
]=]
function CanaryScript.GetEngineClient()
	if RuntimeContext.Client then
		local EngineClient = ReplicatedStorage:WaitForChild("EngineClient")
		local EngineReplicated = ReplicatedStorage:WaitForChild("EngineReplicated")

		local Player = PlayerService.LocalPlayer

		CanaryEngineClient.Packages = {
			Client = require(EngineClient[".intellisense"]),
			Replicated = require(EngineReplicated[".intellisense"]),
		}

		CanaryEngineClient.Media = {
			Client = EngineClient.Media,
			Replicated = EngineReplicated.Media,
		}

		CanaryEngineClient.Player = Player

		CanaryEngineClient.PlayerGui = Player:WaitForChild("PlayerGui") :: StarterGui
		CanaryEngineClient.PlayerBackpack = Player:WaitForChild("Backpack") :: StarterPack

		return CanaryEngineClient
	else
		Debugger.error("Failed to fetch 'EngineClient', Context must be client.")
		return nil
	end
end

--[=[
	Creates a new network controller on the client, with the name of `controllerName`

	:::tip

	You can set the data type of a network controller after it being made like the following:

	```lua
	local NetworkController: CanaryEngine.ServerNetworkController<number, number> = EngineClient.CreateNetworkController("MyNewNetworkController") -- assuming you are sending over and recieving a number
	```

	:::
	
	@param controllerName string -- The name of the controller
	@return ClientNetworkController<any>
]=]
CanaryEngineClient.CreateNetworkController = CanaryEngine.CreateNetworkControllerClient

--[=[
	Creates a new network controller on the server, with the name of `controllerName`

	:::tip

	You can set the data type of a network controller after it being made like the following:

	```lua
	local NetworkController: CanaryEngine.ServerNetworkController<number, number> = EngineServer.CreateNetworkController("MyNewNetworkController") -- assuming you are sending over and recieving a number
	```

	:::
	
	@param controllerName string -- The name of the controller
	@return ServerNetworkController<any>
]=]
CanaryEngineServer.CreateNetworkController = CanaryEngine.CreateNetworkControllerServer

CanaryScript.CreateSignal = CanaryEngine.CreateSignal
CanaryScript.GetLatestPackageVersionAsync = CanaryEngine.GetLatestPackageVersionAsync

return CanaryScript