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

ProfileStoreObject.__index = ProfileStoreObject
ProfileObject.__index = ProfileObject

EasyProfile.LoadedData = { }

-- // Functions

if not RunService:IsServer() then
	error("Cannot run on any environments except the server.")
end

local function IsProfileKeyValid(target: (Player | string | number)?, pattern: string, err: string, ...: string): string
	if not target then
		error("Target does not exist; did you forget to pass it?")
	end

	if typeof(target) == "string" then
		return target
	elseif typeof(target) == "number" then
		return string.format(pattern, target)
	elseif typeof(target) == "Instance" and target:IsA("Player") then
		return string.format(pattern, target.UserId)
	else
		error(string.format(err, ...))
	end
end

function EasyProfile.CreateProfileStore(name: string?, defaultProfileData: {[string]: any}, playerKeyPattern: string?)
	if not defaultProfileData then
		error("Default profile data is required")
	end

	local ProfileStoreObjectMetatable = setmetatable({ }, ProfileStoreObject)
	local ProfileStore = ProfileService.GetProfileStore(name or "Global", defaultProfileData)

	ProfileStoreObjectMetatable.SessionLockClaimed = Signal.CreateController("SessionLockClaimed") :: Types.SignalController<Player | string>
	ProfileStoreObjectMetatable.SessionLockUnclaimed = Signal.CreateController("SessionLockUnclaimed") :: Types.SignalController<Player | string>

	ProfileStoreObjectMetatable._ProfileStore = ProfileStore
	ProfileStoreObjectMetatable._Pattern = playerKeyPattern or "%d"
	ProfileStoreObjectMetatable._Name = name or "Global"

	EasyProfile.LoadedData[ProfileStoreObjectMetatable._Name] = { }

	return table.freeze(ProfileStoreObjectMetatable)
end

-- ProfileStoreObject

function ProfileStoreObject:DeleteProfileAsync(target: number | string)
	local CurrentLoadedProfileStore = self._ProfileStore
	local ProfileKey = IsProfileKeyValid(target, self._Pattern,
	 "Cannot delete profile of type %s",
	  typeof(target))

	CurrentLoadedProfileStore:WipeProfileAsync(ProfileKey)
end

function ProfileStoreObject:GetProfileAsync(target: number | string): Future.Future<boolean, {[string]: any}, () -> ()>
	return Future.Try(function(profileStore, target)
		local ProfileKey = IsProfileKeyValid(target, self._Pattern,
		"Cannot get profile of type %s",
		 typeof(target))

		local ProfileToView = profileStore:ViewProfileAsync(ProfileKey)

		if not ProfileToView then
			error(`Requested data for target {target} does not exist, or was not fetched properly`)
		end

		local Overwrite: () -> () | nil

		Overwrite = function()
			ProfileToView:OverwriteAsync()
			Overwrite = nil
		end

		return ProfileToView.Data, Overwrite
	end, self._ProfileStore, target)
end

function ProfileStoreObject:LoadProfileAsync(owner: Player | string, reconcileData: boolean?, profileClaimedHandler: (((placeId: number, gameJobId: string) -> (ProfileLoadType)) | ProfileLoadType)?): Future.Future<boolean, typeof(ProfileObject)>
	return Future.Try(function(profileStore, owner, reconcileData, profileClaimedHandler)
		local ProfileObjectMetatable = setmetatable({ }, ProfileObject)
		local ProfileKey = IsProfileKeyValid(owner, self._Pattern,
	 "Cannot get profile of type %s",
	  	typeof(owner))
	
		local LoadedProfile = profileStore:LoadProfileAsync(ProfileKey, profileClaimedHandler)
	
		if not LoadedProfile then
			if typeof(owner) == "Instance" and owner:IsA("Player") then
				owner:Kick(`Data for profile {owner} could not be loaded, other JobId is trying to load this data already`)
			end

			error(`Data for profile {owner} could not be loaded, other JobId is trying to load this data already`)
		end
	
		if reconcileData then
			LoadedProfile:Reconcile()
		end
	
		if typeof(owner) == "Instance" and owner:IsA("Player") then
			LoadedProfile:AddUserId(owner.UserId)
		end
	
		LoadedProfile:ListenToRelease(function()
			EasyProfile.LoadedData[self._Name][owner] = nil
			self.SessionLockUnclaimed:Fire(owner)
	
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

		ProfileObjectMetatable.GlobalKeyAdded = Signal.CreateController("GlobalKeyAdded") :: Types.SignalController<GlobalKey>
		ProfileObjectMetatable.Profile = LoadedProfile

		EasyProfile.LoadedData[self._Name][owner] = ProfileObjectMetatable
		self.SessionLockClaimed:Fire(owner)

		return table.freeze(ProfileObjectMetatable)
	end, self._ProfileStore, owner, reconcileData, profileClaimedHandler)
end

function ProfileStoreObject:UnclaimSessionLock(owner: Player | string, valuesToSave: {[string]: any}?, hopReadyCallback: (() -> ())?)
	local ProfileKey = IsProfileKeyValid(owner, self._Pattern,
	 "Cannot unclaim invalid session reference: %s",
	  typeof(owner))
	
	local Profile = EasyProfile.LoadedData[self._Name][ProfileKey].Profile

	if valuesToSave then
		for key, value in valuesToSave do
			if not Profile.Data[key] then
				error(`Invalid key: {key} is an instance/primitive type or does not exist.`)
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
	local ProfileKey = IsProfileKeyValid(target, self._Pattern,
	 "Cannot sent global key to invalid user: %s",
	  typeof(target))

	CurrentLoadedProfileStore:GlobalUpdateProfileAsync(ProfileKey, function(globalUpdates)
		globalUpdates:AddActiveUpdate({
			Key = key;
			Value = value;
		})
	end)
end

function ProfileStoreObject:RemoveGlobalKeyAsync(target: number | string, keyId: number)
	local CurrentLoadedProfileStore = self._ProfileStore
	local ProfileKey = IsProfileKeyValid(target, self._Pattern,
	 "Cannot remove global key for invalid user: %s",
	  typeof(target))

	CurrentLoadedProfileStore:GlobalUpdateProfileAsync(ProfileKey, function(globalUpdates)
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

	return nil
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