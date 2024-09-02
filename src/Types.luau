export type Controller = {
    Start: (() -> ())?,
	Init: (() -> ())?,
    Uses: {Controller}?,
}

export type DevController<T> = T & Controller

export type WorkerType =
	"PostSimulation"
	| "PreSimulation"
	| "PreAnimation"
	| "PreRender"
	| "PlayerAdded"
	| "PlayerRemoving"

export type Worker = {
	Connection: RBXScriptSignal,
	Callback: (...any) -> (),
}

export type Storage = {
	Controllers: {DevController<any>},
	Workers: {Worker},
}

return {}
