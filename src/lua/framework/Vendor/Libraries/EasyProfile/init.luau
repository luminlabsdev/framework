-- // Package

local EasyProfile = { }
local Vendor = script.Parent.Vendor

-- // Variables

export type GlobalKey = {Key: string, Value: any, KeyId: number}

type ProfileMetaData = {ProfileCreated: number; ProfileLoadCount: number; ProfileActiveSession: {placeId: number; jobId: string;}}
type ProfileLoadType = "Repeat" | "Cancel" | "ForceLoad" | "Steal"

local EngineVendor = script.Parent.Parent.Parent
local EngineLibraries = EngineVendor.Libraries

local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local ProfileService = require(Vendor.ProfileService)
local Types = require(EngineVendor.Types)
local Debugger = require(EngineVendor.Debugger)
local Signal = require(EngineVendor.Controllers.Init).SignalController
local Future = require(EngineLibraries.RedbloxUtils.Future)

local ValidLeaderboardTypes = {
	"boolean",
	"number",
	"string",
}

local ValidAttributeTypes = {
	"string",
	"boolean",
	"number",
	"UDim",
	"UDim2",
	"BrickColor",
	"Color3",
	"Vector2",
	"Vector3",
	"EnumItem",
	"NumberSequence",
	"ColorSequence",
	"NumberRange",
	"Rect",
}

local ProfileStoreObject = { }
local ProfileObject = { }

EasyProfile.LoadedData = { }

type EasyProfile = {
	LoadedData: {[string]: {[Player | string]: ProfileObject}},
	CreateProfileStore: (name: string, defaultProfileData: {[string]: any}, playerKeyPattern: string?) -> (ProfileStoreObject)
}

export type ProfileObject = {
	GlobalKeyAdded: Types.SignalController<GlobalKey>,

	CreateProfileLeaderstats: (self: ProfileObject, player: Player, statsToAdd: {string}?) -> (),
	CanSaveData: (self: ProfileObject) -> (boolean),
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
	LoadProfileAsync: (self: ProfileStoreObject, owner: Player | string, reconcileData: boolean?, profileClaimedHandler: (((placeId: number, gameJobId: string) -> (ProfileLoadType)) | ProfileLoadType)?) -> (Future.Future<ProfileObject?>),
	UnclaimSessionLock: (self: ProfileStoreObject, owner: Player | string, valuesToSave: {[string]: any}, hopReadyCallback: (() -> ())?) -> (),
	SetGlobalKeyAsync: (self: ProfileStoreObject, target: number | string, key: string, value: any) -> (),
	RemoveGlobalKeyAsync: (self: ProfileStoreObject, target: number | string, keyId: number) -> (),
}

-- // Functions

if not RunService:IsServer() then
	error("Cannot run on any environments except the server.")
end

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

-- ProfileStoreObject

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
		Debugger.Debug(warn, `Cannot delete profile of type {typeof(target)}`, nil, false)
		return
	end

	CurrentLoadedProfileStore:WipeProfileAsync(str)
end

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
		Debugger.Debug(warn, `Cannot get profile of type {typeof(target)}`, nil, false)
		return nil
	end

	local RequestedData = CurrentLoadedProfileStore:ViewProfileAsync(str).Data

	if not RequestedData then
		warn("Requested data for target", target, "does not exist")
		return nil
	end

	return RequestedData
end

function ProfileStoreObject:LoadProfileAsync(owner: Player | string, reconcileData: boolean?, profileClaimedHandler: (((placeId: number, gameJobId: string) -> (ProfileLoadType)) | ProfileLoadType)?): Future.Future<ProfileObject?>
	return Future.Try(function(profileStore, owner, reconcileData, profileClaimedHandler)
		if not profileStore then
			error("No profile store loaded, make sure API requests are enabled")
		end
	
		local ProfileObjectMetatable = setmetatable({ }, {__index = ProfileObject})
	
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
	
		local LoadedProfile = profileStore:LoadProfileAsync(str, profileClaimedHandler) :: any
	
		ProfileObjectMetatable.GlobalKeyAdded = Signal.NewController("GlobalKeyAdded") :: Types.SignalController<GlobalKey>
	
		if not LoadedProfile then
			if typeof(owner) == "Instance" and owner:IsA("Player") then
				owner:Kick(`Data for profile {owner} could not be loaded, other JobId is trying to load this data already`)
			end
			warn(`Data for profile {owner} could not be loaded, other JobId is trying to load this data already`)
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

		ProfileObjectMetatable.Profile = LoadedProfile
		EasyProfile.LoadedData[self._Name][owner] = ProfileObjectMetatable

		return table.freeze(ProfileObjectMetatable)
	end, self._ProfileStore, owner, reconcileData, profileClaimedHandler)
end

function ProfileStoreObject:UnclaimSessionLock(owner: Player | string, valuesToSave: {[string]: any}?, hopReadyCallback: (() -> ())?)
	local CurrentLoadedProfileStore = self._ProfileStore
	if not CurrentLoadedProfileStore then
		warn("No profile store loaded, make sure API requests are enabled")
		return
	end
	
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

-- ProfileObjects

function ProfileObject:GetProfileData(): {[string]: any}?
	return self.Profile.Data
end

function ProfileObject:GetProfileTags(): {[string]: any}?
	return self.Profile.MetaData.MetaTags
end

function ProfileObject:CanSaveData(): boolean
	return self.Profile:IsActive()
end

function ProfileObject:CreateProfileLeaderstats(player: Player, statsToAdd: {string}?, isAttributes: boolean?): Folder?
	local Profile = self.Profile

	if not isAttributes then
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
	else
		for attribute, value in statsToAdd or Profile.Data do
			if not table.find(ValidAttributeTypes, typeof(value)) then
				continue
			end
			
			player:SetAttribute(attribute, value)
		end
	end
end

function ProfileObject:GetGlobalKeys(): {GlobalKey}?
	local Profile = self.Profile
	local GlobalKeys = { }

	for _, globalKey in Profile.GlobalUpdates:GetLockedUpdates() do
		table.insert(GlobalKeys, {Key = globalKey[2].Key; Value = globalKey[2].Value; KeyId = globalKey[1]})
		Profile.GlobalUpdates:ClearLockedUpdate(globalKey[1])
	end

	return table.freeze(GlobalKeys)
end

function ProfileObject:AddUserIds(userIds: number | {number})
	local Profile = self.Profile

	if type(userIds) == "number" then
		Profile:AddUserId(userIds)
		return
	end

	for _, userId in userIds do
		Profile:AddUserId(userId)
	end
end

function ProfileObject:GetUserIds(): {number}?
	return self.Profile.UserIds
end

function ProfileObject:RemoveUserIds(userIds: {number}?)
	local Profile = self.Profile

	if not userIds then
		userIds = Profile.UserIds
	end

	for _, userId in userIds :: {number} do
		Profile:RemoveUserId(userId)
	end
end

function ProfileObject:GetMetaData(): ProfileMetaData?
	local Profile = self.Profile

	return table.freeze({
		ProfileCreated = Profile.MetaData.ProfileCreateTime;
		ProfileLoadCount = Profile.MetaData.SessionLoadCount;
		ProfileActiveSession = {placeId = Profile.MetaData.ActiveSession[1], jobId = Profile.MetaData.ActiveSession[2]}
	})
end

function ProfileObject:GetDataUsage(): number?
	local EncodedUsage = HttpService:JSONEncode(self.Profile.Data)
	local UsageLength = string.len(EncodedUsage)

	return (UsageLength / 4194304) * 100
end

return table.freeze(EasyProfile)