local Types = require(script.Parent.Parent.Types)
return {
	Controllers = {},
	Workers = {
		PostSimulation = {},
		PreSimulation = {},
		PreAnimation = {},
		PreRender = {},
	},
	Nodes = {
		Signals = {},
	},
} :: Types.Storage
