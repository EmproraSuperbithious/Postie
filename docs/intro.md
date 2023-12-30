---
sidebar_position: 1
---

# Why Postie?

Issues with calling InvokeClient in a RemoteFunction:
* If the client throws an error, the server throws the error too.
* If the client disconnects while it's being invoked, InvokeClient throws an error.
* If the client doesn't return a value, the server yields forever.

Postie solves all three of these problems by replacing one RemoteFunction invocation with two RemoteEvent firings.