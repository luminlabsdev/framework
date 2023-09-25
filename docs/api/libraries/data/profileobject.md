# ProfileObject <Badge type="danger" text="server" />

What is returned from loading a profile, this is used player-per-player or by a key.

## Methods

### GetProfileData

Gets the data for the profile that was loaded in.

**Returns**

* **[Dictionary](/api/engine/types#dictionary)<string, any>?**

---

### GetProfileTags

Gets the meta tags for the profile that was loaded in.

**Returns**

* **[Dictionary](/api/engine/types#dictionary)<string, any>?**

---

### CreateProfileLeaderstats

Creates leaderstats for Roblox's leaderboard based on provided values from the profile. If a value isn't supported, it won't be added to the leaderboard. Here is a list of natively supported types:

|Type|
|-|
|`boolean`|
|`number`|
|`string`|

**Parameters**

* **player:** `Player`\
The player to parent the leaderstats to, required because the owner of the profile can be the player **or** a set string

* **statsToAdd:** `Array<string>?`\
Specific stats to add, leaving this nil will account for all data on the profile

* **isAttributes:** `boolean?`\
No description

**Returns**

* **[Folder?](https://create.roblox.com/docs/reference/engine/classes/Folder)**

---

### GetGlobalKeys

Gets all of the global keys that were recieved when the target was offline.

**Returns**

* **[Array](/api/engine/types#array)\<[GlobalKey](/api/libraries/data/easyprofile#globalkey)\>?**

---

### AddUserIds

Adds `UserId`'s to the target profile.

**Parameters**

* **userIds:** `number | { number }`\
The `userId`s to add.

**Returns**

* **void**

---

### GetUserIds

Gets all the associated `userId`'s of the target profile.

**Returns**

* **[Array](/api/engine/types#array)\<number\>?**

---

### RemoveUserIds

Removes all the associated `userId`'s off of the target profile, leave `userIds` blank to clear all user IDs.

**Parameters**

* **userIds:** `number | { number }`\
The `userId`'s to clear off the target profile

**Returns**

* **void**

---

### GetMetaData

Gets all metadata that is related to the target profile.

**Returns**

* **[ProfileMetaData?](/api/libraries/data/easyprofile#profilemetadata)**

---

### GetDataUsage

Gets the amount of data (in percent) currently being used by the profile.

**Returns**

* **number?**

## Events

### GlobalKeyAdded

Fires when a global key has been recieved by the server.

**Parameters**

* **recievedKey:** `GlobalKey`\
The global key that was recieved