local Types = require(script.Parent.Parent.Types)
return {
	Controllers = {},
	Workers = {
		RunService = {
			PostSimulation = {},
			PreSimulation = {},
			PreAnimation = {},
			PreRender = {},
		},
		Players = {
			PlayerAdded = {},
			PlayerRemoving = {},
		},
	},
	Nodes = {
		Signals = {},
	},
} :: Types.Storage
