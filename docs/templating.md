# Server Side Rendering (SSR)

Server side templating refers to the ability of a web application to generate
HTML pages from templates and dynamic variables. BlackSheep does this using the
wondeful [`Jinja2` library](https://palletsprojects.com/p/jinja/) by the
[Pallets](https://palletsprojects.com) team.

This page describes:

- [X] How to configure server side templating.
- [X] Returning views using response functions.
- [X] Returning views using the MVC features.

!!! info
    The [BlackSheep MVC project
    template](https://github.com/RobertoPrevato/BlackSheepMVC) includes a
    ready-to-use solution having an application with templates and layout
    configured.

## Configuration
This example shows how to use Jinja2 templating engine with BlackSheep:

```python
from blacksheep import Application
from blacksheep.server.templating import use_templates
from jinja2 import PackageLoader

app = Application(show_error_details=True, debug=True)
get = app.router.get

# NB: this example requires a package called "app";
# containing a 'templates' folder
# The server file must be in the same folder that contains "app"
view = use_templates(app, loader=PackageLoader("app", "templates"))


@get("/")
def home():
    return view("home", {"example": "Hello", "foo": "World"})

```

The expected folder structure for this example:
```
⬑ app
     ⬑ templates
          home.html   <-- template file loaded by `view` function
     __init__.py

server.py
```

```html
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <meta name="description" content="Example.">
</head>
<body>
  <h1>{{example}}</h1>
  <p>{{foo}}</p>
</body>
</html>
```

If the `use_templates` function is called more than once, the Jinja2
environment is configured only once, but new `view` functions are returned. It
is recommended to keep this setup in a single file, and import the `view`
function in files that define routes for the application.

## Async mode

It is possible to enable Jinja2 [async
mode](http://jinja.pocoo.org/docs/2.10/api/#async-support), using the parameter
`enable_async`. When `enable_async` is true, the function returned by
`use_templates` is asynchronous:

```python
from blacksheep import Application
from blacksheep.server.templating import use_templates
from jinja2 import PackageLoader

app = Application(show_error_details=True, debug=True)
get = app.router.get

# NB: this example requires a package called "app";
# containing a 'templates' folder
# The server file must be in the same folder that contains "app"
view = use_templates(app, loader=PackageLoader("app", "templates"), enable_async=True)


@get("/")
async def home():
    return await view("home", {"example": "Hello", "foo": "World"})

```

## Loading templates

It is possible to load templates by name including '.html', or without file
extension; '.html' extension is added automatically. Extension must be lower
case.

```python
@get("/")
async def home(request):
    return view("home.html", {"example": "Hello", "foo": "World"})


# or...


@get("/")
async def home(request):
    return view("home", {"example": "Hello", "foo": "World"})
```

## Helpers and filters

To configure custom helpers and filters for Jinja, it is possible to access
its `Environment` using the `templates_environment` property of the application,
once server side templating is configured.

```
.
├── app
│   ├── __init__.py
│   └── views
│       └── index.html
└── server.py
```

```python
# server.py
from blacksheep import Application
from blacksheep.server.templating import use_templates
from jinja2 import PackageLoader, Environment

app = Application(show_error_details=True)

view = use_templates(app, PackageLoader("app", "views"))


def example():
    return "This is an example"


app.templates_environment.globals.update({"my_function": example})  # <<<


@app.route("/")
async def home():
    return view("index.html", {})
```

```html
<!-- index.html -->
<p>Hello, World!</p>
{{ my_function() }}
```
