--[=[
	The metadata for a user's profile.

	@field ProfileCreated number
	@field ProfileLoadCount number
	@field ProfileActiveSession {placeId: number, jobId: string}

	@interface ProfileMetaData
	@within EasyProfile
]=]
type ProfileMetaData = {ProfileCreated: number; ProfileLoadCount: number; ProfileActiveSession: {placeId: number; jobId: string;}}
type ProfileLoadType = "Repeat" | "Cancel" | "ForceLoad" | "Steal"

--[=[
	The type for the global key.

	@type GlobalKey {Key: string, Value: any, KeyId: number}
	@within EasyProfile
]=]
export type GlobalKey = {Key: string, Value: any, KeyId: number}

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
local Types = require(script.Parent.Parent.Parent.Types)
local Debugger = require(script.Parent.Parent.Debugger)
local Signal = require(script.Parent.Parent.Controllers.Vendor.SignalController)

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
	@prop SessionLockClaimed SignalController<Player>
]=]

--[=[
	Fires when a session lock has been unclaimed.
	
	@within ProfileStoreObject
	@tag Event
	@prop SessionLockUnclaimed SignalController<Player>
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
	@tag Event
	@prop GlobalKeyAdded SignalController<GlobalKey>
]=]

--[=[
	The loaded profile.
	
	@within ProfileObject
	@private
	@prop Profile any
]=]

--[=[
	A table of the currently loaded players in game, each key is based on a profile store.
	
	@within EasyProfile
	@prop LoadedPlayers {[string]: {[Player]: ProfileObject}}
]=]
EasyProfile.LoadedPlayers = { }

type EasyProfile = {
	LoadedPlayers: {[string]: {[Player]: ProfileObject}},
	CreateProfileStore: (name: string?, defaultPlayerData: {[string]: any}, keyPattern: string?) -> (ProfileStoreObject)
}

export type ProfileObject = {
	GetProfileData: (self: ProfileObject) -> ({[string]: any}),
	GetGlobalKeys: (self: ProfileObject) -> ({GlobalKey}?),
	AddUserIds: (self:ProfileObject, userIds: {number} | number) -> (),
	GetUserIds: (self: ProfileObject) -> ({number}?),
	RemoveUserIds: (self: ProfileObject, userIds: {number}?) -> (),
	GetMetaData: (self: ProfileObject) -> (ProfileMetaData),
	GetDataUsage: (self: ProfileObject) -> (number?),
}

export type ProfileStoreObject = {
	SessionLockClaimed: Types.SignalController<Player>,
	SessionLockUnclaimed: Types.SignalController<Player>,

	DeleteProfileAsync: (self: ProfileStoreObject, userId: number) -> (),
	GetProfileAsync: (self: ProfileStoreObject, userId: number) -> ({[string]: any}?),
	LoadProfileAsync: (self: ProfileStoreObject, player: Player, reconcileData: boolean?, profileClaimedHandler: (((placeId: number, gameJobId: string) -> (ProfileLoadType)) | ProfileLoadType)?) -> (ProfileObject),
	UnclaimSessionLock: (self: ProfileStoreObject, player: Player, valuesToSave: {[string]: any}, hopReadyCallback: (() -> ())?) -> (),
	SetGlobalKeyAsync: (self: ProfileStoreObject, userId: number, key: string, value: any) -> (),
	RemoveGlobalKeyAsync: (self: ProfileStoreObject, userId: number, keyId: number) -> (),
}

-- // Functions

if not RunService:IsServer() then
	error("Cannot run on any environments except the server.")
end

--[=[
	Gets an existing profile store of creates one if it does not exist yet.
	
	@param name string? -- The name of the profile store to get, defaults to "Global"
	@param defaultPlayerData dictionary -- The default data of player when loaded, only applies if this is their first time joining 
	@param keyPattern string -- The pattern for the key to use, use '%d' as a placeholder for the player's `UserId`.
	
	@return ProfileStoreObject?
]=]
function EasyProfile.CreateProfileStore(name: string?, defaultPlayerData: {[string]: any}, keyPattern: string?): ProfileStoreObject?
	if not defaultPlayerData then
		Debugger.Debug(warn, "Default player data is required")
		return nil
	end
	
	local ProfileStoreObjectMetatable = setmetatable({ }, {__index = ProfileStoreObject})
	local ProfileStore = ProfileService.GetProfileStore(name or "Global", defaultPlayerData)

	ProfileStoreObjectMetatable.SessionLockClaimed = Signal.NewController("SessionLockClaimed") :: Types.SignalController<Player>
	ProfileStoreObjectMetatable.SessionLockUnclaimed = Signal.NewController("SessionLockUnclaimed") :: Types.SignalController<Player>

	ProfileStoreObjectMetatable._ProfileStore = ProfileStore
	ProfileStoreObjectMetatable._Pattern = keyPattern or "user_%d"
	ProfileStoreObjectMetatable._Name = name or "Global"

	EasyProfile.LoadedPlayers[ProfileStoreObjectMetatable._Name] = { }

	return ProfileStoreObjectMetatable
end

--[=[
	Completely wipes the data of the key `userId`, good for complying with GDPR practices.
	
	@param userId number -- The user id to erase the data of
	@yields
]=]
function ProfileStoreObject:DeleteProfileAsync(userId: number)
	local CurrentLoadedProfileStore = self._ProfileStore
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
function ProfileStoreObject:GetProfileAsync(userId: number): {[string]: any}?
	local CurrentLoadedProfileStore = self._ProfileStore
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

	@yields
	
	@param player Player -- The player to load the data of
	@param reconcileData boolean? -- Whether or not to reconcile the data of the player, defaults to true
	@param profileClaimedHandler ((placeId: number, gameJobId: string) -> (ProfileLoadType))? -- The function to run when the profile of the player is already claimed
	
	@return ProfileObject?
]=]
function ProfileStoreObject:LoadProfileAsync(player: Player, reconcileData: boolean?, profileClaimedHandler: (((placeId: number, gameJobId: string) -> (ProfileLoadType)) | ProfileLoadType)?): ProfileObject?
	local ProfileObjectMetatable = setmetatable({ }, {__index = ProfileObject})
	local CurrentLoadedProfileStore = self._ProfileStore

	if not CurrentLoadedProfileStore then
		Debugger.Debug(warn, "No profile store loaded, make sure API requests are enabled")
		return nil
	end

	if not player then
		Debugger.Debug(warn, "Cannot unclaim session lock for a player that is non-existent")
		return nil
	end

	local LoadedPlayerProfile = CurrentLoadedProfileStore:LoadProfileAsync(string.format(self._Pattern, player.UserId), profileClaimedHandler)
	local Success = true

	ProfileObjectMetatable.GlobalKeyAdded = Signal.NewController("GlobalKeyAdded") :: Types.SignalController<GlobalKey>

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
		EasyProfile.LoadedPlayers[self._Name][player] = nil
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
		ProfileObjectMetatable.GlobalKeyAdded:Fire({{Key = data.Key; Value = data.Value; KeyId = keyId;}})
		LoadedPlayerProfile.GlobalUpdates:ClearLockedUpdate(keyId)
	end)

	self.SessionLockClaimed:Fire({player})

	EasyProfile.LoadedPlayers[self._Name][player] = ProfileObjectMetatable
	ProfileObjectMetatable.Profile = LoadedPlayerProfile

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
	@param hopReadyCallback? -- The function to run when a server hop is ready, leaving this blank will disable this feature
]=]
function ProfileStoreObject:UnclaimSessionLock(player: Player, valuesToSave: {[string]: any}?, hopReadyCallback: (() -> ())?)
	local CurrentLoadedProfileStore = self._ProfileStore
	local PlayerProfile = EasyProfile.LoadedPlayers[self._Name][player].Profile

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
				Debugger.Debug(warn, `Invalid key: {key} is an instance/primitive type or does not exist.`)
				continue
			end

			PlayerProfile.Data[key] = value
		end
	end

	PlayerProfile:Release()

	if hopReadyCallback then
		PlayerProfile:ListenToHopReady(hopReadyCallback)
	end
end

--[=[
	Sets a global key for `userId`, regardless of whether they share the same `JobId` as the sender or they are offline.
	
	@param userId number -- The player to set the global key of
	@param key string -- The key to send to `userId`
	@param value any -- The value of `key`
	
	@yields
]=]
function ProfileStoreObject:SetGlobalKeyAsync(userId: number, key: string, value: any)
	local CurrentLoadedProfileStore = self._ProfileStore
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
	local CurrentLoadedProfileStore = self._ProfileStore
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