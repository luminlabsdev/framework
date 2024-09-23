export type Controller<T> = {
	Start: (() -> ())?,
	Init: (() -> ())?,
	Uses: { any }?,
} & T

export type Cycle<T...> = {
	Fire: (self: Cycle<T...>, T...) -> (),
	Name: string,
	Listeners: { (...any) -> () },
}

return {}
