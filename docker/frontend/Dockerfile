# serpent-surge-infra/docker/frontend/Dockerfile

FROM nginx:alpine

COPY ./dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

ARG BUILD_TIME
ENV BUILD_TIME=$BUILD_TIME
