FROM ghcr.io/linuxserver/baseimage-alpine-nginx:3.21

LABEL maintainer="aptalca"
LABEL org.opencontainers.image.source=https://github.com/aptalca/m3uplayer

ARG APP_VERSIONS

ENV HOME="/config"

RUN \
  echo "**** install runtime packages ****" && \
  apk add --no-cache --upgrade \
    npm && \
  echo "**** install backend and frontend ****" && \
  if [ -z "${APP_VERSIONS+x}" ]; then \
    FRONTEND_RELEASE=$(curl -sX GET "https://api.github.com/repos/4gray/iptvnator/releases" \
      | jq -r '.[0].tag_name'); \
    BACKEND_COMMIT=$(curl -sX GET "https://api.github.com/repos/4gray/iptvnator-backend/commits" \
      | jq -r '.[0].sha' | cut -c -8); \
  else \
    FRONTEND_RELEASE=$(echo "${APP_VERSIONS}" | sed 's|-.{8}$||'); \
    BACKEND_COMMIT=$(echo "${APP_VERSIONS}" | sed -r 's|.*-(.{8})$|\1|'); \
  fi && \
  mkdir -p /app/backend && \
  curl -o \
    /tmp/backend.tar.gz -fL \
    "https://github.com/4gray/iptvnator-backend/archive/${BACKEND_COMMIT}.tar.gz" && \
  tar xf \
    /tmp/backend.tar.gz -C \
    /app/backend --strip-components=1 && \
  cd /app/backend && \
  npm install && \
  mkdir -p \
    /app/www/public \
    /tmp/frontend && \
  curl -o \
    /tmp/frontend.tar.gz -fL \
    "https://github.com/4gray/iptvnator/archive/refs/tags/${FRONTEND_RELEASE}.tar.gz" && \
  tar xf \
    /tmp/frontend.tar.gz -C \
    /tmp/frontend --strip-components=1 && \
  cd /tmp/frontend && \
  npm ci && \
  npm run build:web && \
  mv /tmp/frontend/dist/* /app/www/public/ && \
  echo "**** cleanup ****" && \
  rm -rf \
    /tmp/* \
    "${HOME}"/.npm

# copy local files
COPY root/ /

# ports and volumes
EXPOSE 80 443
