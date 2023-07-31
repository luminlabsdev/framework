-- // Types

--[=[
	A script connection, similar to an [RBXScriptConnection]

	@field Disconnect (self: ScriptConnection) -> ()
	@field Connected boolean

	@interface ScriptConnection
	@within CanaryEngine
	@private
]=]
type ScriptConnection = {
	Disconnect: (self: ScriptConnection) -> (),
	Connected: boolean,
}


--[=[
	A script signal, similar to an [RBXScriptSignal]

	@field Connect (self: ScriptSignalBasic<T>?, func: (data: {T}) -> ()) -> (ScriptConnection)
	@field Wait (self: ScriptSignalBasic<T>?) -> ({T})
	@field Once (self: ScriptSignalBasic<T>?, func: (data: {T}) -> ()) -> (ScriptConnection)
	
	@field Fire (self: ScriptSignal<T>?, data: ({T} | T)?) -> ()
	@field DisconnectAll (self: ScriptSignal<T>?) -> ()
	
	@field Name string

	@interface ScriptSignal
	@within CanaryEngine
	@private
]=]
export type ScriptSignal<T> = {
	Connect: (self: ScriptSignal<T>?, func: (data: {T}) -> ()) -> (ScriptConnection),
	Wait: (self: ScriptSignal<T>?) -> ({T}),
	Once: (self: ScriptSignal<T>?, func: (data: {T}) -> ()) -> (ScriptConnection),

	Fire: (self: ScriptSignal<T>?, data: ({T} | T)?) -> (),
	DisconnectAll: (self: ScriptSignal<T>?) -> (),

	Name: string,
}

--[=[
	A ClientNetworkController is basically a mixed version of a [RemoteEvent] and [RemoteFunction]. It has better features and is more performant.

	@field Connect (self: ClientNetworkController<T, U>?, func: (data: {T}) -> ()) -> (ScriptConnection)
	@field Once (self: ClientNetworkController<T, U>?, func: (data: {T}) -> ()) -> (ScriptConnection)
	@field Wait (self: ClientNetworkController<T, U>?) -> ({T})
	
	@field Fire (self: ClientNetworkController<T, U>?, data: ({T} | T)?) -> ()
	@field InvokeAsync (self: ClientNetworkController<T, U>?, data: ({T} | T)?) -> ({U})

	@field DisconnectAll (self: ClientNetworkController<T, U>?) -> ()
	@field Name string

	@interface ClientNetworkController
	@within CanaryEngine
]=]
export type ClientNetworkController<T, U> = {
	Connect: (self: ClientNetworkController<T, U>?, func: (data: {T}) -> ()) -> (ScriptConnection),
	Wait: (self: ClientNetworkController<T, U>?) -> ({T}),
	Once: (self: ClientNetworkController<T, U>?, func: (data: {T}) -> ()) -> (ScriptConnection),

	Fire: (self: ClientNetworkController<T, U>?, data: ({T} | T)?) -> (),
	InvokeAsync: (self: ClientNetworkController<T, U>?, data: ({T} | T)) -> ({U}),

	DisconnectAll: (self: ClientNetworkController<T, U>?) -> (),
	Name: string,
}

--[=[
	A ServerNetworkController is basically a mixed version of a [RemoteEvent] and [RemoteFunction]. It has better features and is more performant, though this is the server-sided API.

	@field Connect (self: ServerNetworkController<T, U>?, func: (sender: Player, data: {T}) -> ()) -> (ScriptConnection)
	@field Once (self: ServerNetworkController<T, U>?, func: (sender: Player, data: {T}) -> ()) -> (ScriptConnection)
	@field Wait (self: ServerNetworkController<T, U>?) -> (Player, {T})
	
	@field Fire (self: ServerNetworkController<T, U>?, recipient: Player | {Player}, data: ({T} | T)?) -> ()
	@field OnInvoke (self: ServerNetworkController<T, U>?, callback: (sender: Player, data: {T}) -> ()) -> ()
	
	@field SetRateLimit (self: ServerNetworkController<T, U>?, maxInvokesPerSecond: number, invokeOverflowCallback: (sender: Player) -> ()) -> ()
	@field DisconnectAll (self: ServerNetworkController<T, U>?) -> ()
	@field Name string

	@interface ServerNetworkController
	@within CanaryEngine
]=]
export type ServerNetworkController<T, U> = {
	Connect: (self: ServerNetworkController<T, U>?, func: (sender: Player, data: {T}) -> ()) -> (ScriptConnection),
	Wait: (self: ServerNetworkController<T, U>?) -> (Player, {T}),
	Once: (self: ServerNetworkController<T, U>?, func: (sender: Player, data: {T}) -> ()) -> (ScriptConnection),
	
	Fire: (self: ServerNetworkController<T, U>?, recipient: Player | {Player}, data: ({T} | T)?) -> (),
	FireAll: (self: ServerNetworkController<T, U>?, data: ({T} | T)?) -> (),
	FireExcept: (self: ServerNetworkController<T, U>?, except: Player | {Player}, data: ({T} | T)?) -> (),
	OnInvoke: (self: ServerNetworkController<T, U>?, callback: (sender: Player, data: {T}) -> ({U} | U)) -> (),

	SetRateLimit: (self: ServerNetworkController<T, U>?, maxInvokesPerSecond: number, invokeOverflowCallback: (sender: Player) -> ()) -> (),
	DisconnectAll: (self: ServerNetworkController<T, U>?) -> (),
	Name: string,
}