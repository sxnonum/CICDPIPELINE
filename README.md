# CI/CD-pipeline med GitHub Actions + Docker

Liten Node.js-app (ingen npm-dependency) som testas, byggs till en Docker-image och deployas automatiskt.

## Flöde
| Workflow | Trigger | Steg |
|---|---|---|
| `ci.yml` | PR / push till annan branch än `main` | tester → Docker-build + smoke test (`/health`) |
| `deploy.yml` | push till `main` | tester → build & push till GHCR → SSH-deploy |

## Lokalt
```
npm test
docker build -t app . && docker run -p 3000:3000 app
```

## Secrets (Settings → Secrets → Actions) för deploy-steget
- `DEPLOY_HOST`, `DEPLOY_USER`, `DEPLOY_SSH_KEY` – servern med Docker installerat
- `GHCR_PULL_USER`, `GHCR_PULL_TOKEN` – PAT med `read:packages` så servern kan hämta imagen

Skapa även en Environment `production` (valfritt: kräv manuell approval).
