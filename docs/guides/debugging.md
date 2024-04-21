# Debugging

Debugging is a great feature of LuminFramework. We have provided a debugger packasge which allows you to debug your games with almost no effort required. This does not clutter the output and allows you to easily keep track of logs and other things.

### Logging Events

Logging events is similar to calling the debug function, but a bit different. `LogEvent` does two things differently:

1. Events are only printed to the output in studio
2. Introduces a session logs table which an entry gets added to upon a call

You can actually see this being used internally when creating new signals/networkcontrollers. It is a meant to be used alongside debug, but instead of debugging this will log the event in a table so you can verify it happened via code. This also has it's own dedicated setting called `ShowLoggedEvents`, which if disabled will disable the printing of events regardless of your client type.

### Call Stacks

The debugger has a pretty nice feature of generating clean callstacks. `GetCallStack` returns a table of info pertaining to the callstack of the source, which has been neatly sorted into a couple of keys. These allow you to:

1. Get the exact line number of where the code was called from
2. Get a table of every ancestor from the source
3. Get a string of the full name along with the function name if provided

This is mainly used for testing scenarios and doesn't really have any use outside of that unless you have an internal developer panel of some sort.