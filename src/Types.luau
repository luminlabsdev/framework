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

export type PromiseEvent = { Connect: (PromiseEvent, callback: (...any) -> ()) -> () }

export type PromiseStatus = {
	Started: string,
	Resolved: string,
	Rejected: string,
	Cancelled: string,
}

export type Promise<T...> = {
	andThen: (Promise<T...>, successHandler: ((T...) -> ...any)?, failureHandler: ((T...) -> ...any)?) -> Promise<T...>,
	catch: (Promise<T...>, failureHandler: (T...) -> ...any) -> Promise<T...>,
	await: (Promise<T...>) -> (boolean, T...),
	expect: (Promise<T...>) -> T...,
	cancel: (Promise<T...>) -> (),
	now: (Promise<T...>, rejectionValue: any) -> Promise<T...>,
	andThenCall: (Promise<T...>, callback: (...any) -> any) -> Promise<T...>,
	andThenReturn: (Promise<T...>, ...any) -> Promise<T...>,
	awaitStatus: (Promise<T...>) -> (PromiseStatus, ...any),
	finally: (Promise<T...>, finallyHandler: (status: PromiseStatus) -> ...any) -> Promise<T...>,
	finallyCall: (Promise<T...>, callback: (...any) -> any, ...any?) -> Promise<T...>,
	finallyReturn: (Promise<T...>, ...any) -> Promise<T...>,
	getStatus: (Promise<T...>) -> PromiseStatus,
	tap: (Promise<T...>, tapHandler: (...any) -> ...any) -> Promise<T...>,
	timeout: (Promise<T...>, seconds: number, rejectionValue: any?) -> Promise<T...>,
}

export type PromiseLib = {
	Status: PromiseStatus,
	new: (
		executor: (
			resolve: (...any) -> (),
			reject: (...any) -> (),
			onCancel: (abortHandler: () -> ()?) -> boolean
		) -> ()
	) -> Promise<...any>,
} & any

export type NetworkRoot<T, U> = {
	Event: (name: string, reliable: boolean?) -> Promise<T>,
	Function: (name: string, reliable: boolean?) -> Promise<U>,
}

export type ServerFunction<T..., U...> = {
	OnInvoke: (
		self: ServerFunction<T..., U...>,
		callback: (sender: Player, T...) -> (U...),
		typeValidationArgs: { string }?
	) -> (),
	SetRateLimit: (
		self: ServerFunction<T..., U...>,
		maxCalls: number,
		resetInterval: number?,
		invokeOverflowCallback: (sender: Player) -> ()?
	) -> (),

	Reliable: boolean,
}

export type ServerEvent<T..., U...> = {
	Listen: (self: ServerEvent<T..., U...>, func: (sender: Player, U...) -> (), typeValidationArgs: { string }?) -> (),

	Fire: (self: ServerEvent<T..., U...>, recipient: Player | { Player }, T...) -> (),
	FireNow: (self: ServerEvent<T..., U...>, recipient: Player | { Player }, T...) -> (),
	FireAll: (self: ServerEvent<T..., U...>, T...) -> (),
	FireExcept: (self: ServerEvent<T..., U...>, except: Player | { Player }, T...) -> (),
	FireFilter: (self: ServerEvent<T..., U...>, filter: (Player) -> boolean, T...) -> (),
	SetRateLimit: (
		self: ServerEvent<T..., U...>,
		maxCalls: number,
		resetInterval: number?,
		fireOverflowCallback: (sender: Player) -> ()?
	) -> (),

	Reliable: boolean,
}

export type ClientFunction<T..., U...> = {
	InvokeAsync: (self: ClientFunction<T..., U...>, T...) -> Promise<U...>,
	Reliable: boolean,
}

export type ClientEvent<T..., U...> = {
	Listen: (self: ClientEvent<T..., U...>, func: (U...) -> ()) -> (),
	Fire: (self: ClientEvent<T..., U...>, T...) -> (),
	FireNow: (self: ClientEvent<T..., U...>, T...) -> (),

	Reliable: boolean,
}

export type Server<T> = {
	Network: NetworkRoot<ServerEvent<...any, ...any>, ServerFunction<...any, ...any>>,
} & T

export type Client<T> = {
	Network: NetworkRoot<ClientEvent<...any, ...any>, ClientFunction<...any, ...any>>,
	Player: Player,
	PlayerGui: PlayerGui,
	Camera: Camera,
	Character: () -> Promise<Character6Joint>,
} & T

return {}
