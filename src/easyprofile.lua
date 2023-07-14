type dictionary = {[string]: any}
type array = {[number]: any}

--[=[
	The metadata for a user's profile.

	@field ProfileCreated number
	@field ProfileLoadCount number
	@field ProfileActiveSession {placeId: number, jobId: string}

	@interface ProfileMetaData
	@within EasyProfile
]=]
type ProfileMetaData = {ProfileCreated: number; ProfileLoadCount: number; ProfileActiveSession: {placeId: number; jobId: string;}}

--[=[
	The type for the global key.

	@type GlobalKey {Key: string, Value: any, KeyId: number}
	@within EasyProfile
]=]
export type GlobalKey = {Key: string, Value: any, KeyId: number}

--[=[
	A script connection, similar to an [RBXScriptConnection].

	@field Disconnect (self: ScriptConnection) -> ()
	@field Connected boolean

	@interface ScriptConnection
	@within EasyProfile
	@private
]=]
type ScriptConnection = {
	Disconnect: (self: ScriptConnection) -> (),
	Connected: boolean,
}

--[=[
	A script signal, similar to an [RBXScriptSignal].

	@field Connect (self: ScriptSignal<T>?, func: (data: {T}) -> ()) -> (ScriptConnection)
	@field Wait (self: ScriptSignal<T>?) -> ({T})
	@field Once (self: ScriptSignal<T>?, func: (data: {T}) -> ()) -> (ScriptConnection)

	@interface ScriptSignal
	@within EasyProfile
	@private
]=]
type ScriptSignal<T> = {
	Connect: (self: ScriptSignal<T>?, func: (data: {T}) -> ()) -> (ScriptConnection),
	Wait: (self: ScriptSignal<T>?) -> ({T}),
	Once: (self: ScriptSignal<T>?, func: (data: {T}) -> ()) -> (ScriptConnection),
}

-- // Variables


--[=[
	The parent of all classes.

	@server
	@class EasyProfile
]=]
local EasyProfile = { }
local Vendor = script.Vendor

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local ProfileService = require(Vendor.ProfileService)
local Signal = require(Vendor.Signal)

local IsProfileStoreAlreadyLoaded = false
local CurrentLoadedProfileStore = nil

--[=[
	The object that holds the `ProfileStoreObject`.
	
	@server
	@class ProfileStoreObject
]=]
local ProfileStoreObject = { }

--[=[
	Fires when a session lock has been claimed.
	
	@within ProfileStoreObject
	@tag Event
	@prop SessionLockClaimed ScriptSignal<Player>
]=]

--[=[
	Fires when a session lock has been unclaimed.
	
	@within ProfileStoreObject
	@tag Event
	@prop SessionLockUnclaimed ScriptSignal<Player>
]=]

--[=[
	The profile name pattern.
	
	@within ProfileStoreObject
	@private
	@prop _Pattern string
]=]

--[=[
	The child object of `ProfileObject`.
	
	@server
	@class ProfileObject
]=]
local ProfileObject = { }

--[=[
	Fires when a global key has been recieved by the server.
	
	@within ProfileObject
	@tag event
	@prop GlobalKeyAdded ScriptSignal<GlobalKey>
]=]

--[=[
	The loaded profile.
	
	@within ProfileObject
	@private
	@prop Profile any
]=]

--[=[
	A table of the currently loaded players in game. Do not edit this unless you know what you are doing.
	
	@within EasyProfile
	@prop LoadedPlayers {Player}
]=]
EasyProfile.LoadedPlayers = { }

-- // Functions

local function assert<T>(assertion: T, msg: string, ...: any): T
	if not assertion then
		warn(string.format(msg, ...))
	end
	return assertion
end

assert(
	RunService:IsServer(),
	"Cannot run on any environments except the server."
)

--[=[
	Gets an existing profile store of creates one if it does not exist yet.
	
	@param name string? -- The name of the profile store to get, defaults to "Global"
	@param defaultPlayerData dictionary -- The default data of player when loaded, only applies if this is their first time joining 
	@param keyPattern string -- The pattern for the key to use, use '%d' as a placeholder for the player's `UserId`.
	
	@return DataStoreObject?
]=]
function EasyProfile.CreateProfileStore(name: string?, defaultPlayerData: dictionary, keyPattern: string?): typeof(setmetatable({ }, {__index = ProfileStoreObject}))?
	if not name then
		name = "Global"
	end

	if not keyPattern then
		keyPattern = "user_%d"
	end

	if IsProfileStoreAlreadyLoaded then
		error("Cannot have more than a single datastore being used a runtime, this is to prevent data mismanagement")
		return nil
	end

	if not defaultPlayerData then
		warn("Must include default player data")
		return nil
	end

	local ProfileStoreObjectMetatable = setmetatable({ }, {__index = ProfileStoreObject})
	local ProfileStore = ProfileService.GetProfileStore(name, defaultPlayerData)

	IsProfileStoreAlreadyLoaded = true
	CurrentLoadedProfileStore = ProfileStore

	ProfileStoreObject.SessionLockClaimed = Signal.new() :: ScriptSignal<Player>
	ProfileStoreObject.SessionLockUnclaimed = Signal.new() :: ScriptSignal<Player>

	ProfileStoreObject._Pattern = keyPattern

	return table.freeze(
		ProfileStoreObjectMetatable
	)
end

--[=[
	Completely wipes the data of the key `userId`, good for complying with GDPR practices.
	
	@param userId number -- The user id to erase the data of
	@yields
]=]
function ProfileStoreObject:DeleteProfileAsync(userId: number)
	if not CurrentLoadedProfileStore then
		warn("No profile store loaded, make sure API requests are enabled")
		return
	end

	CurrentLoadedProfileStore:WipeProfileAsync(string.format(
		self._Pattern,
		userId)
	)
end

--[=[
	Fetches the data off the key `userId`, this will only read data and does not load it.
	
	@param userId number -- The user id to get of the data of
	@yields
]=]
function ProfileStoreObject:GetProfileAsync(userId: number): dictionary?
	if not CurrentLoadedProfileStore then
		warn("No profile store loaded, make sure API requests are enabled")
		return
	end

	local RequestedData = CurrentLoadedProfileStore:ViewProfileAsync(string.format(
		self._Pattern,
		userId)
	).Data

	if not RequestedData then
		warn("Requested data for user", userId, "does not exist")
		return nil
	end

	return RequestedData
end

--[=[
	Loads the data off the key `userId`. All edits to this data will be saved and be able to be used next session.
	
	@param player Player -- The player to load the data of
	@param reconcileData boolean? -- Whether or not to reconcile the data of the player, defaults to true
	@param profileClaimedHandler ((placeId: number, gameJobId: string) -> ("Forceload" | "Cancel"))? -- The function to run when the profile of the player is already claimed
	
	@yields
]=]
function ProfileStoreObject:LoadProfileAsync(player: Player, reconcileData: boolean?, profileClaimedHandler: ((placeId: number, gameJobId: string) -> ("ForceLoad" | "Cancel"))?): typeof(setmetatable({}, {__index = ProfileObject}))?
	local ProfileObjectMetatable = setmetatable({ }, {__index = ProfileObject})

	if not CurrentLoadedProfileStore then
		warn("No profile store loaded, make sure API requests are enabled")
		return nil
	end

	if not player then
		warn("Cannot unclaim session lock for a player that is non-existent")
		return nil
	end

	local LoadedPlayerProfile = CurrentLoadedProfileStore:LoadProfileAsync(string.format(self._Pattern, player.UserId), profileClaimedHandler)
	local Success = true

	ProfileObject.GlobalKeyAdded = Signal.new() :: ScriptSignal<GlobalKey>

	if not LoadedPlayerProfile then
		player:Kick(`Data for user {player.UserId} could not be loaded, other JobId is trying to load this data already`)
		warn(`Data for user {player.UserId} could not be loaded, other JobId is trying to load this data already`)
		Success = false
		return nil
	end

	if not player:IsDescendantOf(Players) then
		LoadedPlayerProfile:Release()
		Success = false
		return nil
	end

	if reconcileData then
		LoadedPlayerProfile:Reconcile()
	end

	LoadedPlayerProfile:AddUserId(player.UserId)
	LoadedPlayerProfile:ListenToRelease(function()
		EasyProfile.LoadedPlayers[player] = nil
		self.SessionLockUnclaimed:Fire({player})

		setmetatable(ProfileObjectMetatable, nil)
		table.clear(ProfileObjectMetatable)

		player:Kick(`Data for user {player.UserId} active on another server, please try again`)
	end)

	for _, globalKey in LoadedPlayerProfile.GlobalUpdates:GetActiveUpdates() do
		LoadedPlayerProfile.GlobalUpdates:LockActiveUpdate(globalKey[1])
	end

	LoadedPlayerProfile.GlobalUpdates:ListenToNewActiveUpdate(function(keyId: number, data: any)
		LoadedPlayerProfile.GlobalUpdates:LockActiveUpdate(keyId)
	end)

	LoadedPlayerProfile.GlobalUpdates:ListenToNewLockedUpdate(function(keyId: number, data: any)
		ProfileObject.GlobalKeyAdded:Fire({{Key = data.Key; Value = data.Value; KeyId = keyId;}})
		LoadedPlayerProfile.GlobalUpdates:ClearLockedUpdate(keyId)
	end)

	self.SessionLockClaimed:Fire({player})

	EasyProfile.LoadedPlayers[player] = LoadedPlayerProfile
	ProfileObject.Profile = LoadedPlayerProfile

	if Success then
		return ProfileObjectMetatable
	else
		return nil
	end
end

--[=[
	Unclaims the session lock that `player` holds, throwing a warning if they are not session locked. This is usually because you did not load the player data correctly.
	
	`valuesToSave` Usage:
	
	```lua
	Players.PlayerRemoving:Connect(function(player)
		MyDataStore:UnclaimSessionLock(player, {
			Coins = player:GetAttribute("Coins") -- Make sure coins is a member of your profile data, or it will skip over it.
		})
	end)
	```
	
	@param player Player -- The player to unclaim the session lock of
	@param valuesToSave dictionary? -- Values to save that are not already saved to the player data, for example attributes that need to be saved on player removing
]=]
function ProfileStoreObject:UnclaimSessionLock(player: Player, valuesToSave: dictionary?)
	local PlayerProfile = EasyProfile.LoadedPlayers[player]

	if not PlayerProfile then
		warn("No profile loaded")
		return
	end

	if not CurrentLoadedProfileStore then
		warn("No profile store loaded, make sure API requests are enabled")
		return
	end

	if not player then
		warn("Cannot unclaim session lock for a player that is non-existent")
		return
	end

	if valuesToSave then
		for key, value in valuesToSave do
			if not PlayerProfile.Data[key] then
				warn(`Invalid key: {key} is an instance or does not exist.`)
				continue
			end

			PlayerProfile.Data[key] = value
		end
	end

	PlayerProfile:Release()
end

--[=[
	Sets a global key for `userId`, regardless of whether they share the same `JobId` as the sender or they are offline.
	
	@param userId number -- The player to set the global key of
	@param key string -- The key to send to `userId`
	@param value any -- The value of `key`
	
	@yields
]=]
function ProfileStoreObject:SetGlobalKeyAsync<a>(userId: number, key: string, value: a)
	if not CurrentLoadedProfileStore then
		warn("No profile store loaded, make sure API requests are enabled")
		return
	end

	CurrentLoadedProfileStore:GlobalUpdateProfileAsync(string.format(self._Pattern, userId), function(globalUpdates)
		globalUpdates:AddActiveUpdate({
			Key = key;
			Value = value;
		})
	end)
end

--[=[
	Removes the global key that sent by using `ProfileStoreObject:SetGlobalKeyAsync` with the key ID of `keyId`. This only applies if it has not been recieved yet.
	
	@param userId number -- The player to remove the global key of
	@param keyId number -- The `keyId` of the key to remove
	
	@yields
]=]
function ProfileStoreObject:RemoveGlobalKeyAsync(userId: number, keyId: number)
	if not CurrentLoadedProfileStore then
		warn("No profile store loaded, make sure API requests are enabled")
		return
	end

	CurrentLoadedProfileStore:GlobalUpdateProfileAsync(string.format(self._Pattern, userId), function(globalUpdates)
		globalUpdates:ClearActiveUpdate(keyId)
	end)
end

--[=[
	Gets the data for the profile that was loaded in.
	
	@return {[string]: any}?
]=]

function ProfileObject:GetProfileData(): {[string]: any}?
	local PlayerProfile = self.Profile

	if not PlayerProfile then
		warn("No profile loaded")
		return nil
	end

	return PlayerProfile.Data
end

--[=[
	Gets all of the global keys that were recieved when the player was offline.
	
	@return {GlobalKey}?
]=]
function ProfileObject:GetGlobalKeys(): {GlobalKey}?
	local PlayerProfile = self.Profile

	if not PlayerProfile then
		warn("No profile loaded")
		return nil
	end

	local GlobalKeys = { }

	for _, globalKey in PlayerProfile.GlobalUpdates:GetLockedUpdates() do
		table.insert(GlobalKeys, {Key = globalKey[2].Key; Value = globalKey[2].Value; KeyId = globalKey[1]})
		PlayerProfile.GlobalUpdates:ClearLockedUpdate(globalKey[1])
	end

	return table.freeze(GlobalKeys)
end

--[=[
	Adds `UserId`'s to the player's profile.
	
	@param userIds number | {number} -- The `UserId`s to add.
]=]
function ProfileObject:AddUserIds(userIds: number | {number})
	local PlayerProfile = self.Profile

	if not PlayerProfile then
		warn("No profile loaded")
		return nil
	end

	if type(userIds) == "number" then
		PlayerProfile:AddUserId(userIds)
		return
	end

	for _, userId in userIds do
		PlayerProfile:AddUserId(userId)
	end
end

--[=[
	Gets all the associated `UserId`'s of the player's profile.
	
	@return {number}?
]=]
function ProfileObject:GetUserIds(): {number}?
	local PlayerProfile = self.Profile

	if not PlayerProfile then
		warn("No profile loaded")
		return nil
	end

	return PlayerProfile.UserIds
end

--[=[
	Removes all the associated `UserId`'s off of the player's profile, leave `userIds` blank to clear all user IDs.
	
	@param userIds {number}? -- The `userId`'s to clear off the player's profile
]=]
function ProfileObject:RemoveUserIds(userIds: {number}?)
	local PlayerProfile = self.Profile

	if not PlayerProfile then
		warn("No profile loaded")
		return nil
	end

	if not userIds then
		userIds = PlayerProfile.UserIds
	end

	for _, userId in userIds :: {number} do
		PlayerProfile:RemoveUserId(userId)
	end
end

--[=[
	Gets all metadata that is related to the player's profile.

	@return ProfileMetaData?
]=]
function ProfileObject:GetMetaData(): ProfileMetaData?
	local PlayerProfile = self.Profile

	if not PlayerProfile then
		warn("No profile loaded")
		return nil
	end

	return table.freeze({
		ProfileCreated = PlayerProfile.MetaData.ProfileCreateTime;
		ProfileLoadCount = PlayerProfile.MetaData.SessionLoadCount;
		ProfileActiveSession = {placeId = PlayerProfile.MetaData.ActiveSession[1], jobId = PlayerProfile.MetaData.ActiveSession[2]}
	})
end

--[=[
	Gets the amount of data (in percent) currently being used by the profile.
	
	@return number?
]=]
function ProfileObject:GetDataUsage(): number?
	local PlayerProfile = self.Profile

	if not PlayerProfile then
		warn("No profile loaded")
		return nil
	end

	local EncodedUsage = HttpService:JSONEncode(PlayerProfile.Data)
	local UsageLength = string.len(EncodedUsage)

	return (UsageLength / 4194304) * 100
end

return table.freeze(EasyProfile)