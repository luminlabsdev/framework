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
	for currentAttempt = 1, retries or 3 do
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
    @param requestCachePool {string | boolean}? -- Decides if the request is cached in [Fetch.RequestCache]. `returnValue` decides whether or not to return the value on the initial request.

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

return Fetch