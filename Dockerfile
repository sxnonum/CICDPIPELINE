FROM node:26-alpine
ENV NODE_ENV=production
WORKDIR /app
# Appen har inga beroenden, så npm/npx behövs inte i runtime-imagen (mindre attackyta)
RUN rm -rf /usr/local/lib/node_modules/npm /usr/local/bin/npm /usr/local/bin/npx
COPY package.json ./
COPY src ./src
ARG APP_VERSION=dev
ENV APP_VERSION=$APP_VERSION
USER node
EXPOSE 3000
HEALTHCHECK --interval=30s --timeout=3s CMD wget -qO- http://127.0.0.1:3000/health || exit 1
CMD ["node", "src/server.js"]
