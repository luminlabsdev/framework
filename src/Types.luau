local Types = {}

export type Character15Joint = {
	["Body Colors"]: BodyColors,
	HumanoidRootPart: Part,
	Humanoid: Humanoid & {
		HumanoidDescription: HumanoidDescription,
		Animator: Animator,
	},
	Head: MeshPart & {
		face: Decal,
	},
	LeftFoot: MeshPart,
	LeftHand: MeshPart,
	LeftLowerArm: MeshPart,
	LeftLowerLeg: MeshPart,
	LeftUpperArm: MeshPart,
	LeftUpperLeg: MeshPart,
	LowerTorso: MeshPart,
	UpperTorso: MeshPart,
	RightFoot: MeshPart,
	RightHand: MeshPart,
	RightLowerArm: MeshPart,
	RightLowerLeg: MeshPart,
	RightUpperArm: MeshPart,
	RightUpperLeg: MeshPart,
} & Model

export type Character6Joint = {
	["Body Colors"]: BodyColors,
	HumanoidRootPart: Part,
	Humanoid: Humanoid & {
		HumanoidDescription: HumanoidDescription,
		Animator: Animator,
	},
	Head: Part & {
		face: Decal,
		Mesh: SpecialMesh,
	},
	["Left Arm"]: Part,
	["Left Leg"]: Part,
	["Right Arm"]: Part,
	["Right Leg"]: Part,
	["Torso"]: Part & {
		roblox: Decal,
	},
} & Model

export type NetworkRoot<T, U> = {
	Event: (name: string, reliable: boolean?) -> T,
	Function: (name: string, reliable: boolean?) -> U,
}

type Event = { Connect: (Event, callback: (...any) -> ()) -> () }

type PromiseStatus = {
	Started: string,
	Resolved: string,
	Rejected: string,
	Cancelled: string,
}

-- This type is directly created from the actual types listed out in the API (https://eryn.io/roblox-lua-promise/api/Promise).
export type Promise = {
	andThen: (Promise, successHandler: ((...any) -> ...any)?, failureHandler: ((...any) -> ...any)?) -> Promise,
	catch: (Promise, failureHandler: (...any) -> ...any) -> Promise,
	await: (Promise) -> (boolean, ...any),
	expect: (Promise) -> ...any,
	cancel: (Promise) -> (),
	now: (Promise, rejectionValue: any) -> Promise,
	andThenCall: (Promise, callback: (...any) -> any) -> Promise,
	andThenReturn: (Promise, ...any) -> Promise,
	awaitStatus: (Promise) -> (PromiseStatus, ...any),
	finally: (Promise, finallyHandler: (status: PromiseStatus) -> ...any) -> Promise,
	finallyCall: (Promise, callback: (...any) -> any, ...any?) -> Promise,
	finallyReturn: (Promise, ...any) -> Promise,
	getStatus: (Promise) -> PromiseStatus,
	tap: (Promise, tapHandler: (...any) -> ...any) -> Promise,
	timeout: (Promise, seconds: number, rejectionValue: any?) -> Promise,
}

export type ServerFunction = {
	OnInvoke: (
		self: ServerFunction,
		callback: (sender: Player, ...unknown) -> (any, ...any),
		typeValidationArgs: { string }?
	) -> (),
	SetRateLimit: (
		self: ServerFunction,
		maxCalls: number,
		resetInterval: number?,
		invokeOverflowCallback: (sender: Player) -> ()?
	) -> (),

	IsReliable: boolean,
}

export type ServerEvent = {
	Listen: (self: ServerEvent, func: (sender: Player, ...unknown) -> (), typeValidationArgs: { string }?) -> (),

	Fire: (self: ServerEvent, recipient: Player | { Player }, ...any) -> (),
	FireAll: (self: ServerEvent, ...any) -> (),
	FireExcept: (self: ServerEvent, except: Player | { Player }, ...any) -> (),
	FireFilter: (self: ServerEvent, filter: (Player) -> boolean, ...any) -> (),
	SetRateLimit: (
		self: ServerEvent,
		maxCalls: number,
		resetInterval: number?,
		fireOverflowCallback: (sender: Player) -> ()?
	) -> (),

	IsReliable: boolean,
}

export type ClientFunction = {
	InvokeAsync: (self: ClientFunction, ...any) -> Promise,

	IsReliable: boolean,
}

export type ClientEvent = {
	Listen: (self: ClientEvent, func: (...any) -> ()) -> (),
	Fire: (self: ClientEvent, ...any) -> (),

	IsReliable: boolean,
}

return Types
