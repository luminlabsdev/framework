export type Controller<T> = {
    Start: (() -> ())?,
	Init: (() -> ())?,
    Uses: {
        any
    }?,
} & T

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
	Controllers: {Controller<any>},
	Workers: {Worker},
}

return {}
