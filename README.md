# m3uplayer

Combines the frontend and backend of IPTVnator in a single docker image served under one url.

Requires the var `CLIENT_URL` set to the exact address the user will be accessing it in the browser at (ie. `http://192.168.1.5:3576` or `http://mydomain.url`).

If the stream links are http, the app needs to be accessed over http. Otherwise the browser will likely block access due to mixed content.

Sample compose yaml:
```yaml
services:
  m3uplayer:
    image: ghcr.io/aptalca/m3uplayer
    container_name: m3uplayer
    ports:
      - 3576:80
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=America/New_York
      - CLIENT_URL=http://192.168.1.5:3576
    restart: unless-stopped
```

**NOTE:**
While this branch builds and pushes upstream releases to the `latest` tag, the [dev branch](https://github.com/aptalca/m3uplayer/tree/dev) of this repo builds and pushes upstream commits to the `dev` tag. You can pull them via `docker pull ghcr.io/aptalca/m3uplayer:dev`.
