local Signal = require(script.Parent.Parent.signal)

export type Controller<T> = T & {
	Name: string?,
	Start: (() -> ())?,
	Init: (() -> ())?,
	IsController: boolean?,
}

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
	Controllers: {Controller<any>},
	ExpectedControllers: {Controller<any>},
	Workers: { [string]: { [string]: { Worker } } },
	Nodes: {
		Signals: { [string]: Signal.Signal<...any> },
	},
}

return {}
