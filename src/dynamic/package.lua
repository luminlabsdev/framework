local CanaryPackage = { }

--[=[
	A package's client-sided interface.
	
	@client
	@class CanaryPackageClient
]=]
local CanaryPackageClient = { }

--[=[
	A simple reference to the [Players.LocalPlayer].

	@prop Player Player
	@readonly

	@within CanaryPackageClient
]=]

--[=[
	A simple reference to the [Player.PlayerGui], useful for automatic typing and API simplicity.

	@prop PlayerGui StarterGui
	@readonly

	@within CanaryPackageClient
]=]

--[=[
	A simple reference to the player's [Backpack], useful for automatic typing and API simplicity.

	@prop PlayerBackpack StarterPack
	@readonly

	@within CanaryPackageClient
]=]

--[=[
	A reference to the Media folder on the client, also gives access to replicated media.

	@prop Media {Client: Folder, Replicated: Folder}
	@readonly

	@within CanaryPackageClient
]=]

--[=[
	A package's server-sided interface.
	
	@server
	@class CanaryPackageServer
]=]
local CanaryPackageServer = { }

--[=[
	A reference to the Media folder on the Server, also gives access to replicated media.

	@prop Media {Server: Folder, Replicated: Folder}
	@readonly

	@within CanaryPackageServer
]=]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local PlayerService = game:GetService("Players")
local CanaryEngine = require(script.Parent)

local Debugger = require(script.Parent.Vendor.Debugger)
local RuntimeContext = require(script.Parent.Vendor.Runtime).Context

local Network = script.Parent.Vendor.Network
local Data = script.Parent.Vendor.Data

local NetworkController = require(Network.NetworkController)

--[=[
	Gets the server-sided interface of CanaryEngine, for use in packages
	
	@server
	@return PackageServer?
]=]
function CanaryPackage.GetPackageServer()
	if RuntimeContext.Server then
		local EngineServer = ServerStorage:WaitForChild("EngineServer")
		local EngineReplicated = ReplicatedStorage:WaitForChild("EngineReplicated")

		CanaryPackageServer.Matchmaking = require(Network.MatchmakingService)
		CanaryPackageServer.Moderation = nil
		CanaryPackageServer.Data = require(Data.EasyProfile)

		CanaryPackageServer.Media = {
			Server = EngineServer.Media,
			Replicated = EngineReplicated.Media,
		}

		return CanaryPackageServer
	else
		Debugger.error("Failed to fetch 'PackageServer', Context must be server.")
	end
end

--[=[
	Gets the client-sided interface of CanaryEngine, for use in packages
	
	@client
	@return PackageClient?
]=]
function CanaryPackage.GetPackageClient()
	if RuntimeContext.Client then
		local EngineClient = ReplicatedStorage:WaitForChild("EngineClient")
		local EngineReplicated = ReplicatedStorage:WaitForChild("EngineReplicated")

		local Player = PlayerService.LocalPlayer

		CanaryPackageClient.Player = Player
		CanaryPackageClient.PlayerGui = Player:WaitForChild("PlayerGui") :: StarterGui
		CanaryPackageClient.PlayerBackpack = Player:WaitForChild("Backpack") :: StarterPack

		CanaryPackageClient.Media = {
			Client = EngineClient.Media,
			Replicated = EngineReplicated.Media,
		}

		return CanaryPackageClient
	else
		Debugger.error("Failed to fetch 'PackageClient', Context mush be client.")
	end
end

--[=[
	Creates a new network controller on the client, with the name of `controllerName`

	:::tip

	You can set the data type of a network controller after it being made like the following:

	```lua
	local NetworkController: CanaryEngine.ServerNetworkController<number, number> = PackageClient.CreateNetworkController("MyNewNetworkController") -- assuming you are sending over and recieving a number
	```

	:::
	
	@param controllerName string -- The name of the controller
	@return ClientNetworkController<any>
]=]
CanaryPackageClient.CreateNetworkController = CanaryEngine.CreateNetworkControllerClient

--[=[
	Creates a new network controller on the server, with the name of `controllerName`

	:::tip

	You can set the data type of a network controller after it being made like the following:

	```lua
	local NetworkController: CanaryEngine.ServerNetworkController<number, number> = PackageServer.CreateNetworkController("MyNewNetworkController") -- assuming you are sending over and recieving a number
	```

	:::
	
	@param controllerName string -- The name of the controller
	@return ServerNetworkController<any>
]=]
CanaryPackageServer.CreateNetworkController = CanaryEngine.CreateNetworkControllerServer

CanaryPackage.CreateSignal = CanaryEngine.CreateSignal
CanaryPackage.GetLatestPackageVersionAsync = CanaryEngine.GetLatestPackageVersionAsync

return CanaryPackage