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

export type Controller<T> = {
	Name: string?,
	IsController: boolean?,
	Init: (() -> ())?,
	Start: (() -> ())?,
} & T

export type Storage = {
	Controllers: {[string]: Controller<any>},
	Workers: {[string]: {Worker}},
	Nodes: {
		Signals: { [string]: Signal.Signal<...any> },
	},
}

return {}
