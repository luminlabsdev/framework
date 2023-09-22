type CallStack = {Name: string, Source: string, DefinedLine: number}
type ExpectedType = "Axes" | "BrickColor" | "CatalogSearchParams" | "CFrame" | "Color3" | "ColorSequence" | "ColorSequenceKeypoint" | "Content" | "DateTime"
| "DockWidgetPluginGuiInfo" | "Enum" | "EnumItem" | "Enums" | "Faces" | "FloatCurveKey" | "Font" | "Instance" | "NumberRange" | "NumberSequence"
| "NumberSequenceKeyPoint" | "OverlapParams" | "PathWaypoint" | "PhysicalProperties" | "Random" | "Ray" | "RayastParams" | "RaycastResult" | "RBXScriptConnection"
| "RBXScriptSignal" | "Rect" | "Region3" | "Region3int16" | "SharedTable" | "TweenInfo" | "UDim" | "UDim2" | "Vector2" | "Vector2int16" | "Vector3" | "Vector3int16"
| "nil" | "boolean" | "number" | "string" | "function" | "userdata" | "thread" | "table"

export namespace Debugger {
    export function Debug<T>(debugHandler: ((...T) => (void)) | ((message: T, level: number) => (void)), arguments: {[index: number]: T} | T, prefix: string | undefined, respectDebugger: boolean | undefined): void;
    export function GetCallStack(instance: Instance, stackName: string | undefined): CallStack;
    export function DebugInvalidData(paramNumber: number, funcName: string, expectedType: ExpectedType, param: unknown): void;

    export let CachedStackTraces: {[key: string]: CallStack}
}