local Spawn = require(script.Parent.Spawn)

local Future = {}
Future.__index = Future

function Future.new<T..., A...>(Callback: (A...) -> T..., ...: A...)
	local self = setmetatable({}, Future)

	self.ValueList = nil :: { any }?

	self.AfterList = {} :: { (T...) -> () }
	self.YieldList = {} :: { thread }

	task.spawn(function(self, ...)
		self.ValueList = { Callback(...) }

		for _, Thread in self.YieldList do
			task.spawn(Thread, table.unpack(self.ValueList))
		end

		for _, Callback in self.AfterList do
			Spawn(Callback, table.unpack(self.ValueList))
		end
	end, self, ...)

	return self
end

export type Future<T...> = typeof(Future.new(function(): T... end))

function Future.Try<T..., A...>(Callback: (A...) -> T..., ...: A...)
	return Future.new(pcall, Callback, ...)
end

function Future.IsComplete<T...>(self: Future<T...>)
	return self.ValueList ~= nil
end

function Future.IsPending<T...>(self: Future<T...>)
	return self.ValueList == nil
end

function Future.Expect<T...>(self: Future<T...>, Message: string): T...
	assert(self.ValueList, Message)
	return table.unpack(self.ValueList)
end

function Future.Unwrap<T...>(self: Future<T...>): T...
	return self:Expect("Attempt to unwrap pending value!")
end

function Future.UnwrapOr<T...>(self: Future<T...>, ...: T...)
	if self.ValueList then
		return table.unpack(self.ValueList)
	else
		return ...
	end
end

function Future.UnwrapOrElse<T...>(self: Future<T...>, Else: () -> T...)
	if self.ValueList then
		return table.unpack(self.ValueList)
	else
		return Else()
	end
end

function Future.After<T...>(self: Future<T...>, Callback: (T...) -> ())
	table.insert(self.AfterList, Callback)
end

function Future.Await<T...>(self: Future<T...>): T...
	if self.ValueList then
		return table.unpack(self.ValueList)
	else
		table.insert(self.YieldList, coroutine.running())

		return coroutine.yield()
	end
end

return Future