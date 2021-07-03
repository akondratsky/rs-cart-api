# clean layer with nodejs, we will use it for build and for release both
FROM alpine:latest as base
WORKDIR /app
RUN apk add --update --no-cache nodejs

# we need npm only to build project
FROM base as npmbase
RUN apk add --update --no-cache npm

# install all dependencies (including dev) to build project
FROM npmbase as dependencies
WORKDIR /app
COPY package*.json ./
RUN npm install && npm cache clean --force

# build
FROM dependencies as build
WORKDIR /app
COPY . /app
RUN npm run build

# install only those dependencies which are necessary to run application
FROM npmbase as prerelease
WORKDIR /app
COPY --from=dependencies /app/package*.json ./
COPY --from=build /app/dist ./
RUN npm install --only=production

# copy everything we need to run application
FROM base as release
WORKDIR /app
RUN apk add --update --no-cache nodejs
COPY --from=prerelease app ./

EXPOSE 4000

CMD ["node", "main.js"]
