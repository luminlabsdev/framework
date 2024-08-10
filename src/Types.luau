local Signal = require(script.Parent.Parent.signal)

export type WorkerType =
	  "PostSimulation"
	| "PreSimulation"
	| "PreAnimation"
	| "PreRender"
	| "PlayerAdded"
	| "PlayerRemoving"

export type Worker = {
	Type: WorkerType,
	Callback: (...any) -> (),
	IsWorker: boolean,
}

export type Storage = {
	Controllers: {[string]: {[string]: any}},
	Workers: {[string]: {Worker}},
	Nodes: {
		Signals: { [string]: Signal.Signal<...any> },
	},
}

return {}
