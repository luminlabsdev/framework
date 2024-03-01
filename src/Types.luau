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
		roblox: Decal
	}
} & Model

return Types