---
sidebar_position: 1 
---

# Why Postie

## Issues with RemoteFunctions

Postie aims to solve a few issues with calling InvokeClient in a RemoteFunction:
* If the client throws an error, the server will throw an error too.
* If the client disconnects while it's being invoked, InvokeClient throws an error.
* If the client doesn't return a value, the server will yield forever.

Postie solves all three of these problems by replacing RemoteFunctions with RemoteEvents. 

## Simple and Friendly API

Postie's API is small and very similar to RemoteFunctions. You won't need to
remember much to work with this library. 
