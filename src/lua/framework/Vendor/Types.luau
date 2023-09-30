-- // Packages

local EngineTypes = { }
local Future = require(script.Parent.Libraries.RedbloxUtils.Future)

-- Tables

export type Dictionary<T, U> = {[T]: U}
export type Array<T> = {[number]: T}

-- Basic Controllers

type ControllerConnection = () -> ()

export type SignalController<T> = {
	DisconnectAll: (self: SignalController<T>) -> (),
	Fire: (self: PublicSignalController<T>, data: (Array<T> | T)?) -> (),
} & PublicSignalController<T>

export type PublicSignalController<T> = {
	Connect: (self: PublicSignalController<T>, func: (data: Array<T>) -> ()) -> (ControllerConnection),
	Wait: (self: PublicSignalController<T>) -> (Array<T>),
	Once: (self: PublicSignalController<T>, func: (data: Array<T>) -> ()) -> (ControllerConnection),

	Name: string,
}

-- Network Controllers

export type ClientNetworkController<T, U> = {
	Listen: (self: ClientNetworkController<T, U>, func: (data: Array<T>?) -> ()) -> (),

	Fire: (self: ClientNetworkController<T, U>, data: (Array<T> | T)?) -> (),
	InvokeAsync: (self: ClientNetworkController<T, U>, data: (Array<T> | T)?) -> (Future.Future<{U}>),

	Name: string,
}

export type ServerNetworkController<T, U> = {
	Listen: (self: ServerNetworkController<T, U>, func: (sender: Player, data: (Array<T> | unknown)?) -> ()) -> (),
	OnInvoke: (self: ServerNetworkController<T, U>, callback: (sender: Player, data: (Array<T> | unknown)?) -> (Array<U> | U)) -> (),
	
	Fire: (self: ServerNetworkController<T, U>, recipient: Player | Array<Player>, data: (Array<T> | T)?) -> (),
	FireAll: (self: ServerNetworkController<T, U>, data: (Array<T> | T)?) -> (),
	FireExcept: (self: ServerNetworkController<T, U>, except: Player | Array<Player>, data: (Array<T> | T)?) -> (),
	FireInRange: (self: ServerNetworkController<T, U>, comparePoint: Vector3, maximumRange: number, data: (Array<T> | T)?) -> (),

	SetRateLimit: (self: ServerNetworkController<T, U>, maxInvokesPerSecond: number, invokeOverflowCallback: (sender: Player) -> ()) -> (),
	Name: string,
}

-- Misc. Types

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
} & Model

return EngineTypes