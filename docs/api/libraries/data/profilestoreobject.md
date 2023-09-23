# ProfileStoreObject <Badge type="danger" text="server" />

Handles anything related to the profile store itself.

## Methods

### DeleteProfileAsync

Completely wipes the data of the key userId, good for complying with `GDPR` practices.

#### Parameters

* **target:** `number | string`\
The user id / key to erase the data of

#### Returns

* **[Future](https://util.redblox.dev/future.html#methods)**

---

### GetProfileAsync

Fetches the data off the key `userId`, this will only read data and does not load it.

#### Parameters

* **target:** `number | string`\
The user id / key to get of the data of

#### Returns

* **[Future](https://util.redblox.dev/future.html#methods)<[Dictionary](/api/engine/types#dictionary)<string, any>>**

---

### LoadProfileAsync

Loads the data off the key `userId`. All edits to this data will be saved and be able to be used next session.

#### Parameters

* **owner:** `Player | string`\
The owner of profile to load the data of

* **reconcileData:** `boolean?`\
Whether or not to reconcile the data of the profile, defaults to true

* **profileClaimedHandler:** `((placeId: number, gameJobId: string) -> (ProfileLoadType))? | ProfileLoadType?`\
The function to run when the profile is already claimed

#### Returns

* **[Future](https://util.redblox.dev/future.html#methods)<[ProfileObject?](/api/libraries/data/profileobject)>**

---

### RemoveGlobalKeyAsync

Removes the global key that sent by using [ProfileStoreObject:SetGlobalKeyAsync](#setglobalkeyasync) with the key ID of `keyId`. This only applies if it has not been recieved yet, which means the function should be ran around within the first minute of being sent.

#### Parameters

* **target:** `number | string`\
The target to remove the global key of

* **keyId:** `number`\
The `keyId` of the key to remove

#### Returns

* **[Future](https://util.redblox.dev/future.html#methods)**

---

### SetGlobalKeyAsync

Sets a global key for target profile, regardless of whether they share the same `JobId` as the sender or they are offline.

#### Parameters

* **target:** `number | string`\
The target to set the global key of

* **key:** `string`\
The key to send to the target

* **value:** `any`\
The value of `key`

#### Returns

* **[Future](https://util.redblox.dev/future.html#methods)**

---

### UnclaimSessionLock

Unclaims the session lock that the profile holds, throwing a warning if they are not session locked. This is usually because you did not load the profile data correctly.

`valuesToSave` Example usage:

```lua
Players.PlayerRemoving:Connect(function(player)
	MyDataStore:UnclaimSessionLock(player, {
		Coins = player:GetAttribute("Coins") -- Make sure coins is a member of your profile data, or it will skip over it.
	})
end)
```

#### Parameters

* **owner:** `Player | string`\
The owner of the profile to unclaim the session lock of

* **valuesToSave:** `Dictionary<string, any>?`\
Values to save that are not already saved to the profile data, for example attributes that need to be saved on player removing

* **hopReadyCallback:** `(() -> ())?`\
The function to run when a server hop is ready, leaving this blank will disable this feature

#### Returns

* **void**

## Events

### SessionLockClaimed

Fires when a session lock has been claimed.

#### Parameters

* **player:** `Player | string`\
The player/key whose session lock was claimed

---

### SessionLockUnclaimed

Fires when a session lock has been unclaimed.

#### Parameters

* **player:** `Player | string`\
The player/key whose session lock was unclaimed