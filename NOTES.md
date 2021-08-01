
# Notes

## Release new version

### Update Bedrock version

- Open [https://www.minecraft.net/en-us/download/server/bedrock/](https://www.minecraft.net/en-us/download/server/bedrock/)
- Inspect Ubuntu `DOWNLOAD` button href to find latest version
- Update all occurences of `BEDROCK_VERSION` in the repo
- Commit and push changes w/ message `Upgrade to <version>`
- Run `./git-tag.sh` to tag the release
- Check [Docker Hub](https://hub.docker.com/repository/docker/iwhite/minecraft-bedrock/builds)

### Auto build (no longer working, Docker Hub got rid of free builds)

Pushing commits/tags to GitHub will trigger [Docker Hub](https://hub.docker.com/repository/docker/iwhite/minecraft-bedrock/builds) builds.

### Manual build

*Note: `./build.sh` builds the container locally, does not push anything to GitHub.*

#### Build and push to [Docker Hub](https://hub.docker.com/repository/docker/iwhite/minecraft-bedrock)

- Update all occurences of `BEDROCK_VERSION` in the repo
- `docker build -t "iwhite/minecraft-bedrock:${BEDROCK_VERSION}" .`
- `docker tag "iwhite/minecraft-bedrock:${BEDROCK_VERSION}" iwhite/minecraft-bedrock:latest`
- `docker login`
- `docker push "iwhite/minecraft-bedrock:${BEDROCK_VERSION}"`
- `docker push iwhite/minecraft-bedrock:latest`
- Copy contents of `README.md` to update the Docker Hub repo [Readme](https://hub.docker.com/repository/docker/iwhite/minecraft-bedrock)

## Run locally

```bash
mkdir /tmp/minecraft-bedrock
docker run -dit -v /tmp/minecraft-bedrock:/data -p 19132:19132/tcp -p 19132:19132/udp iwhite/minecraft-bedrock:{version}
```

### Debug

```bash
docker exec -it {container_id} bash
```
