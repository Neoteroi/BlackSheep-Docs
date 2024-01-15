# Server-Sent Events

[**Server-Sent Events**](https://developer.mozilla.org/en-US/docs/Web/API/Server-sent_events) (SSE) enable creating a persistent, one-way connection between a client and a server.
When using SSE, a client can receive automatic updates from a server via an HTTP
connection.

BlackSheep implements built-in support for server-side events since version
`2.0.6`, offering features to simplify their use. This page describes how to
use the built-in features for server-sent events.

!!! tip
    Older versions of the web framework can also be configured to use SSE,
    because they already supported response streaming. But this requires
    writing functions that generate the right bytes sequences.

## Defining a server-sent events route

The following example describes the base elements to configure a route for
server-sent events:

```python
import asyncio
from collections.abc import AsyncIterable

from blacksheep import Application, get
from blacksheep.server.sse import ServerSentEvent

app = Application()


# A request handler defined as async generator yielding ServerSentEvent...
@get("/events")
def events_handler() -> AsyncIterable[ServerSentEvent]:
    for i in range(3):
        yield ServerSentEvent({"message": f"Hello World {i}"})
        await asyncio.sleep(1)
```

1. Import `ServerSentEvent` from `blacksheep.server.sse`.
2. Import `AsyncIterable` from `collections.abc`, or from `typing` if support for Python 3.8 is desired.
3. Define an asynchronous generator with a return type annotation of `AsyncIterable[ServerSentEvent]`.
4. Register a request handler that returns a `ServerEventsResponse` bound to
   the asynchronous generator. This kind of response returns a specialized type
   of `StreamedContent` that streams events information to the client.

In this case the return type annotation is mandatory because the request
handler is automatically normalized by BlackSheep.

## Defining a server-sent events route controlling the Response object

To define a server-sent events route and maintain control of the `Response`
object, refer to the following example:

```python
import asyncio
from collections.abc import AsyncIterable

from blacksheep import Application, get
from blacksheep.server.sse import ServerSentEvent, ServerEventsResponse

app = Application()


# An AsyncGenerator yielding ServerSentEvent...
async def events_provider() -> AsyncIterable[ServerSentEvent]:
    for i in range(3):
        yield ServerSentEvent({"message": f"Hello World {i}"})
        await asyncio.sleep(1)


# A request handler returning a streaming response bound to the generator...
@get("/events")
def events_handler():
    return ServerEventsResponse(events_provider)
```

In this case the return type annotation is optional.

## The ServerSentEvent class

| Property  | Description                                                                                     |
| --------- | ----------------------------------------------------------------------------------------------- |
| `data`    | An object that will be transmitted to the client, in JSON.                                      |
| `event`   | Optional event type name.                                                                       |
| `id`      | Optional event ID to set the EventSource's last event ID value.                                 |
| `retry`   | Optional reconnection delay time, in milliseconds, when a the connection to the server is lost. |
| `comment` | Optional comment.                                                                               |

For more information on events properties, please refer to the [MDN documentation](https://developer.mozilla.org/en-US/docs/Web/API/Server-sent_events/Using_server-sent_events).

## Handling client disconnections and application shutdown

When using a technique that relies on persistent HTTP connections, it is
generally necessary to handle:

- client disconnections, to stop handling requests that were disconnected.
- application shutdown gracefully, to close pending connections.

To check if a request is disconnected, use the `request.is_disconnected()`
method where appropriate.

To check if the server process is shutting down, use the `is_stopping` function
from `blacksheep.server.application`.

```python
from blacksheep.server.application import is_stopping
```

The following example demonstrates a basic usage of both features:

```python
import asyncio
from collections.abc import AsyncIterable

from blacksheep import Application, Request, get
from blacksheep.server.application import is_stopping
from blacksheep.server.sse import ServerSentEvent

app = Application(show_error_details=True)
app.serve_files("static")


@get("/events")
async def events_handler(request: Request) -> AsyncIterable[ServerSentEvent]:
    i = 0

    while True:
        if await request.is_disconnected():
            print("The request is disconnected!")
            break

        if is_stopping():
            print("The application is stopping!")
            break

        i += 1
        yield ServerSentEvent({"message": f"Hello World {i}"})

        try:
            await asyncio.sleep(1)
        except asyncio.exceptions.CancelledError:
            break
```

Note how `functools.partial` is used in the example above.

## Example in GitHub

Refer to the [server-sent events example](https://github.com/Neoteroi/BlackSheep-Examples/tree/main/server-sent-events) for an example that handles application shutdown and client
disconnections, and also presents a basic example in JavaScript to use SSE.

## Related technologies

Server-sent events are often related to WebSockets, which instead enable
bi-directional communication between a server and a client, and to
[long-polling](https://github.com/Neoteroi/BlackSheep-Examples/tree/main/long-polling),
which is often used as a fall-back when SSE or WebSockets are not supported.
