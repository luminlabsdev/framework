--[=[
	The parent of all classes.

	@class Fetch
]=]
local Fetch = { }

--[=[
	Cached data from previously made requests.

	@prop RequestCache {[string]: any}
	@within Fetch
]=]

local HttpService = game:GetService("HttpService")

Fetch.RequestCache = { } :: {[string]: any}

local function pcallRetry<A..., B...>(func: (A...) -> (B...), retries: number?, ...: A...): (boolean, B...)	
	for currentAttempt = 1, (retries or 3) + 1 do
		local success, result = pcall(func, ...)

		if success then
			return true, result
		end

		if currentAttempt ~= retries then
			continue
		end

		return false, result
	end

	return false, nil
end

--[=[
	Gets the contents from a specified URL, retrying multiple times if the request was not a success.

	@param requestUrl string -- The url to make the request to
	@param decodeContent boolean? -- Whether or not the request should be decoded
	@param maxRetries number? -- The maximum amount of retries if the request fails
	@param requestCachePool string -- Decides if the request is cached in [Fetch.RequestCache]

	@return any
]=]
function Fetch.FetchAsync(requestUrl: string, decodeContent: boolean?, maxRetries: number?, requestCachePool: string?): any?
	if requestCachePool and Fetch.RequestCache[requestCachePool] then
		return Fetch.RequestCache[requestCachePool]
	end

	local success, result = pcallRetry(HttpService.GetAsync, maxRetries, HttpService, requestUrl)

	if not success then
		warn(`Fatal: Could not get the contents of '{requestUrl}'`)
		return
	end

	if decodeContent then
		result = HttpService:JSONDecode(result)
	end

	if requestCachePool then
		Fetch.RequestCache[requestCachePool] = result
		return result
	end

	return result
end

--[=[
	Sets a module script to hold the http cache contents, using this will allow you to also input any previous cache.

	@param moduleScript ModuleScript -- The module to store the cache in
]=]
function Fetch.SetHttpCacheTable(moduleScript: ModuleScript)
	local tableCount = 0

	for key, value in Fetch.RequestCache do
		tableCount += 1
	end

	if tableCount == 0 then
		Fetch.RequestCache = require(moduleScript)
	else
		local module = require(moduleScript)

		for key, value in Fetch.RequestCache do
			module[key] = value
		end

		Fetch.RequestCache = module
	end
end

return Fetch