#!/usr/bin/env bash

BEDROCK_VERSION=${BEDROCK_VERSION:-1.17.10.04}

echo "Building image for server ${BEDROCK_VERSION}..."
docker build -t "iwhite/minecraft-bedrock:${BEDROCK_VERSION}" .

# Docker Hub builds tagged/latest images automatically.
# Run `./git-tag.sh` after pushing master to tag a new version.

# Manual build/tag/push to Docker Hub:
# docker build -t "iwhite/minecraft-bedrock:${BEDROCK_VERSION}" .
# docker tag "iwhite/minecraft-bedrock:${BEDROCK_VERSION}" iwhite/minecraft-bedrock:latest
# docker login
# docker push "iwhite/minecraft-bedrock:${BEDROCK_VERSION}"
# docker push iwhite/minecraft-bedrock:latest

echo "Done."
