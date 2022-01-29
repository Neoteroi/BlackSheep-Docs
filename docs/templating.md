Server side templating refers to the ability of a web application to generate
HTML pages from templates and dynamic variables. BlackSheep does this using the
wondeful [`Jinja2` library](https://palletsprojects.com/p/jinja/) by the
[Pallets](https://palletsprojects.com) team.

This page describes:

<div class="check-list"></div>
* How to configure server side templating.
* Returning views using [response functions]().
* Returning views using the [MVC features]().

> **Note:** the [BlackSheep MVC project
> template](https://github.com/RobertoPrevato/BlackSheepMVC) includes a
> ready-to-use solution having an application with templates and layout
> configured.

## Configuration
This example shows how to use Jinja2 templating engine with BlackSheep:

```python
from blacksheep.server import Application
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
from blacksheep.server import Application
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
