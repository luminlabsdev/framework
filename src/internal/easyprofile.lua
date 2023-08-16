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

local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local ProfileService = require(Vendor.ProfileService)
local Types = require(script.Parent.Parent.Parent.Types)
local Debugger = require(script.Parent.Parent.Debugger)
local Signal = require(script.Parent.Parent.Controllers.Vendor.SignalController)

local ValidLeaderboardTypes = {
	"boolean",
	"number",
	"string",
}

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
	@prop SessionLockClaimed SignalController<Player | string>
]=]

--[=[
	Fires when a session lock has been unclaimed.
	
	@within ProfileStoreObject
	@tag Event
	@prop SessionLockUnclaimed SignalController<Player | string>
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
	A table of the currently loaded profiles in game, each key is based on a profile store.
	
	@within EasyProfile
	@prop LoadedData {[string]: {[Player | string]: ProfileObject}}
]=]
EasyProfile.LoadedData = { }

type EasyProfile = {
	LoadedData: {[string]: {[Player | string]: ProfileObject}},
	CreateProfileStore: (name: string, defaultProfileData: {[string]: any}, playerKeyPattern: string?) -> (ProfileStoreObject)
}

export type ProfileObject = {
	GlobalKeyAdded: Types.SignalController<GlobalKey>,

	CreateProfileLeaderstats: (self: ProfileObject, player: Player, statsToAdd: {string}?) -> (),
	GetProfileData: (self: ProfileObject) -> ({[string]: any}),
	GetGlobalKeys: (self: ProfileObject) -> ({GlobalKey}?),
	AddUserIds: (self: ProfileObject, userIds: {number} | number) -> (),
	GetUserIds: (self: ProfileObject) -> ({number}?),
	RemoveUserIds: (self: ProfileObject, userIds: {number}?) -> (),
	GetMetaData: (self: ProfileObject) -> (ProfileMetaData),
	GetDataUsage: (self: ProfileObject) -> (number?),
}

export type ProfileStoreObject = {
	SessionLockClaimed: Types.SignalController<Player | string>,
	SessionLockUnclaimed: Types.SignalController<Player | string>,

	DeleteProfileAsync: (self: ProfileStoreObject, owner: number | string) -> (),
	GetProfileAsync: (self: ProfileStoreObject, owner: number | string) -> ({[string]: any}?),
	LoadProfileAsync: (self: ProfileStoreObject, owner: Player | string, reconcileData: boolean?, profileClaimedHandler: (((placeId: number, gameJobId: string) -> (ProfileLoadType)) | ProfileLoadType)?) -> (ProfileObject),
	UnclaimSessionLock: (self: ProfileStoreObject, owner: Player | string, valuesToSave: {[string]: any}, hopReadyCallback: (() -> ())?) -> (),
	SetGlobalKeyAsync: (self: ProfileStoreObject, target: number | string, key: string, value: any) -> (),
	RemoveGlobalKeyAsync: (self: ProfileStoreObject, target: number | string, keyId: number) -> (),
}

-- // Functions

if not RunService:IsServer() then
	error("Cannot run on any environments except the server.")
end

--[=[
	Gets an existing profile store of creates one if it does not exist yet.
	
	@param name string? -- The name of the profile store to get, defaults to "Global"
	@param defaultProfileData dictionary -- The default data of profie when loaded, only applies if this is their first time joining 
	@param playerKeyPattern string -- The pattern for the key to use if used to store player data, use '%d' as a placeholder for the player's `UserId`.
	
	@return ProfileStoreObject?
]=]
function EasyProfile.CreateProfileStore(name: string?, defaultProfileData: {[string]: any}, playerKeyPattern: string?): ProfileStoreObject?
	if not defaultProfileData then
		Debugger.Debug(warn, "Default profile data is required")
		return nil
	end

	local ProfileStoreObjectMetatable = setmetatable({ }, {__index = ProfileStoreObject})
	local ProfileStore = ProfileService.GetProfileStore(name or "Global", defaultProfileData)

	ProfileStoreObjectMetatable.SessionLockClaimed = Signal.NewController("SessionLockClaimed") :: Types.SignalController<Player | string>
	ProfileStoreObjectMetatable.SessionLockUnclaimed = Signal.NewController("SessionLockUnclaimed") :: Types.SignalController<Player | string>

	ProfileStoreObjectMetatable._ProfileStore = ProfileStore
	ProfileStoreObjectMetatable._Pattern = playerKeyPattern or "user_%d"
	ProfileStoreObjectMetatable._Name = name or "Global"

	EasyProfile.LoadedData[ProfileStoreObjectMetatable._Name] = { }

	return ProfileStoreObjectMetatable
end

--[=[
	Completely wipes the data of the key `userId`, good for complying with GDPR practices.
	
	@param target number | string -- The user id / key to erase the data of
	@yields
]=]
function ProfileStoreObject:DeleteProfileAsync(target: number | string)
	local CurrentLoadedProfileStore = self._ProfileStore
	if not CurrentLoadedProfileStore then
		warn("No profile store loaded, make sure API requests are enabled")
		return
	end

	local str: string

	if typeof(target) == "string" then
		str = target
	elseif typeof(target) == "number" then
		str = string.format(self._Pattern, target)
	else
		Debugger.Debug(warn, `Cannot delete profile of type {typeof(target)}`)
		return
	end

	CurrentLoadedProfileStore:WipeProfileAsync(str)
end

--[=[
	Fetches the data off the key `userId`, this will only read data and does not load it.
	
	@param target number | string -- The user id / key to get of the data of
	@yields
]=]
function ProfileStoreObject:GetProfileAsync(target: number | string): {[string]: any}?
	local CurrentLoadedProfileStore = self._ProfileStore
	if not CurrentLoadedProfileStore then
		warn("No profile store loaded, make sure API requests are enabled")
		return
	end

	local str: string

	if typeof(target) == "string" then
		str = target
	elseif typeof(target) == "number" then
		str = string.format(self._Pattern, target)
	else
		Debugger.Debug(warn, `Cannot get profile of type {typeof(target)}`)
		return nil
	end

	local RequestedData = CurrentLoadedProfileStore:ViewProfileAsync(str).Data

	if not RequestedData then
		warn("Requested data for target", target, "does not exist")
		return nil
	end

	return RequestedData
end

--[=[
	Loads the data off the key `userId`. All edits to this data will be saved and be able to be used next session.

	@yields
	
	@param owner Player | string-- The owner of profile to load the data of
	@param reconcileData boolean? -- Whether or not to reconcile the data of the profile, defaults to true
	@param profileClaimedHandler ((placeId: number, gameJobId: string) -> (ProfileLoadType))? -- The function to run when the profile is already claimed
	
	@return ProfileObject?
]=]
function ProfileStoreObject:LoadProfileAsync(owner: Player | string, reconcileData: boolean?, profileClaimedHandler: (((placeId: number, gameJobId: string) -> (ProfileLoadType)) | ProfileLoadType)?): ProfileObject?
	local ProfileObjectMetatable = setmetatable({ }, {__index = ProfileObject})
	local CurrentLoadedProfileStore = self._ProfileStore

	if not CurrentLoadedProfileStore then
		Debugger.Debug(warn, "No profile store loaded, make sure API requests are enabled")
		return nil
	end

	if not owner then
		Debugger.Debug(warn, "Cannot unclaim session lock for a owner that is non-existent")
		return nil
	end

	local str: string

	if typeof(owner) == "string" then
		str = owner
	elseif typeof(owner) == "Instance" and owner:IsA("Player") then
		str = string.format(self._Pattern, owner.UserId)
	else
		Debugger.DebugInvalidData(1, "LoadProfileAsync", "Instance or string", owner, warn)
		return nil
	end

	local LoadedProfile = CurrentLoadedProfileStore:LoadProfileAsync(str, profileClaimedHandler) :: any
	local Success = true

	ProfileObjectMetatable.GlobalKeyAdded = Signal.NewController("GlobalKeyAdded") :: Types.SignalController<GlobalKey>

	if not LoadedProfile then
		if typeof(owner) == "Instance" and owner:IsA("Player") then
			owner:Kick(`Data for profile {owner} could not be loaded, other JobId is trying to load this data already`)
		end
		warn(`Data for profile {owner} could not be loaded, other JobId is trying to load this data already`)
		Success = false
		return nil
	end

	if reconcileData then
		LoadedProfile:Reconcile()
	end

	if typeof(owner) == "Instance" and owner:IsA("Player") then
		LoadedProfile:AddUserId(owner.UserId)
	end

	LoadedProfile:ListenToRelease(function()
		EasyProfile.LoadedData[self._Name][owner] = nil
		self.SessionLockUnclaimed:Fire({owner})

		setmetatable(ProfileObjectMetatable, nil)
		table.clear(ProfileObjectMetatable)

		if typeof(owner) == "Instance" and owner:IsA("Player") then
			owner:Kick(`Data for user {owner.UserId} active on another server, please try again`)
		end
	end)

	for _, globalKey in LoadedProfile.GlobalUpdates:GetActiveUpdates() do
		LoadedProfile.GlobalUpdates:LockActiveUpdate(globalKey[1])
	end

	LoadedProfile.GlobalUpdates:ListenToNewActiveUpdate(function(keyId: number, data: any)
		LoadedProfile.GlobalUpdates:LockActiveUpdate(keyId)
	end)

	LoadedProfile.GlobalUpdates:ListenToNewLockedUpdate(function(keyId: number, data: any)
		ProfileObjectMetatable.GlobalKeyAdded:Fire({{Key = data.Key; Value = data.Value; KeyId = keyId;}})
		LoadedProfile.GlobalUpdates:ClearLockedUpdate(keyId)
	end)

	self.SessionLockClaimed:Fire({owner})

	EasyProfile.LoadedData[self._Name][owner] = ProfileObjectMetatable
	ProfileObjectMetatable.Profile = LoadedProfile

	if Success then
		return ProfileObjectMetatable
	else
		return nil
	end
end

--[=[
	Unclaims the session lock that the profile holds, throwing a warning if they are not session locked. This is usually because you did not load the profile data correctly.
	
	`valuesToSave` Example usage:
	
	```lua
	Players.PlayerRemoving:Connect(function(player)
		MyDataStore:UnclaimSessionLock(player, {
			Coins = player:GetAttribute("Coins") -- Make sure coins is a member of your profile data, or it will skip over it.
		})
	end)
	```
	
	@param owner Player | string -- The owner of the profile to unclaim the session lock of
	@param valuesToSave dictionary? -- Values to save that are not already saved to the profile data, for example attributes that need to be saved on player removing
	@param hopReadyCallback? -- The function to run when a server hop is ready, leaving this blank will disable this feature
]=]
function ProfileStoreObject:UnclaimSessionLock(owner: Player | string, valuesToSave: {[string]: any}?, hopReadyCallback: (() -> ())?)
	local CurrentLoadedProfileStore = self._ProfileStore
	local Profile = EasyProfile.LoadedData[self._Name][owner].Profile

	if not Profile then
		warn("No profile loaded")
		return
	end

	if not CurrentLoadedProfileStore then
		warn("No profile store loaded, make sure API requests are enabled")
		return
	end

	if not owner then
		warn("Cannot unclaim session lock for a owner that is non-existent")
		return
	end

	if valuesToSave then
		for key, value in valuesToSave do
			if not Profile.Data[key] then
				Debugger.Debug(warn, `Invalid key: {key} is an instance/primitive type or does not exist.`)
				continue
			end

			Profile.Data[key] = value
		end
	end

	Profile:Release()

	if hopReadyCallback then
		Profile:ListenToHopReady(hopReadyCallback)
	end
end

--[=[
	Sets a global key for target profile, regardless of whether they share the same `JobId` as the sender or they are offline.
	
	@param target number | string -- The target to set the global key of
	@param key string -- The key to send to the target
	@param value any -- The value of `key`
	
	@yields
]=]
function ProfileStoreObject:SetGlobalKeyAsync(target: number | string, key: string, value: any)
	local CurrentLoadedProfileStore = self._ProfileStore
	if not CurrentLoadedProfileStore then
		warn("No profile store loaded, make sure API requests are enabled")
		return
	end

	local str: string

	if typeof(target) == "string" then
		str = target
	elseif typeof(target) == "number" then
		str = string.format(self._Pattern, target)
	else
		Debugger.Debug(warn, `Cannot set global key of type {typeof(target)}`)
		return
	end

	CurrentLoadedProfileStore:GlobalUpdateProfileAsync(str, function(globalUpdates)
		globalUpdates:AddActiveUpdate({
			Key = key;
			Value = value;
		})
	end)
end

--[=[
	Removes the global key that sent by using `ProfileStoreObject:SetGlobalKeyAsync` with the key ID of `keyId`. This only applies if it has not been recieved yet.
	
	@param target number | string -- The target to remove the global key of
	@param keyId number -- The `keyId` of the key to remove
	
	@yields
]=]
function ProfileStoreObject:RemoveGlobalKeyAsync(target: number | string, keyId: number)
	local CurrentLoadedProfileStore = self._ProfileStore
	if not CurrentLoadedProfileStore then
		warn("No profile store loaded, make sure API requests are enabled")
		return
	end

	local str: string

	if typeof(target) == "string" then
		str = target
	elseif typeof(target) == "number" then
		str = string.format(self._Pattern, target)
	else
		Debugger.Debug(warn, `Cannot remove global key of type {typeof(target)}`)
		return
	end

	CurrentLoadedProfileStore:GlobalUpdateProfileAsync(str, function(globalUpdates)
		globalUpdates:ClearActiveUpdate(keyId)
	end)
end

--[=[
	Gets the data for the profile that was loaded in.
	
	@return {[string]: any}?
]=]
function ProfileObject:GetProfileData(): {[string]: any}?
	local Profile = self.Profile

	if not Profile then
		warn("No profile loaded")
		return nil
	end

	return Profile.Data
end

--[=[
	Creates leaderstats for Roblox's leaderboard based on provided values from the profile. If a value isn't supported, it won't be added to the leaderboard. Here is a list of natively supported types:

	|Type|
	|-|
	|`boolean`|
	|`number`|
	|`string`|
	
	@param player Player -- The player to parent the leaderstats to, required because the owner of the profile can be the player **or** a set string
	@param statsToAdd {string}? -- Specific stats to add, leaving this nil will account for all data on the profile

	@return Folder?
]=]
function ProfileObject:CreateProfileLeaderstats(player: Player, statsToAdd: {string}?): Folder?
	local Profile = self.Profile

	if not Profile then
		warn("No profile loaded")
		return nil
	end

	local LeaderstatsFolder = Instance.new("Folder")

	for key, value in statsToAdd or Profile.Data do
		local ValueType = type(value)

		if not table.find(ValidLeaderboardTypes, ValueType) then
			continue
		end

		local StatClass = `{ValueType:gsub("^%l", string.upper)}Value`
		local NewStat = Instance.new(StatClass)

		NewStat.Name = key
		NewStat.Value = value
		NewStat.Parent = LeaderstatsFolder
	end

	LeaderstatsFolder.Name = "leaderstats"
	LeaderstatsFolder.Parent = player

	return LeaderstatsFolder
end

--[=[
	Gets all of the global keys that were recieved when the target was offline.
	
	@return {GlobalKey}?
]=]
function ProfileObject:GetGlobalKeys(): {GlobalKey}?
	local Profile = self.Profile

	if not Profile then
		warn("No profile loaded")
		return nil
	end

	local GlobalKeys = { }

	for _, globalKey in Profile.GlobalUpdates:GetLockedUpdates() do
		table.insert(GlobalKeys, {Key = globalKey[2].Key; Value = globalKey[2].Value; KeyId = globalKey[1]})
		Profile.GlobalUpdates:ClearLockedUpdate(globalKey[1])
	end

	return table.freeze(GlobalKeys)
end

--[=[
	Adds `UserId`'s to the target profile.
	
	@param userIds number | {number} -- The `UserId`s to add.
]=]
function ProfileObject:AddUserIds(userIds: number | {number})
	local Profile = self.Profile

	if not Profile then
		warn("No profile loaded")
		return
	end

	if type(userIds) == "number" then
		Profile:AddUserId(userIds)
		return
	end

	for _, userId in userIds do
		Profile:AddUserId(userId)
	end
end

--[=[
	Gets all the associated `UserId`'s of the target profile.
	
	@return {number}?
]=]
function ProfileObject:GetUserIds(): {number}?
	local Profile = self.Profile

	if not Profile then
		warn("No profile loaded")
		return nil
	end

	return Profile.UserIds
end

--[=[
	Removes all the associated `UserId`'s off of the target profile, leave `userIds` blank to clear all user IDs.
	
	@param userIds {number}? -- The `userId`'s to clear off the target profile
]=]
function ProfileObject:RemoveUserIds(userIds: {number}?)
	local Profile = self.Profile

	if not Profile then
		warn("No profile loaded")
		return
	end

	if not userIds then
		userIds = Profile.UserIds
	end

	for _, userId in userIds :: {number} do
		Profile:RemoveUserId(userId)
	end
end

--[=[
	Gets all metadata that is related to the target profile.

	@return ProfileMetaData?
]=]
function ProfileObject:GetMetaData(): ProfileMetaData?
	local Profile = self.Profile

	if not Profile then
		warn("No profile loaded")
		return nil
	end

	return table.freeze({
		ProfileCreated = Profile.MetaData.ProfileCreateTime;
		ProfileLoadCount = Profile.MetaData.SessionLoadCount;
		ProfileActiveSession = {placeId = Profile.MetaData.ActiveSession[1], jobId = Profile.MetaData.ActiveSession[2]}
	})
end

--[=[
	Gets the amount of data (in percent) currently being used by the profile.
	
	@return number?
]=]
function ProfileObject:GetDataUsage(): number?
	local Profile = self.Profile

	if not Profile then
		warn("No profile loaded")
		return nil
	end

	local EncodedUsage = HttpService:JSONEncode(Profile.Data)
	local UsageLength = string.len(EncodedUsage)

	return (UsageLength / 4194304) * 100
end

return table.freeze(EasyProfile)