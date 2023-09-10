interface ControllerConnection {
    Disconnect(): void;
    Connected: boolean;
}

export interface SignalController<T> {
    Connect(func: (data: {[index: number]: T}) => (void)): ControllerConnection;
    Wait(): {[index: number]: T};
    Once(func: (data: {[index: number]: T}) => (void)): ControllerConnection;

    Fire(data: (T | {[index: number]: T}) | undefined): void;

    DisconnectAll(): void;
    Name: string;
}

export interface ClientNetworkController<T, U> {
    Connect(self: ClientNetworkController<T, U>, func: (data: {[index: number]: T} | undefined) => (void)): ControllerConnection;
    Wait(self: ClientNetworkController<T, U>): {[index: number]: T} | undefined;
    Once(self: ClientNetworkController<T, U>, func: (data: {[index: number]: T} | undefined) => (void)): ControllerConnection;

    Fire(self: ClientNetworkController<T, U>, data: (T | {[index: number]: T}) | undefined): void;
    InvokeAsync(self: ClientNetworkController<T, U>, data: (T | {[index: number]: T}) | undefined): {[index: number]: U} | undefined;
    
    Destroy(): void;
    DisconnectAll(): void;
    Name: string;
}

export interface Example {
    Hello(possibilyNull?: number): void;
}

export interface ServerNetworkController<T, U> {
    Connect(self: ServerNetworkController<T, U>, func: (sender: Player, data: {[index: number]: T} | undefined) => (void)): ControllerConnection;
    Wait(self: ServerNetworkController<T, U>): [Player, {[index: number]: T} | undefined];
    Once(self: ServerNetworkController<T, U>, func: (sender: Player, data: {[index: number]: T} | undefined) => (void)): ControllerConnection;

    Fire(self: ServerNetworkController<T, U>, recipient: Player | {[index: number]: Player}, data: (T | {[index: number]: T}) | undefined): void;
    FireAll(self: ServerNetworkController<T, U>, data: (T | {[index: number]: T}) | undefined): void;
    FireExcept(self: ServerNetworkController<T, U>, except: Player | {[index: number]: Player}, data: (T | {[index: number]: T}) | undefined): void;
    FireInRange(self: ServerNetworkController<T, U>, comparePoint: Vector3, maximumRange: number, data: (T | {[index: number]: T}) | undefined)
    OnInvoke(self: ServerNetworkController<T, U>, callback: (sender: Player, data: (T | {[index: number]: T}) | undefined) => U): void;

    SetRateLimit(self: ServerNetworkController<T, U>, maxInvokesPerSecond: number, invokeOverflowCallback: ((sender: Player) => (void)) | undefined);
    Destroy(): void;
    DisconnectAll(): void;
    Name: string;
}

export interface Sprite {
    Animate(image: ImageLabel, imageSize: Vector2, frames: Vector2, fps: number | undefined, imageId: string | undefined): void;
    StopAnimation(image: ImageLabel): void;
}

export interface Base64 {
    Encode(data: any): string;
    Decode(data: any): string;
}

export interface Statistics {
    GetMedian(numberList: {number}): number;
    GetMean(numberList: {number}): number;
    GetMode(numberList: {number}): number;
}

type CallStack = {Name: string, Source: string, DefinedLine: number}
type ExpectedType = "Axes" | "BrickColor" | "CatalogSearchParams" | "CFrame" | "Color3" | "ColorSequence" | "ColorSequenceKeypoint" | "Content" | "DateTime"
| "DockWidgetPluginGuiInfo" | "Enum" | "EnumItem" | "Enums" | "Faces" | "FloatCurveKey" | "Font" | "Instance" | "NumberRange" | "NumberSequence"
| "NumberSequenceKeyPoint" | "OverlapParams" | "PathWaypoint" | "PhysicalProperties" | "Random" | "Ray" | "RayastParams" | "RaycastResult" | "RBXScriptConnection"
| "RBXScriptSignal" | "Rect" | "Region3" | "Region3int16" | "SharedTable" | "TweenInfo" | "UDim" | "UDim2" | "Vector2" | "Vector2int16" | "Vector3" | "Vector3int16"
| "nil" | "boolean" | "number" | "string" | "function" | "userdata" | "thread" | "table"

export interface Debugger {
    Debug<T>(debugHandler: ((...T) => (void)) | ((message: T, level: number) => (void)), arguments: {[index: number]: T} | T, prefix: string | undefined, respectDebugger: boolean | undefined): void;
    GetCallStack(instance: Instance, stackName: string | undefined): CallStack;
    DebugInvalidData(paramNumber: number, funcName: string, expectedType: ExpectedType, param: unknown): void;

    CachedStackTraces: {[key: string]: CallStack}
}

type BenchmarkData = {Total: number, Longest: number, Shortest: number, Average: number};

interface BenchmarkObject {
    SetFunction(self: BenchmarkObject, timesToRun: number, func: (timesRan: number) => (void)): BenchmarkData;
    Start(self: BenchmarkObject): void;
    Stop(self: BenchmarkObject): void;
    GetCurrentTime(self: BenchmarkObject): number | undefined;
    Destroy(self: BenchmarkObject): void;
}

export interface Benchmark {
    CreateBenchmark(): BenchmarkObject
}

export interface Serialize {
    Serialize<T>(value: T): {[index: number]: any}
    Deserialize<T>(value: {[index: number]: any}): T
}

export interface Fetch {
    RequestCache: {[key: string]: any},
    FetchAsync(requestUrl: string, decodeContent: boolean | undefined, maxRetries: number | undefined, requestCachePool: string | undefined): any | undefined
}

export type GlobalKey = {Key: string, Value: any, KeyId: number}
type ProfileMetaData = {ProfileCreated: number; ProfileLoadCount: number; ProfileActiveSession: {placeId: number; jobId: string;}}

export interface ProfileObject {
    GlobalKeyAdded: SignalController<GlobalKey>;

    GetProfileData(self: ProfileObject): {[key: string]: any} | undefined;
    CreateProfileLeaderstats(self: ProfileObject, player: Player, statsToAdd: {[index: number]: string} | undefined): Folder | undefined;
    GetGlobalKeys(self: ProfileObject): {[index: number]: GlobalKey} | undefined;
    AddUserIds(self: ProfileObject, userIds: number | {[index: number]: number}): void | undefined;
    GetUserIds(self: ProfileObject): {[index: number]: number} | undefined;
    RemoveUserIds(self: ProfileObject, userIds: {[index: number]: number} | undefined): void | undefined;
    GetMetaData(self: ProfileObject): ProfileMetaData | undefined;
    GetDataUsage(self: ProfileObject): number | undefined;
}

export interface ProfileStoreObject {
    DeleteProfileAsync(self: ProfileStoreObject, userId: number): void;
    GetProfileAsync(self: ProfileStoreObject, userId: number): {[key: string]: any} | undefined;
    LoadProfileAsync(self: ProfileStoreObject, player: Player, reconcileData: boolean | undefined, profileClaimedHandler: ((placeId: number, gameJobId: string) => ("Forceload" | "Cancel")) | undefined): ProfileObject;
    UnclaimSessionLock(self: ProfileStoreObject, player: Player, valuesToSave: {[key: string]: any} | undefined): void;
    SetGlobalKeyAsync(self: ProfileStoreObject, userId: number, key: string, value: any): void;
    RemoveGlobalKeyAsync(self: ProfileStoreObject, userId: number, keyId: number): void;

    SessionLockClaimed: SignalController<Player>;
    SessionLockUnclaimed: SignalController<Player>;
}

export interface EasyProfile {
    CreateProfileStore(name: string | undefined, defaultPlayerData: {[key: string]: any}, keyPattern: string | undefined): ProfileStoreObject;
    LoadedPlayers: {[key: string]: {[key: string]: ProfileObject}};
}

interface EngineServer {
    Packages: {
        Server: Folder
        Replicated: Folder
    }

    Media: {
        Server: Folder
        Replicated: Folder
    }

    Data: EasyProfile
	CreateNetworkController(controllerName: string): ServerNetworkController<any, any>;
}

export interface Character {
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

interface EngineClient {
    Packages: {
        Client: Folder
        Replicated: Folder
    }

    Media: {
        Client: Folder
        Replicated: Folder
    }

    Player: Player
    Character: Character & Model

    PlayerGui: StarterGui
    PlayerBackpack: StarterPack

	CreateNetworkController(controllerName: string, controllerTimeout: number | undefined): ClientNetworkController<any, any>;
}

interface EngineReplicated {
    Packages: Folder
    Media: Folder
}

export namespace CanaryEngine {
    export function GetEngineServer(): EngineServer;
	export function GetEngineClient(): EngineClient;
    export function GetEngineReplicated(): EngineReplicated;

	export function CreateSignal(signalName: string | undefined): SignalController<any>;
    export function CreateAnonymousSignal(): SignalController<any>;

    export let Runtime: {
        RuntimeSettings: {
            StudioDebugEnabled: boolean;
            CheckLatestVersion: boolean;
            LiveGameDebugger: boolean
        };

        RuntimeContext: {
            Studio: boolean;
            Server: boolean;
            Client: boolean;
            StudioPlay: boolean;
        };

        RuntimeObjects: {
            NetworkControllers: {
                [key: string]: ClientNetworkController<any, any> | ServerNetworkController<any, any> 
            },

            SignalControllers: {
                [key: string]: SignalController<any>
            }
        }
    }
}