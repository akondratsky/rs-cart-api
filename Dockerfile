FROM alpine:latest as base
RUN apk add --update --no-cache nodejs

FROM alpine:latest as npmbase
RUN apk add --update --no-cache npm

# prepare node_modules
FROM npmbase as dependencies
WORKDIR /app
COPY package*.json ./
RUN npm install && npm cache clean --force

# let's create normal build
FROM dependencies as build
WORKDIR /app
COPY . /app
RUN npm run build

FROM npmbase as releasebuild
WORKDIR /app
COPY --from=build /app/package*.json ./
RUN npm install --only=production
COPY --from=build /app/dist ./

FROM npmbase as release
WORKDIR /app
COPY --from=releasebuild /app ./

EXPOSE 4000

CMD ["node", "main.js"]
