To develop locally with HTTPS using a trusted certificate, a possible solution
is to generate a root CA, and a certificate for `localhost` using
[https://github.com/jsha/minica](minica), as recommended by [Let's
Encrypt](https://letsencrypt.org/docs/certificates-for-localhost/).

> If you want a little more realism in your development certificates, you can
> use minica to generate your own local root certificate, and issue end-entity
> (aka leaf) certificates signed by it. You would then import the root
> certificate rather than a self-signed end-entity certificate.

Summary:

1. install [Go](https://golang.org/doc/install)
2. clone the GitHub repository of [minica](https://github.com/jsha/minica)
3. `cd` into the repository's folder and build minica using `go build` as
   described in [in `minica`
   README](https://github.com/jsha/minica#installation)
4. create certificates for `localhost` using the command below

```bash
./minica --domains localhost
```

The output from the `minica` repository look like this (under the folder
`localhost`):

```
.
├── go.mod
├── LICENSE.txt
├── localhost
│   ├── cert.pem
│   └── key.pem
├── main.go
├── minica
├── minica-key.pem
├── minica.pem
└── README.md
```

Then:

5. Configure `minica.pem` root certificate as trusted certificate in the system
   (see instructions below for Linux and Windows)
6. Run your server using `key.pem` and `cert.pem` generated for localhost

---

### How to configure minica trusted CA

#### Under Linux

Configure the given `minica.pem` as trusted CA Authority for your PC. To do so,
install for example `certutil` package, and then use:

```bash
certutil -d sql:$HOME/.pki/nssdb -A -t "P,," -n "minica root" -i minica.pem
```

To list existing certificates with `certutil`:
```bash
# list certificates
certutil -L -d sql:${HOME}/.pki/nssdb
```

---

#### Under Windows

Use `openssl` to generate a PFX file, from the files generated by `minica`,
using the command below:

```bash
# Note: this command prompts for a password
openssl pkcs12 -inkey minica-key.pem -in minica.pem -export -out minica.pfx
```

Configure the generated PFX as trusted CA Authority for your PC. To do so,
click on the `.pfx` file, and follow the wizard to import the certificate as
Trusted Root Certificate for your machine.

---

Finally, to run using an SSL certificate trusted in the system, for example
with `uvicorn`:

```bash
uvicorn server:app --reload --ssl-keyfile ./key.pem --ssl-certfile ./cert.pem
```

Where `key.pem` and `cert.pem` are the files generated for `localhost`. The
development server can now be used at `https://localhost`. Note:
`https://127.0.0.1` won't work in this case.
