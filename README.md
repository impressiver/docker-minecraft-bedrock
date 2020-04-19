# Minecraft Bedrock Server in Docker

Run the official [Minecraft Bedrock server](https://www.minecraft.net/en-us/download/server/bedrock/) in Docker, optionally syncing data to a mounted volume for persistence.


## Prerequisites

- [Docker](https://www.docker.com/get-started)


## Arguments

| Flag | Description | Default |
| ---- | ----------- | ------- |
| BEDROCK_VERSION | Specify [server version](https://minecraft.gamepedia.com/Bedrock_Dedicated_Server#History) | `1.14.60.5` |
| BEDROCK_DOWNLOAD_URL | Override download URL | "https://minecraft.azureedge.net/bin-linux/bedrock-server-${BEDROCK_VERSION}.zip" |


## Instructions

1. **Pull the latest image from [Docker Hub](https://hub.docker.com/r/iwhite/minecraft-bedrock)**

```bash
$ docker pull iwhite/minecraft-bedrock
```


2. **Create a container and run Minecraft Bedrock server**

* Create a Bedrock server that accepts connections only over ipv4

```bash
$ docker run -dit -p 19132:19132/tcp -p 19132:19132/udp iwhite/minecraft-bedrock
```

* Create a Bedrock server that accepts connections over both ipv4 and ipv6

```bash
$ docker run -dit -p 19132:19132/tcp -p 19132:19132/udp -p 19133:19133/tcp -p 19133:19133/udp iwhite/minecraft-bedrock
```

* Create a Bedrock server with persistent settings and data

```bash
$ docker run -dit -v /path/to/minecraft-bedrock:/data -p 19132:19132/tcp -p 19132:19132/udp iwhite/minecraft-bedrock
```

Replace `/path/to/minecraft-bedrock` with an absolute path (on the Docker host) where data and settings should be stored.

Default settings are automatically created when the container first starts.
Data is then synced every time the container starts, and every time the server or container is stopped.
This ensures files created or modified by the server are saved to the mounted volume and loaded again after restart.


3. **Connect to the Minecraft server console inside a running container**

```bash
# Find running server container id
$ docker ps -f ancestor=iwhite/minecraft-bedrock --format "{{.ID}}: {{.Image}} {{.Status}}"
# Attach to server console
$ docker attach {container id}
# To detach from the console, type: ^P^Q
```

You might not see any output after attaching to a container, just type `help` and hit enter for a list of available commands.
