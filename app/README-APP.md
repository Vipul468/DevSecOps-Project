# App source (Amazon Prime clone)

This folder holds the **containerisation files** for the app (Dockerfile + nginx.conf).
The actual React/Vite source code of the Amazon Prime clone is NOT bundled here —
you clone it into this folder.

## Get the app source

The popular tutorial uses this open-source clone. Clone it INTO this `app/` folder
so that `package.json` sits next to the `Dockerfile`:

```bash
cd app
# example public clone used by the DevOps Project-2 tutorial:
git clone https://github.com/N4si/DevSecOps-Project.git .
# (any React/Vite "prime video clone" repo works; it must have package.json + `npm run build` -> dist/)
```

After cloning you should have:

```
app/
├── Dockerfile        <- provided by this scaffold
├── nginx.conf        <- provided by this scaffold
├── package.json      <- from the cloned app
├── src/              <- from the cloned app
└── ...
```

## Build & run locally (smoke test)

```bash
cd app
docker build --build-arg TMDB_V3_API_KEY=<your_tmdb_key> -t prime-clone:local .
docker run --rm -p 8080:80 prime-clone:local
# open http://localhost:8080
```

Get a free TMDB API key at https://www.themoviedb.org/settings/api (the clone
uses it to list movies).
