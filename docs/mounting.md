# Mounting applications

The word "mounting" refers to the ability to plug ASGI applications into
others, under specific routes. This enables reusing whole applications, or
components, across web applications. This page describes:

- [X] How to use the mount feature in BlackSheep.
- [X] Details about mounting, and handling of application events.
- [X] An example using [Piccolo Admin](https://github.com/piccolo-orm/piccolo_admin)

## How to use mounts

To mount an application in another application, use the `mount` method:

```python
application_a.mount("/example-path", application_b)
```

Example:

```python
from blacksheep.server import Application

app_a = Application()


@app_a.router.get("/")
def a_home():
    return "Hello, from Application A"


app_b = Application()


@app_b.router.get("/")
def b_home():
    return "Hello, from Application B"


# Note: when mounting another BlackSheep application,
# make sure to handle the start and stop events of the mounted app

@app_b.on_start
async def handle_app_a_start(_):
    await app_a.start()


@app_b.on_stop
async def handle_app_a_stop(_):
    await app_a.stop()


app_b.mount("/a", app_a)

```

In the example above, both `app_a` and `app_b` are complete applications that
can be started independently. If `app_a` is started alone, it replies to GET
web requests at route "/" with the text "Hello, from Application A".

Since `app_b` mounts `app_a` under the path "/a", when `app_b` is started, it
delegates requests to `/a` to the mounted application, therefore when `app_b`
is started, a GET request to the route "/a" produces the greetings message
from `app_a`. A GET request to the route "/" instead is replied with the text
"Hello, from Application B".

!!! info
    Try to create a file `server.py` like in the example above, and run the
    applications using `uvicorn`, to verify how they work in practice.

## Side effects of mounting
Even though mounting can enable interesting scenarios, it comes at a price.

Applications that are supposed to be mounted by other applications need to be
designed to be "mount-friendly", for example when they handle redirects or
links to static files they serve. Absolute paths will not work when used by
applications that are mounted by other applications, while relative paths will
work.

If an application is not designed to be mounted by other applications, it might
create non-obvious side effects.

Consider the following example:

```python
from blacksheep.server import Application
from blacksheep.server.responses import redirect

app_a = Application()


@app_a.router.get("/")
def a_home():
    return "Hello, from Application A"


@app_a.router.get("/test")
def redirect_to_home():
    # Note: app_a defines an absolute path for redirection - this won't work
    # for mounted apps since the intention is most likely to redirect to a path
    # handled by the same application
    return redirect("/")


app_b = Application()


@app_b.router.get("/")
def b_home():
    return "Hello, from Application B"


@app_b.on_start
async def handle_app_a_start(_):
    await app_a.start()


@app_b.on_stop
async def handle_app_a_stop(_):
    await app_a.stop()


app_b.mount("/a", app_a)

```

This won't produce the expected result in real-life scenarios! `app_a` in this
case redirects to the absolute path "/", therefore a path that is handled by
`app_b`! In general, mounted apps will be defined in dedicated packages with
no knowledge of the applications that mount them. To fix this scenario, it is
necessary to use a relative path for redirection, like:

```python
@app_a.router.get("/test")
def redirect_to_home():
    return redirect("./")
```

### Handling of application events
Applications often need to define actions that must happen when the application
starts, and actions that must happen when the application stops.

ASGI web frameworks handle lifecycle events when they get dedicated messages
from the underlying ASGI server (`lifespan` messages), notifying the ASGI
server when initialization logic has completed. However, when an application is
mounted into another, it is not responsible of handling `lifespan` messages.

When mounted apps define initialization and shutdown logic, the application
that mounts them must register their initialization and shutdown functions as
part of its own events.

BlackSheep applications must always be started to work properly. This is
achieved, like in the examples above, registering `on_start` and `on_stop`
event handlers in the mounting app, to handle the lifecycle of the mounted app.

```python
@app_b.on_start
async def handle_app_a_start(_):
    await app_a.start()


@app_b.on_stop
async def handle_app_a_stop(_):
    await app_a.stop()


app_b.mount("/a", app_a)
```

This ensures that when the main application handles `lifespan` messages from
the ASGI HTTP Server, the mounted app is also notified properly of those
events.

!!! info
    The way the mounted app must be started and stopped depend on the
    web framework used to implement it. The example above is correct when `app_a`
    is an instance of BlackSheep Application.

## Examples
To see a working example where `mount` is used, see [the Piccolo Admin example
at
_BlackSheep-Examples_](https://github.com/Neoteroi/BlackSheep-Examples/tree/main/piccolo-admin).

In this example, [Piccolo Admin](https://github.com/piccolo-orm/piccolo_admin)
is configured as mounted app under "/admin" route, providing a UI to handle
data stored in a `SQLite` database.
