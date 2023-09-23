# EasyProfile <Badge type="danger" text="server" />

A smart solution to data storing, built on top of ProfileService.

## Types

### ProfileMetaData <Badge type="tip" text="public" />

The metadata for a user's profile.

---

### GlobalKey <Badge type="tip" text="public" />

The type for the global key.

---

### ProfileLoadType <Badge type="tip" text="private" />

No description

## Properties

### LoadedData

A table of the currently loaded profiles in game, each key is based on a profile store.

* **[Dictionary](/api/engine/types#dictionary)<string, [Dictionary](/api/engine/types#dictionary)<Player | string, [ProfileObject](/api/libraries/data/profileobject)>>**

## Functions

### CreateProfileStore

Gets an existing profile store or creates one if it does not exist yet.

#### Parameters

* **name:** `string?`\
The name of the profile store to get, defaults to "Global"

* **defaultProfileData:** `Dictionary<string, any>`\
The default data of profie when loaded, only applies if this is their first time joining

* **playerKeyPattern:** `string?`\
The pattern for the key to use if used to store player data, use '%d' as a placeholder for the player's UserId.

#### Returns

* **[ProfileStoreObject?](/api/libraries/data/profilestoreobject)**

---