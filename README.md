# plone-backend

Plone backend [Docker](https://docker.com) images using Python 3 and [pip](https://pip.pypa.io/en/stable/).

> **NOTE**: These images are not yet officially supported by the Plone Community.

## Supported tags and respective Dockerfile links

### Plone 5.2 (Stable Plone)

- `latest, 5.2, 5.2.6, 5.2.6-python38` [(5.2/5.2.6/Dockerfile.python38)](https://github.com/plone/plone-backend/blob/main/5.2/5.2.6/Dockerfile.python38)
- `5.2.6-python37` [(5.2/5.2.6/Dockerfile.python37)](https://github.com/plone/plone-backend/blob/main/5.2/5.2.6/Dockerfile.python37)
- `5.2.6-python36` [(5.2/5.2.6/Dockerfile.python36)](https://github.com/plone/plone-backend/blob/main/5.2/5.2.6/Dockerfile.python36)

### Plone 6 (Next Plone Release)

- `6.0.0a1, 6.0.0a1-python39` [(6.0/6.0.0a1/Dockerfile.python39)](https://github.com/plone/plone-backend/blob/main/6.0/6.0.0a1/Dockerfile.python39)
- `6.0.0a1-python38` [(6.0/6.0.0a1/Dockerfile.python38)](https://github.com/plone/plone-backend/blob/main/6.0/6.0.0a1/Dockerfile.python38)
- `6.0.0a1-python37` [(6.0/6.0.0a1/Dockerfile.python37)](https://github.com/plone/plone-backend/blob/main/6.0/6.0.0a1/Dockerfile.python37)
- `6.0-dev, 6.0-dev-python39` [(6.0/6.0-dev/Dockerfile.python39)](https://github.com/plone/plone-backend/blob/main/6.0/6.0-dev/Dockerfile.python39)
- `6.0-dev-python38` [(6.0/6.0-dev/Dockerfile.python38)](https://github.com/plone/plone-backend/blob/main/6.0/6.0-dev/Dockerfile.python38)
- `6.0-dev-python37` [(6.0/6.0-dev/Dockerfile.python37)](https://github.com/plone/plone-backend/blob/main/6.0/6.0-dev/Dockerfile.python37)

## Using this image

### Simple usage

```shell
docker run -p 8080:8080 plone/plone-backend:6.0.0a1 start
```

Then point your browser at http://localhost:8080 and you should see the default Plone site creation page.

### ZEO Server

This image supports ZEO clusters natively, and to use it

Create a directory for your project, and inside it create a `docker-compose.yml` file that starts your Plone instance and the ZEO instance with volume mounts for data persistence:

```yaml
version: "3"
services:

  lb:
    image: plone/plone-haproxy
    depends_on:
    - backend
    ports:
    - "8080:8080"
    - "1936:1936"
    environment:
      FRONTEND_PORT: "8080"
      BACKENDS: "backend"
      BACKENDS_PORT: "8080"
      DNS_ENABLED: "True"
      HTTPCHK: "GET /"
      INTER: "5s"
      LOG_LEVEL: "info"

  backend:
    image: plone/plone-backend:6.0.0a1
    restart: always
    environment:
      ZEO_ADDRESS: zeo:8100
    ports:
    - "8080"
    depends_on:
      - zeo

  zeo:
    image: plone/plone-zeo:latest
    restart: always
    volumes:
      - data:/data
    ports:
    - "8100"

volumes:
  data: {}
```

Now, run `docker-compose up -d --scale backend=4` from your project directory.

Point your browser at http://localhost:8080 and you should see the default Plone site creation page.


### Persisting data

There are several ways to store data used by applications that run in Docker containers.

We encourage users of the `Plone` images to familiarize themselves with the options available.

[The Docker documentation](https://docs.docker.com/) is a good starting point for understanding the different storage options and variations.


## Extending from this image

In a directory create a  `Dockerfile` file:
```Dockerfile
FROM plone/plone-backend:6.0.0a1

RUN ./bin/pip install "relstorage==3.4.5" "psycopg[binary]==3.0.1 --use-deprecated legacy-resolver"
```

Also create a `requirements.txt` file, with packages to be installed:
```
pas.plugin.authomatic
```

Build your new image

```shell
docker build . -t myproject:latest -f Dockerfile
```

And start a container with
```shell
docker run -p 8080:8080 myproject:latest start
```

## Configuration Variables

### Addons installation

It is possible to install, during startup time, addons in a container created using this image. To do so, pass the **ADDONS** environment variable with a list (separated by space) of requirements to be added to the image:

```shell
docker run -p 8080:8080 -e ADDONS="pas.plugins.authomatic" plone/plone-backend:6.0.0a1 start
```

This approach also allows you to test Plone with a specific version of one of its core components

```shell
docker run -p 8080:8080 -e ADDONS="plone.volto==3.1.0a3" plone/plone-backend:6.0.0a1 start
```

> **NOTE**: We advise against using this feature on production environments. In this case, extend the image as explained before.

### Developing packages

It is possible to install local packages instead of packages from pip. To do so, pass the **DEVELOP** environment variable with a list (separated by space) of paths to python packages to be installed.
Those packages will be installed with ``pip install --editable``.


```shell
docker run -p 8080:8080 -e DEVELOP="/app/src/mysite.policy" plone/plone-backend:6.0.0a1 start
```

This approach also allows you to develop local packages by using a volume

```shell
docker run -p 8080:8080 -e DEVELOP="/app/src/mysite.policy" -v /path/to/mysite.policy:/app/src/mysite.policy plone/plone-backend:6.0.0a1 start
```

> **NOTE**: We advise against using this feature on production environments.


### Site creation

It is possible to initialize your database with a Plone Site instance on first run. To do so, pass the **SITE** environment variable with the name of the Plone Site instance, e.g.: **SITE=Plone**. This will add a Volto ready Plone site. If you want a Plone classic instance, pass also **TYPE=classic** environment variable. To initialize it with additional profiles, just pass them, space separated, via **PROFILES** environment variable, e.g.: **PROFILES=eea.api.layout:default**. To recreate the Plone site on container restart you can pass the **DELETE_EXISTING** environment.

Plone 6 example:

```shell
docker run -p 8080:8080 -e ADDONS="eea.api.layout" -e SITE="Plone" -e PROFILES="eea.api.layout:default" plone/plone-backend:6.0.0a1
```

Plone 6 Classic example:

```shell
docker run -p 8080:8080 -e ADDONS="eea.facetednavigation" -e SITE="Plone" -e TYPE="classic" -e PROFILES="eea.facetednavigation:default" plone/plone-backend:6.0.0a1
```

> **NOTE**: We advise against using this feature on production environments.

### Main variables

| Environment variable                      | Zope option                    | Default value                   |
| ----------------------------------------- | ------------------------------ | ------------------------------- |
| DEBUG_MODE                                | debug-mode                     | off                             |
| SECURITY_POLICY_IMPLEMENTATION            | security-policy-implementation | C                               |
| VERBOSE_SECURITY                          | verbose-security               | false                           |
| DEFAULT_ZPUBLISHER_ENCODING               | default-zpublisher-encoding    | utf-8                           |


### ZEO

To use a ZEO database, you need to pass the **ZEO_ADDRESS** to the image:

```yaml
version: "3"
services:

  backend:
    image: plone/plone-backend:6.0.0a1
    restart: always
    environment:
      ZEO_ADDRESS: zeo:8100
    ports:
    - "8080:8080"
    depends_on:
      - zeo

  zeo:
    image: plone/plone-zeo:latest
    restart: always
    volumes:
      - data:/data
    ports:
    - "8100:8100"

volumes:
  data: {}
```

A list of supported environment variables for ZEO:

| Environment variable                      | ZEO option                     | Default value                   |
| ----------------------------------------- | ------------------------------ | ------------------------------- |
| ZEO_SHARED_BLOB_DIR                       | name                           | off                             |
| ZEO_READ_ONLY                             | read-only                      | false                           |
| ZEO_CLIENT_READ_ONLY_FALLBACK             | read-only-fallback             | false                           |
| ZEO_STORAGE                               | storage                        | 1                               |
| ZEO_CLIENT_CACHE_SIZE                     | cache-size                     | 128MB                           |
| ZEO_DROP_CACHE_RATHER_VERIFY              | drop-cache-rather-verify       | false                           |


### Relational Database

> **NOTE**: Currently this image supports only the configuration of PostgreSQL backends via configuration variables. If you need to you MySQL or Oracle we recommend you to extend this image and overwrite the `/app/etc/relstorage.conf` file.

To use a PostgreSQL database, you need to pass the **RELSTORAGE_DSN** to the image:

```yaml
version: "3"
services:

  backend:
    image: plone/plone-backend:6.0.0a1
    environment:
      RELSTORAGE_DSN: "dbname='plone' user='plone' host='db' password='plone'"
    ports:
    - "8080:8080"
    depends_on:
      - db

  db:
    image: postgres
    environment:
      POSTGRES_USER: plone
      POSTGRES_PASSWORD: plone
      POSTGRES_DB: plone
    ports:
    - "5432:5432"

```

A valid PostgreSQL DSN is a list of parameters separated with whitespace. A typical DSN looks like ```dbname='zodb' user='username' host='localhost' password='pass'```.

A list of supported environment variables for Relstorage:

| Environment variable                      | RelStorage option              | Default value                   |
| ----------------------------------------- | ------------------------------ | ------------------------------- |
| RELSTORAGE_NAME                           | name                           | storage                         |
| RELSTORAGE_READ_ONLY                      | read-only                      | off                             |
| RELSTORAGE_KEEP_HISTORY                   | keep-history                   | true                            |
| RELSTORAGE_COMMIT_LOCK_TIMEOUT            | commit-lock-timeout            | 30                              |
| RELSTORAGE_CREATE_SCHEMA                  | create-schema                  | true                            |
| RELSTORAGE_SHARED_BLOB_DIR                | shared-blob-dir                | false                           |
| RELSTORAGE_BLOB_CACHE_SIZE                | blob-cache-size                | 100mb                           |
| RELSTORAGE_BLOB_CACHE_SIZE_CHECK          | blob-cache-size-check          | 10                              |
| RELSTORAGE_BLOB_CACHE_SIZE_CHECK_EXTERNAL | blob-cache-size-check-external | false                           |
| RELSTORAGE_BLOB_CHUNK_SIZE                | blob-chunk-size                | 1048576                         |
| RELSTORAGE_CACHE_LOCAL_MB                 | cache-local-mb                 | 10                              |
| RELSTORAGE_CACHE_LOCAL_OBJECT_MAX         | cache-local-object-max         | 16384                           |
| RELSTORAGE_CACHE_LOCAL_COMPRESSION        | cache-local-compressione       | none                            |
| RELSTORAGE_CACHE_DELTA_SIZE_LIMIT         | cache-delta-size-limit         | 100000                          |


## Contribute

- [Issue Tracker](https://github.com/plone/plone-backend/issues)
- [Source Code](https://github.com/plone/plone-backend/)
- [Documentation](https://github.com/plone/plone-backend/tree/main/docs)

Please **DO NOT** commit to main directly. Even for the smallest and most trivial fix.
**ALWAYS** open a pull request and ask somebody else to merge your code. **NEVER** merge it yourself.


## License

The project is licensed under the GPLv2.
