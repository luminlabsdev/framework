// Adding support for individual libraries soon

interface EngineServer {
    Packages: {
        Server: Folder
        Replicated: Folder
    }

    Media: {
        Server: Folder
        Replicated: Folder
    }

    Matchmaking: {any}
    Moderation: null
    Data: {any}

	CreateNetworkController(controllerName: string): ServerNetworkController<any, any>;
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

    PlayerGui: StarterGui
    PlayerBackpack: StarterPack

	CreateNetworkController(controllerName: string): ClientNetworkController<any, any>;
}

interface EngineReplicated {
    Packages: {
        Replicated: Folder
    }

    Media: {
        Replicated: Folder
    }
}

interface ScriptConnection {
    Disconnect(): void;
    Connected: boolean;
}

export interface ScriptSignal<T> {
    Connect(func: (data: {T}) => (void)): ScriptConnection;
    Wait(): {T};
    Once(func: (data: {T}) => (void)): ScriptConnection;

    Fire(data: (T | {T}) | null): void;

    DisconnectAll(): void;
    Name: string;
}

export interface ClientNetworkController<T, U> {
    Connect(self: ClientNetworkController<T, U>, func: (data: {T} | null) => (void)): ScriptConnection;
    Wait(self: ClientNetworkController<T, U>): {T} | null;
    Once(self: ClientNetworkController<T, U>, func: (data: {T} | null) => (void)): ScriptConnection;

    Fire(self: ClientNetworkController<T, U>, data: (T | {T}) | null): void;
    InvokeAsync(self: ClientNetworkController<T, U>, data: (T | {T}) | null): {U} | null;

    DisconnectAll(): void;
    Name: string;
}

export interface ServerNetworkController<T, U> {
    Connect(self: ServerNetworkController<T, U>, func: (sender: Player, data: {T} | null) => (void)): ScriptConnection;
    Wait(self: ServerNetworkController<T, U>): [Player, {T} | null];
    Once(self: ServerNetworkController<T, U>, func: (sender: Player, data: {T} | null) => (void)): ScriptConnection;

    Fire(self: ServerNetworkController<T, U>, recipient: Player | {Player}, data: (T | {T}) | null): void;
    FireAll(self: ServerNetworkController<T, U>, data: (T | {T}) | null): void;
    FireExcept(self: ServerNetworkController<T, U>, except: Player | {Player}, data: (T | {T}) | null): void;
    OnInvoke(self: ServerNetworkController<T, U>, callback: (sender: Player, data: (T | {T}) | null) => U): void;

    SetRateLimit(self: ServerNetworkController<T, U>, maxInvokesPerSecond: number, invokeOverflowCallback: ((sender: Player) => (void)) | null);
    DisconnectAll(): void;
    Name: string;
}

export namespace CanaryEngine {
    export function GetEngineServer(): EngineServer;
	export function GetEngineClient(): EngineClient;
    export function GetEngineReplicated(): EngineReplicated;

	export function CreateSignal(signalName: string): ScriptSignal<any>;
    export function CreateAnonymousSignal(): ScriptSignal<any>;
	export function GetLatestPackageVersionAsync(packageInstance: any, warnIfNotLatestVersion: boolean | null, respectDebugger: boolean | null): number | null;

    export const Runtime: {
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
    }

    export const Libraries: {
        Utility: any
        Benchmark: any
        Statistics: any
        Serialize: any
    }
}