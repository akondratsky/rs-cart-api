FROM alpine:latest as base
WORKDIR /app
RUN apk add --update --no-cache nodejs npm

FROM base as dependencies
WORKDIR /app
COPY package*.json ./
RUN npm install && npm cache clean --force

FROM dependencies as build
WORKDIR /app
COPY . /app
RUN npm run build

FROM base as prerelease
WORKDIR /app
COPY --from=dependencies /app/package*.json ./
COPY --from=build /app/dist ./
RUN npm install --only=production

FROM base as release
WORKDIR /app
RUN apk add --update --no-cache nodejs
COPY --from=prerelease app ./

EXPOSE 4000

CMD ["node", "main.js"]
