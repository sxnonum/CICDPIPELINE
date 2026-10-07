# CI/CD Pipeline – GitHub Actions + Docker

[![CI](https://github.com/sxnonum/CICDPIPELINE/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/sxnonum/CICDPIPELINE/actions/workflows/ci.yml) [![Security](https://github.com/sxnonum/CICDPIPELINE/actions/workflows/security.yml/badge.svg?branch=main&event=push)](https://github.com/sxnonum/CICDPIPELINE/actions/workflows/security.yml) [![CD](https://github.com/sxnonum/CICDPIPELINE/actions/workflows/deploy.yml/badge.svg?branch=main&event=push)](https://github.com/sxnonum/CICDPIPELINE/actions/workflows/deploy.yml)


En pipeline som automatiskt testar, bygger och levererar en liten Node.js-app som Docker-image.
Appen är medvetet enkel (inga beroenden) – fokus ligger på automatiseringen.

## Pipeline

```
PR / push (andra branscher)         push till main
        │                                  │
   ┌────▼────┐                        ┌────▼────┐
   │  Test   │                        │  Test   │
   └────┬────┘                        └────┬────┘
┌───────▼────────┐                  ┌──────▼───────┐
│ Docker build + │                  │ Build & push │──► ghcr.io (latest + commit-SHA)
│ smoke test     │                  └──────┬───────┘
└────────────────┘                  ┌──────▼───────┐
                                    │ Deploy (SSH) │  valfritt
                                    └──────────────┘
```

| Workflow | Trigger | Vad den gör |
|---|---|---|
| [`ci.yml`](.github/workflows/ci.yml) | PR, push till andra branscher än `main` | Kör tester, bygger imagen och startar containern för ett smoke test mot `/health` |
| [`security.yml`](.github/workflows/security.yml) | PR, push till `main`, varje måndag | CodeQL-analys av koden och Trivy-skanning av Docker-imagen (CRITICAL/HIGH) |
| [`deploy.yml`](.github/workflows/deploy.yml) | push till `main` | Kör tester, publicerar imagen till GitHub Container Registry, deployar via SSH om `DEPLOY_ENABLED=true` |

## Tekniska val
- **Tester** med inbyggda `node:test` – inga extra beroenden, snabb pipeline.
- **Docker**: `node:24-alpine` (npm borttaget ur runtime-imagen), körs som icke-root-användare, har `HEALTHCHECK`.
- **Spårbarhet**: varje image taggas med commit-SHA och får den som `APP_VERSION` (syns på `/`).
- **Säkerhet**: CodeQL + Trivy i pipelinen, Dependabot uppdaterar Actions, Docker-basimage och npm varje vecka.
- **Cache** av Docker-lager via GitHub Actions cache.
- **Concurrency-lås** så att två deployer aldrig körs samtidigt.
- **Minsta möjliga rättigheter** (`permissions`) per jobb.

## Kör lokalt
```
npm test
docker build -t app . && docker run -p 3000:3000 app
curl localhost:3000/health
```

## Aktivera SSH-deploy (valfritt)
Sätt repo-variabeln `DEPLOY_ENABLED=true` och secrets `DEPLOY_HOST`, `DEPLOY_USER`, `DEPLOY_SSH_KEY`,
`GHCR_PULL_USER`, `GHCR_PULL_TOKEN`. Skapa även en Environment `production`.
