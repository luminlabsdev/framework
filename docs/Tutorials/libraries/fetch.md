# Fetch

The fetch module is simply a wrapper for [HttpService:GetAsync](https://create.roblox.com/docs/reference/engine/classes/HttpService#GetAsync). It allows you to cache things you recieve automatically, is organized, and lets you retry a set amount of times if a request fails.

### Get Requests

Making a get request is as easy as it is to do through [HttpService:GetAsync](https://create.roblox.com/docs/reference/engine/classes/HttpService#GetAsync), but it has a lot of new and exciting features. You can even use a parameter to decode content before it is receieved. Here is a simple example of `Fetch` in use:

```lua
local LocationInfo = Fetch.FetchAsync("http://ip-api.com/json", true, 3)

print(LocationInfo) -- Output: {...}
```

This will get the location info of the current server, and will decode it's content based on the provided bool. It will retry 3 times at max.

### Caching

Caching is one of the big reasons why you would want to use `Fetch`, it allows you to specify a name for the cache and will store it in a table which you can access at any time unless removed. Here's how you would set it up:

```lua
Fetch.FetchAsync("http://ip-api.com/json", true, 3, "LocationInfo")
```

We can now fetch this info by doing a simple index!:

```lua
Fetch.FetchAsync("http://ip-api.com/json", true, 3, "LocationInfo")

print(Fetch.RequestCache.LocationInfo) -- Output: {...}
```

And thats all there is to it. What it really does is save time on making your caching infastructure. Caching data is especially important when using API's, so you don't run into the request limit and possibly get blocked.