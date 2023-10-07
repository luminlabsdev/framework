-- // Packages

local EngineTypes = { }
local Future = require(script.Parent.Libraries.RedbloxUtils.Future)

-- Tables

export type Dictionary<T, U> = {[T]: U}
export type Array<T> = {[number]: T}

-- Basic Controllers

type ControllerConnection = () -> ()

export type SignalController<T...> = {
	DisconnectAll: (self: SignalController<T...>) -> (),
	Fire: (self: PublicSignalController<T...>, T...) -> (),
} & PublicSignalController<T...>

export type PublicSignalController<T...> = {
	Connect: (self: PublicSignalController<T...>, func: (T...) -> ()) -> (ControllerConnection),
	Wait: (self: PublicSignalController<T...>) -> (T...),
	Once: (self: PublicSignalController<T...>, func: (T...) -> ()) -> (ControllerConnection),
}

-- Network Controllers

export type ClientNetworkController<T...> = {
	Listen: (self: ClientNetworkController<T...>, func: (T...) -> ()) -> (),

	Fire: (self: ClientNetworkController<T...>, T...) -> (),
	InvokeAsync: (self: ClientNetworkController<T...>, T...) -> (Future.Future<...any>),
}

export type ServerNetworkController<T...> = {
	Listen: (self: ServerNetworkController<T...>, func: (sender: Player, ...unknown) -> ()) -> (),
	BindToInvocation: (self: ServerNetworkController<T...>, callback: (sender: Player, ...unknown) -> (...any)) -> (),

	Fire: (self: ServerNetworkController<T...>, recipient: Player | Array<Player>, T...) -> (),
	FireAll: (self: ServerNetworkController<T...>, T...) -> (),
	FireExcept: (self: ServerNetworkController<T...>, except: Player | Array<Player>, T...) -> (),
	FireInRange: (self: ServerNetworkController<T...>, comparePoint: Vector3, maximumRange: number, T...) -> (),
	FireFilter: (self: ServerNetworkController<T...>, filter: (Player) -> (boolean), T...) -> (),

	SetRateLimit: (self: ServerNetworkController<T...>, maxInvokesPerSecond: number, invokeOverflowCallback: (sender: Player) -> ()) -> (),
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