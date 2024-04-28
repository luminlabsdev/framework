local Types = require(script.Parent.Types)
local Signal = require(script.Parent.Parent.signal)

return {
	Signals = {} :: { [string]: Signal.Signal<...any> },
	Networks = {
		Event = {} :: { [string]: Types.ClientEvent | Types.ServerEvent },
		Function = {} :: { [string]: Types.ClientFunction | Types.ServerFunction },
	},
}
