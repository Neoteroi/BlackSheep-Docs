# Background tasks
This page describes how to start background tasks in request handlers, and how
to configure background tasks that run periodically during the application's
lifetime.

## How to handle a request in background

The following example shows how to handle a web request in background, which
is the use case for the [HTTP 202 Accepted](https://developer.mozilla.org/en-US/docs/Web/HTTP/Status/202)
response status code.

```python
import asyncio
from blacksheep import Application, Response, accepted

app = Application(show_error_details=True)
get = app.router.get


async def background_work():
    # simulate a delay...
    await asyncio.sleep(1)
    print("Done!")


@get("/")
def home() -> Response:
    # start a task in background
    asyncio.create_task(background_work())

    # note: the server returns a response immediately, so before the conclusion
    # of the background task
    return accepted("Operation accepted")

```

## How to configure background tasks

The following example shows how to configure a background tasks, including
the activation of a service resolved by the DI container, running periodically
once every second:

```python
import asyncio
from datetime import datetime

from blacksheep import Application

app = Application()


@app.route("/")
def home():
    return f"Hello, World! {datetime.utcnow().isoformat()}"


def get_current_timestamp():
    return datetime.utcnow().isoformat()


class Foo:
    def __init__(self) -> None:
        pass


async def task_example(app: Application) -> None:
    # example background task, running once every second,
    # this example also shows how to activate a service using the CI container
    while True:
        print(get_current_timestamp())

        my_foo = app.service_provider.get(Foo)
        assert isinstance(my_foo, Foo)
        print("Foo id: ", id(my_foo))

        await asyncio.sleep(1)


async def configure_background_tasks(app):
    asyncio.get_event_loop().create_task(task_example(app))


app.on_start += configure_background_tasks

app.services.add_exact_scoped(Foo)
```
