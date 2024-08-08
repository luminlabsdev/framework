-- Variables

local Logs = {
	AlreadyStarted = "Framework has already started",
	CannotInit = "Init errored at %s; '%s'",
	CannotStart = "Start errored at %s; '%s'",
	ControllerAlreadyExists = "Controller '%s' already exists",
	NameTooShort = "Name must be greater than 0 characters",
	IncorrectType = "Item '%s' is the incorrect type; expects %s",
	IncorrectContext = "Using parameter %s on the incorrect context",
	MustProvide = "Must provider a %s",
	FireNowUnreliableProhibited = "Cannot use FireNow on unreliable events",
	ItemNotOptional = "Item '%s' is not optional and must be included",
	ItemNotFound = "Item '%s' could not be found as a valid item",
}

local FALLBACK = "missing log id"

-- Functions

local function Append(logId: string, ...): string
	return `[Lumin] {string.format(Logs[logId] or FALLBACK, ...)}`
end

local function Assert(assertion: any, logId: string, ...: any)
	if not assertion then
		error(Append(logId, ...), 0)
	end
end

local function Error(logId: string, ...: any)
	error(Append(logId, ...), 0)
end

local function Warn(logId: string, ...: any)
	warn(Append(logId, ...))
end

-- Module

return {
	Append = Append,
	Assert = Assert,
	Error = Error,
	Warn = Warn,
}
