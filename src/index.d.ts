// Adding support for individual libraries soon

interface EngineServer {
    Packages: {
        Server: any
        Replicated: any
    }

    Media: {
        Server: any
        Replicated: any
    }

    Matchmaking: {any}
    Moderation: null
    Data: {any}

	CreateNetworkController(controllerName: string): ServerNetworkController<any>;
}

interface EngineClient {
    Packages: {
        Client: any
        Replicated: any
    }

    Media: {
        Client: any
        Replicated: any
    }

    Player: Player

    PlayerGui: StarterGui
    PlayerBackpack: StarterPack

	CreateNetworkController(controllerName: string): ClientNetworkController<any>;
}

interface PackageServer {
    Media: {
        Server: any
        Replicated: any
    }

    Matchmaking: {any}
    Moderation: null
    Data: {any}

    CreateNetworkController(controllerName: string): ServerNetworkController<any>;
}

interface PackageClient {
    Media: {
        Client: any
        Replicated: any
    }

    Player: Player

    PlayerGui: StarterGui
    PlayerBackpack: StarterPack

    CreateNetworkController(controllerName: string): ClientNetworkController<any>;
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

    Name: string
}

export interface ClientNetworkController<T> {
    Connect(self: ClientNetworkController<T>, func: (data: {T}) => (void)): ScriptConnection;
    Wait(self: ClientNetworkController<T>): {T};
    Once(self: ClientNetworkController<T>, func: (data: {T}) => (void)): ScriptConnection;

    Fire(self: ClientNetworkController<T>, data: (T | {T}) | null): void;
    InvokeAsync(self: ClientNetworkController<T>, data: (T | {T}) | null): {T};

    DisconnectAll(): void
    Name: string;
}

export interface ServerNetworkController<T> {
    Connect(self: ServerNetworkController<T>, func: (sender: Player, data: {T}) => (void)): ScriptConnection;
    Wait(self: ServerNetworkController<T>): [Player, {T}];
    Once(self: ServerNetworkController<T>, func: (data: {T}) => (void)): ScriptConnection;

    Fire(self: ServerNetworkController<T>, recipient: any, data: (T | {T}) | null): void;
    OnInvoke(self: ServerNetworkController<T>, callback: (sender: any, data: {T}) => void): void;

    DisconnectAll(): void
    Name: string;
}

export namespace CanaryEngine {
    export function GetEngineServer(): EngineServer;
	export function GetEngineClient(): EngineClient;

    export function GetPackageServer(): PackageServer;
    export function GetPackageClient(): PackageClient;

	export function CreateSignal(): ScriptSignal<any>;
	export function GetLatestPackageVersionAsync(packageInstance: any, warnIfNotLatestVersion: boolean | null, respectDebugger: boolean | null): number | null;

    const Runtime: {
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

    const Libraries: {
        Utility: any
        Benchmark: any
        Statistics: any
        Serialize: any
    }
	
	let DeveloperMode: boolean
}