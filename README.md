# plone-backend

Plone backend [Docker](https://docker.com) images using Python 3 and [pip](https://pip.pypa.io/en/stable/).

> **NOTE**: These images are not yet officially supported by the Plone Community.

## Supported tags and respective Dockerfile links

- `6.0-dev, 6.0-dev-python39` [(6.0/6.0-dev/Dockerfile.python39)](https://github.com/plone/plone-backend/blob/main/6.0/6.0-dev/Dockerfile.python39)
- `6.0-dev-python38` [(6.0/6.0-dev/Dockerfile.python38)](https://github.com/plone/plone-backend/blob/main/6.0/6.0-dev/Dockerfile.python38)
- `6.0-dev-python37` [(6.0/6.0-dev/Dockerfile.python37)](https://github.com/plone/plone-backend/blob/main/6.0/6.0-dev/Dockerfile.python37)

## Using this image

### Simple usage

```shell
docker run -p 8080:8080 plone/plone-backend:6.0-dev
```

Then point your browser at http://localhost:8080 and you should see the default Plone site creation page.

### ZEO Server

This image supports ZEO clusters natively, and to use it 

Create a directory for your project, and inside it create a `docker-compose.yml` file that starts your Plone instance and the ZEO instance with volume mounts for data persistence:

```yaml
version: "3"
services:

  backend:
    image: plone/plone-backend:6.0-dev
    restart: always
    environment:
      USE_ZEO: 1    
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

Now, run `docker-compose up -d` from your project directory.

Point your browser at http://localhost:8080 and you should see the default Plone site creation page.


### Persisting data 

There are several ways to store data used by applications that run in Docker containers.

We encourage users of the `Plone` images to familiarize themselves with the options available.

[The Docker documentation](https://docs.docker.com/) is a good starting point for understanding the different storage options and variations.


## Extending from this image

In a directory create a  `Dockerfile` file:
```Dockerfile
FROM plone/plone-backend:6.0-dev

RUN ./bin/pip install "relstorage==3.4.5" "psycopg[binary]==3.0.1 --use-deprecated legacy-resolver"
```

Also create a `requirements.txt` file, with packages to be installed:
```
relstorage==3.4.5
psycopg[binary]==3.0.1
```

Build your new image

```shell
docker build . -t myproject:latest -f Dockerfile
```

And start a container with
```shell
docker run -p 8080:8080 myproject:latest
```

## Contribute

- [Issue Tracker](https://github.com/plone/plone-backend/issues)
- [Source Code](https://github.com/plone/plone-backend/)
- [Documentation](https://github.com/plone/plone-backend/tree/main/docs)

Please **DO NOT** commit to main directly. Even for the smallest and most trivial fix.
**ALWAYS** open a pull request and ask somebody else to merge your code. **NEVER** merge it yourself.


## License

The project is licensed under the GPLv2.
