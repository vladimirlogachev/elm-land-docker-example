# Note: `linux/amd64` is a workaround, because elm compiler is not available for `linux/arm64` yet.
# See https://github.com/elm/compiler/issues/2283 for details
# Upd: 0.19.1-6 claims to support arm64, but this Docker build fails.
FROM --platform=linux/amd64 node:20.12-alpine as builder
WORKDIR /app

# Install dependencies
COPY package.json package-lock.json ./
RUN npm install

# Copy source code and build the app
COPY . .
RUN npm run build

FROM nginx:1.25-alpine
WORKDIR /usr/share/nginx/html

# Install jq in order to manipulate json files from script
# Note: `--no-cache` means update before install + remove the cache after install.
RUN apk add --no-cache jq

# Copy nginx config
COPY ./configs/nginx.default-virtual-host.conf /etc/nginx/conf.d/default.conf

# Add script to update config from env variables on container startup
COPY ./configs/nginx.on-startup.sh /docker-entrypoint.d/

# Make the script executable, otherwise it won't run
RUN chmod +x /docker-entrypoint.d/nginx.on-startup.sh

# # Copy bundle and assets
COPY --from=builder /app/dist /usr/share/nginx/html

EXPOSE 80
