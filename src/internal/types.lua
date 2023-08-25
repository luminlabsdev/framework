-- // Types

--[=[
	The parent of all classes.

	@class EngineTypes
]=]
local EngineTypes = { }

--[=[
	A controller connection, similar to an [RBXScriptConnection]

	@field Disconnect (self: ControllerConnection) -> ()
	@field Connected boolean

	@interface ControllerConnection
	@within EngineTypes
	@private
]=]
type ControllerConnection = {
	Disconnect: (self: ControllerConnection) -> (),
	Connected: boolean,
}

--[=[
	A signal controller, similar to an [RBXScriptSignal]

	@field Connect (self: SignalController<T>, func: (data: {T}) -> ()) -> (ControllerConnection)
	@field Wait (self: SignalController<T>) -> ({T})
	@field Once (self: SignalController<T>, func: (data: {T}) -> ()) -> (ControllerConnection)
	
	@field Fire (self: SignalController<T>, data: ({T} | T)?) -> ()

	@field DisconnectAll (self: SignalController<T>) -> ()
	@field Name string

	@interface SignalController
	@within EngineTypes
]=]
export type SignalController<T> = {
	Connect: (self: SignalController<T>, func: (data: {T}) -> ()) -> (ControllerConnection),
	Wait: (self: SignalController<T>) -> ({T}),
	Once: (self: SignalController<T>, func: (data: {T}) -> ()) -> (ControllerConnection),

	Fire: (self: SignalController<T>, data: ({T} | T)?) -> (),

	DisconnectAll: (self: SignalController<T>) -> (),
	Name: string,
}

--[=[
	A ClientNetworkController is basically a mixed version of a [RemoteEvent] and [RemoteFunction]. It has better features and is more performant.

	@field Connect (self: ClientNetworkController<T, U>, func: (data: {T}) -> ()) -> (ControllerConnection)
	@field Once (self: ClientNetworkController<T, U>, func: (data: {T}) -> ()) -> (ControllerConnection)
	@field Wait (self: ClientNetworkController<T, U>) -> ({T})
	
	@field Fire (self: ClientNetworkController<T, U>, data: ({T} | T)?) -> ()
	@field InvokeAsync (self: ClientNetworkController<T, U>, data: ({T} | T)?) -> ({U})

	@field Destroy (self: ClientNetworkController<T, U>) -> ()
	@field DisconnectAll (self: ClientNetworkController<T, U>) -> ()
	@field Name string

	@interface ClientNetworkController
	@within EngineTypes
]=]
export type ClientNetworkController<T, U> = {
	Connect: (self: ClientNetworkController<T, U>, func: (data: {T}) -> ()) -> (ControllerConnection),
	Wait: (self: ClientNetworkController<T, U>) -> ({T}),
	Once: (self: ClientNetworkController<T, U>, func: (data: {T}) -> ()) -> (ControllerConnection),

	Fire: (self: ClientNetworkController<T, U>, data: ({T} | T)?) -> (),
	InvokeAsync: (self: ClientNetworkController<T, U>, data: ({T} | T)) -> ({U}),

	Destroy: (self: ClientNetworkController<T, U>) -> (),
	DisconnectAll: (self: ClientNetworkController<T, U>) -> (),
	Name: string,
}

--[=[
	A ServerNetworkController is basically a mixed version of a [RemoteEvent] and [RemoteFunction]. It has better features and is more performant, though this is the server-sided API.

	@field Connect (self: ServerNetworkController<T, U>, func: (sender: Player, data: {T}) -> ()) -> (ControllerConnection)
	@field Once (self: ServerNetworkController<T, U>, func: (sender: Player, data: {T}) -> ()) -> (ControllerConnection)
	@field Wait (self: ServerNetworkController<T, U>) -> (Player, {T})
	
	@field Fire (self: ServerNetworkController<T, U>, recipient: Player | {Player}, data: ({T} | T)?) -> ()
	@field FireAll (self: ServerNetworkController<T, U>, data: ({T} | T)?) -> ()
	@field FireExcept (self: ServerNetworkController<T, U>, except: Player | {Player}, data: ({T} | T)?) -> ()
	@field FireInRange (self: ServerNetworkController<T, U>, comparePoint: Vector3, maximumRange: number, data: ({T} | T)?) -> ()
	@field OnInvoke (self: ServerNetworkController<T, U>, callback: (sender: Player, data: {T}) -> ()) -> ()
	
	@field SetRateLimit (self: ServerNetworkController<T, U>, maxInvokesPerSecond: number, invokeOverflowCallback: (sender: Player) -> ()) -> ()
	@field Destroy (self: ClientNetworkController<T, U>) -> ()
	@field DisconnectAll (self: ServerNetworkController<T, U>) -> ()
	@field Name string

	@interface ServerNetworkController
	@within EngineTypes
]=]
export type ServerNetworkController<T, U> = {
	Connect: (self: ServerNetworkController<T, U>, func: (sender: Player, data: {T}) -> ()) -> (ControllerConnection),
	Wait: (self: ServerNetworkController<T, U>) -> (Player, {T}),
	Once: (self: ServerNetworkController<T, U>, func: (sender: Player, data: {T}) -> ()) -> (ControllerConnection),
	
	Fire: (self: ServerNetworkController<T, U>, recipient: Player | {Player}, data: ({T} | T)?) -> (),
	FireAll: (self: ServerNetworkController<T, U>, data: ({T} | T)?) -> (),
	FireExcept: (self: ServerNetworkController<T, U>, except: Player | {Player}, data: ({T} | T)?) -> (),
	FireInRange: (self: ServerNetworkController<T, U>, comparePoint: Vector3, maximumRange: number, data: ({T} | T)?) -> (),
	OnInvoke: (self: ServerNetworkController<T, U>, callback: (sender: Player, data: {T}) -> ({U} | U)) -> (),

	SetRateLimit: (self: ServerNetworkController<T, U>, maxInvokesPerSecond: number, invokeOverflowCallback: (sender: Player) -> ()) -> (),
	Destroy: (self: ClientNetworkController<T, U>) -> (),
	DisconnectAll: (self: ServerNetworkController<T, U>) -> (),
	Name: string,
}

--[=[
	A basic type of an R6 character rig. Should be combined with model using the `&` syntax.

	@field Body_Colors BodyColors
	@field HumanoidRootPart Part
	@field Humanoid Humanoid
	@field Torso Part
	@field Head Part
	@field Animate LocalScript
	@field Left_Arm Part
	@field Left_Leg Part
	@field Right_Arm Part
	@field Right_Leg Part


	@interface Character
	@within EngineTypes
]=]
export type Character = {
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
	Animate: LocalScript & {
		PlayEmote: BindableFunction,
		ScaleDampeningPercent: NumberValue,
		climb: StringValue & {
			ClimbAnim: Animation
		},
		fall: StringValue & {
			FallAnim: Animation
		},
		idle: StringValue & {
			Animation1: Animation & {
				Weight: NumberValue
			},
			Animation2: Animation & {
				Weight: NumberValue
			}
		},
		jump: StringValue & {
			JumpAnim: Animation
		},
		run: StringValue & {
			RunAnim: Animation
		},
		sit: StringValue & {
			SitAnim: Animation
		},
		toolnone: StringValue & {
			ToolNoneAnim: Animation
		},
		walk: StringValue & {
			WalkAnim: Animation
		}
	},
	["Left Arm"]: Part,
	["Left Leg"]: Part,
	["Right Arm"]: Part,
	["Right Leg"]: Part,
	["Torso"]: Part & {
		roblox: Decal
	}
}

return EngineTypes