export type Controller<T> = {
    Start: (() -> ())?,
	Init: (() -> ())?,
    Uses: {
        any
    }?,
} & T

export type CycleType =
	"PostSimulation"
	| "PreSimulation"
	| "PreAnimation"
	| "PreRender"
	| "PlayerAdded"
	| "PlayerRemoving"

export type Cycle = {
	Connection: RBXScriptSignal,
	Callback: (...any) -> (),
}

export type Storage = {
	Controllers: {Controller<any>},
	Cycles: {Cycle},
}

return {}
