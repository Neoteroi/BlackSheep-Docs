[![Main](https://github.com/Neoteroi/BlackSheep-Docs/actions/workflows/main.yml/badge.svg)](https://github.com/Neoteroi/BlackSheep-Docs/actions/workflows/main.yml)

# BlackSheep documentation 📜
This repository contains the source code of the documentation that gets
published to [https://www.neoteroi.dev/blacksheep/](https://www.neoteroi.dev/blacksheep/).

This code has been previously hosted in [Azure DevOps](https://dev.azure.com/robertoprevato/BlackSheep).

## How to contribute

The documentation uses MkDocs. For information on how to use MkDocs, refer to its
documentation.

```bash
$ mkdocs serve
```

### Environments

Documentation can be deployed to a DEV environment (this happens when a release is
created from a branch different than `main`), or a PROD environment, when a release is
created from the `main` branch.

* [DEV](https://neoteroideveuwstacc.z6.web.core.windows.net/blacksheep/)
* [PROD](https://www.neoteroi.dev/blacksheep/)

The documentation for `blacksheep` is published under the path `/blacksheep/`
because the same service will be used to serve documentation for other projects,
like `rodi`.
