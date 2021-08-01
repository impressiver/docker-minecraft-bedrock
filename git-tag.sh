#!/usr/bin/env bash

BEDROCK_VERSION=${BEDROCK_VERSION:-1.17.10.04}

echo "Creating git tag for version ${BEDROCK_VERSION}..."
git tag ${BEDROCK_VERSION}

echo "Pushing tags..."
git push --tags

echo "Done."
