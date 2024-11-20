export type Controller<T> = {
	Start: (() -> ())?,
	Init: (() -> ())?,
	Uses: { any }?,
} & T

export type Lifecycle<T...> = {
	Fire: (self: Lifecycle<T...>, T...) -> (),
	Name: string,
	Listeners: { (...any) -> () },
}

return {}
