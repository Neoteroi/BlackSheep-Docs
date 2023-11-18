# HTTP Client

BlackSheep includes an implementation of HTTP Client for HTTP 1.1.

## Client features

- HTTP connection pooling
- User friendly handling of SSL contexts (safe by default)
- Support for client side middlewares
- Automatic handling of redirects (can be disabled, validates circular
  redirects and maximum number of redirects - redirects to URN are simply
  returned to code using the client)
- Automatic handling of cookies (can be disabled, `Set-Cookie` and `Cookie`
  headers)

**Example:**
```python
import asyncio
from blacksheep.client import ClientSession


async def client_example(loop):
    async with ClientSession() as client:
        response = await client.get("https://docs.python.org/3/")

        assert response is not None
        text = await response.text()
        print(text)


loop = asyncio.get_event_loop()
loop.run_until_complete(client_example(loop))

```

## HTTP Connection pooling

The HTTP client in BlackSheep implements connection pooling. Meaning that
connections to the same host and port are kept in memory and reused for
different request-response cycles, when possible. By default, connections are
not disposed as long as they are kept open.

Implementation:
[/blacksheep/client/pool.py](https://github.com/RobertoPrevato/BlackSheep/blob/master/blacksheep/client/pool.py).

Connections are created using `asyncio` function `loop.create_connection`.

## Client middlewares

The HTTP Client supports middlewares. Middlewares on the server are functions
that are executed in order, at every request-response cycle and enable
manipulation of incoming requests and outgoing responses. Middlewares support
interruption of the chain: that is, returning an HTTP response without firing
all handlers in the chain, for example to return HTTP 401 Unauthorized when
applying an authentication strategy. The HTTP client can benefit from the same
design pattern, and this is supported in BlackSheep.

## Client middleware example

```python
async def client_example_middleware(request, next_handler):

    # do something before the request is sent
    response = await next_handler(request)

    # do something with the response from remote server
    return response

client = ClientSession()
client.middlewares.append(client_example_middleware)
client.configure()
```

## Considerations about the ClientSession class
To make the client more user-friendly, default connection pools are reused by
loop id. This is to prevent users from killing the performance of their
applications simply by instantiating many times `ClientSession` (for example,
at every web request).

However, it is recommended to instantiate a single instance of HTTP client and
register it as service of the application:

```python

async def configure_http_client(app):
    http_client = ClientSession()
    app.services.add_instance(http_client)  # register a singleton

app.on_start += configure_http_client

async def dispose_http_client(app):
    http_client = app.service_provider.get(ClientSession)
    await http_client.close()

app.on_stop += dispose_http_client

```

When following this approach, the http client can be automatically injected to
request handlers, and services that need it, like in this example:

```python
from blacksheep import get, html


@get("/get-python-homepage")
async def get_python_homepage(http_client):
    response = await http_client.get("https://docs.python.org/3/")

    assert response is not None
    data = await response.text()
    return html(data)
```

Otherwise, instantiate a single connection pools and use it across several
instances of HTTP clients:

```python
from blacksheep.client import ClientSession
from blacksheep.client.pool import ClientConnectionPools


async def client_pools():
    # instantiate a single instance of pools
    pools = ClientConnectionPools(loop)  # loop is an asyncio loop

    # instantiate clients using the same pools
    client_one = ClientSession(pools=pools)

    client_two = ClientSession(pools=pools)

    client_three = ClientSession(pools=pools)

    await pools.close()
```

!!! danger "Dispose ClientConnectionPools"
    When
