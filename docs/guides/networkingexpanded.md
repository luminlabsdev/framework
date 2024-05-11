# Networking Expanded: Why Batching Can Be Both Good and Bad With Solutions

Now what is batching? Batching is what you think it may be; batching all of the data into one remoteevent call. What we're doing behind the scenes is packaging all the data into one remote event call per frame which lowers bandwidth in most cases due to a lot less overhead by remotes. Batching drastically improves networking performance and the difference of using a custom system versus a default system is extremely large.

## Why It Can Be Bad #1 (Unreliables)

In most cases, batching is beneficial but there is one problem with it, and it specifically has to do with unreliable remote events. The problem is that unreliable remote events have a limit of 900 bytes per call whereas normal remotes have a limit that goes into the megabytes. This becomes a problem if we're firing lots of calls per frame and then batching them, as compiled data from lots of these events can quickly exceed the 900 byte limit.

## Why It Can Be Bad #2 (Reliables)

Batching does something unique to the order of how you called your events; the recieving order on the client or server is completely random. This is because we're sending all of this data in the same frame. To combat this issue, we have provided a method called `FireNow` that you can use if you depend on your event being recieved at the same time it was called. (thanks [@lolmanurfunny](https://github.com/lolmanurfunny)!)

## Solutions (Unreliables)

After the thought process, we found the best solution to check if the currently compiled data plus the new data will exceed 840 bytes (extra space for leg room as our packet size checking method is not 100% accurate). If it does, we can simply call the remote again for that frame instead of compiling the data. This way, we still reap the benefits of batching in some ways while also keeping inside of the size limit.