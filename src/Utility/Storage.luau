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
		PlayerService = {
			PlayerAdded = {},
			PlayerRemoving = {},
		},
	},
	Nodes = {
		Signals = {},
	},
} :: Types.Storage
