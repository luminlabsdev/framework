-- // by jackdotink

local FreeThread: thread? = nil

local function FunctionPasser(Callback, ...)
	local AquiredThread = FreeThread
	FreeThread = nil
	Callback(...)
	FreeThread = AquiredThread
end

local function Yielder()
	while true do
		FunctionPasser(coroutine.yield())
	end
end

return function<T...>(Callback: (T...) -> (), ...: T...)
	if not FreeThread then
		FreeThread = coroutine.create(Yielder)
		coroutine.resume(FreeThread :: any)
	end

	task.spawn(FreeThread :: thread, Callback, ...)
end