# /serpent-surge-infra/docker/backend/Dockerfile
FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
RUN npm install --production

# RUN apk del mariadb-client
RUN apk add --no-cache mysql-client curl

COPY src ./src
# COPY .env .env

EXPOSE 3000

CMD ["node", "src/index.js"]
ARG BUILD_TIME
ENV BUILD_TIME=$BUILD_TIME
