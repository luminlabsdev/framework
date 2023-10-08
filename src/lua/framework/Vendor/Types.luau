-- // Packages

local EngineTypes = { }

-- Tables

export type Dictionary<T, U> = {[T]: U}
export type Array<T> = {[number]: T}

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