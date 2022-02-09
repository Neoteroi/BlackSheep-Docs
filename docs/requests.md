# Requests
This page describes:

- [X] Handling requests.
- [X] Reading parameters from the request.
- [X] Reading request headers and cookies.
- [X] Reading request bodies.

## The Request class
BlackSheep handles requests as instances of `blacksheep.messages.Request`
class. This class provides methods and properties to handle request headers,
cookies, URL, route parameters, request body, user's identity, and other
information like the content type of the request. Each web request results in
the creation of a new instance of `Request`.

### Reading parameters from the request object
It is possible to read query and route parameters from an instance of
`request`. The example below shows how query string, route parameters, and
request headers can be read from the request:

```python
from blacksheep.server import Application
from blacksheep.server.responses import text
from blacksheep.messages import Request, Response


app = Application()
get = app.router.get


@get("/{something}")
def example(request: Request) -> Response:
    client_accept = request.headers.get_first(b"Accept")
    # client_accept is None or bytes

    hello = request.query.get("hello")
    # hello is None or a List[str]

    something = request.route_values["something"]
    # something is str

    return text(
        f"""
        Accept: {client_accept.decode()}
        Hello: {hello}
        Something: {something}
        """
    )
```

However, the recommended approach is to use automatic bindings, which enable a
more accurate generation of OpenAPI Documentation, automatic parsing of values
into the desired type, and improve development experience and source code.

The same example can be achieved in the following way:

```python
from blacksheep.server import Application
from blacksheep.server.responses import text
from blacksheep.messages import Request, Response
from blacksheep.server.bindings import FromHeader, FromQuery


app = Application()
get = app.router.get


class FromAcceptHeader(FromHeader[str]):
    name = "Accept"


@get("/{something}")
def example(
    something: str, accept: FromAcceptHeader, hello: FromQuery[str]
) -> Response:
    return text(
        f"""
        Accept: {accept.value}
        Hello: {hello.value}
        Something: {something}
        """
    )

```

HTTP GET `/example?hello=World`:
```
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,mage/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9
Hello: World
Something: example
```

### Reading request headers and cookies

```python
from blacksheep.server import Application
from blacksheep.server.responses import text
from blacksheep.messages import Response
from blacksheep.server.bindings import FromHeader, FromCookie
from typing import Optional

app = Application()
get = app.router.get


class FromAcceptHeader(FromHeader[str]):
    name = "Accept"


class FromFooCookie(FromCookie[Optional[str]]):
    name = "foo"


@get("/")
def home(accept: FromAcceptHeader, foo: FromFooCookie) -> Response:
    return text(
        f"""
        Accept: {accept.value}
        Foo: {foo.value}
        """
    )
```

### Reading request body
The request class offers several methods to read request bodies of different
kinds.

#### Reading JSON

===  "Using binders (recommended)"

    ```python
    from dataclasses import dataclass

    from blacksheep.server.bindings import FromJSON


    @dataclass
    class SomethingInput:
        name: str
        foo: bool


    @post("/something")
    async def create_something(input: FromJSON[SomethingInput]):
        data = input.value

        # data is already deserialized from JSON into an instance of
        # `SomethingInput`
    ```

    The type parameter for the `FromJSON` binder can be a dataclass, a model from
    [`pydantic`](https://github.com/samuelcolvin/pydantic), a regular class with an
    `__init__` method.

    Note that when mapping the request's payload to an instance of the desired
    type, the type's constructor with `cls(**data)` is used. If it necessary to
    parse dates or other complex types this must be done in the constructor of the
    class. To handle gracefully a payload with extra properties, use `*args` in
    your class constructor: `__init__(one, two, three, *args)__`.

    To read the JSON payload as a regular dictionary, use `dict` as type argument:

    ```python
    @post("/something")
    async def create_something(input: FromJSON[dict]):
        ...
    ```

=== "Directly from the request"

    When the JSON is read from the request object, it is always treated as
    the raw deserialized object (usually a dictionary or a list).

    ```python
    @post("/something")
    async def create_something(request: Request):
        data = await request.json()

        # data is the deserialized object
    ```

#### Reading form

===  "Using binders (recommended)"

    ```python
    from blacksheep.server.bindings import FromForm


    class SomethingInput:
        name: str
        foo: bool

        def __init__(self, name: str, foo: str) -> None:
            self.name = name
            self.foo = bool(foo)


    @post("/something")
    async def create_something(input: FromForm[SomethingInput]):
        data = input.value

        # data is already deserialized from form into an instance of
        # `SomethingInput` - however some properties need to be parsed
        # from str into the desired type in the class definition -
        # see __init__ above
    ```


=== "Directly from the request"

    ```python
    @post("/something")
    async def create_something(request: Request):
        data = await request.form()

        # data is a dictionary
    ```

#### Reading text

===  "Using binders (recommended)"

    ```python
    from blacksheep.server.bindings import FromText


    @post("/something")
    async def store_text(text: FromText):
        data = text.value
    ```

=== "Directly from the request"

    ```python
    @post("/text")
    async def create_text(request: Request):
        data = await request.text()

        # data is a string
    ```

#### Reading raw bytes

===  "Using binders (recommended)"

    ```python
    from blacksheep.server.bindings import FromBytes


    @post("/something")
    async def example(payload: FromBytes):
        data = payload.value
    ```

=== "Directly from the request"

    ```python
    @post("/text")
    async def example(request: Request):
        data = await request.read()

        # data is bytes
    ```

#### Reading files
Files read from `multipart/form-data` payload.

===  "Using binders (recommended)"

    ```python
    from blacksheep.server.bindings import FromFiles


    @post("/something")
    async def post_files(files: FromFiles):
        data = files.value
    ```

=== "Directly from the request"

    ```python
    @post("/upload-files")
    async def upload_files(request: Request):
        files = await request.files()

        for part in files:
            file_bytes = part.data
            file_name = file.file_name.decode()

        ...
    ```

#### Reading streams
Reading streams enables reading bodies of big size using asynchronous
generator. The example below saves a file of arbitrary size without blocking
the event loop:

=== "Directly from the request"

    ```python
    from blacksheep.server.responses import created


    @post("/upload")
    async def save_big_file(request: Request):

        with open("./data/0001.dat", mode="wb") as saved_file:
            async for chunk in request.stream():
                saved_file.write(chunk)

        return created()
    ```
