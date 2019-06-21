#!/usr/bin/env bash

##
# Bedrock Dedicated Server Entrypoint
#
# There are currently no flags or configuration settings to customize the
# bedrock dedicated server data path, so this script handles syncing data to
# the mounted volume for persistence.
#
# At startup, files and directories that don't already exist on the mounted
# volume are copied over. Then paths are replaced with symlinks to '/data' so
# that modifications made while the server is running will be persisted.
#
# When the server or container is stopped, any newly generated files are also
# persisted.
##

FILES=(
  'Debug_Log.txt'
  'permissions.json'
  'server.properties'
  'whitelist.json'
)
DIRS=(
  'behavior_packs'
  'definitions'
  'development_behavior_packs'
  'development_resource_packs'
  'resource_packs'
  'structures'
  'treatments'
  'world_templates'
  'worlds'
)

function term_handler() {
  echo "Received SIGTERM"
  trap - SIGTERM
  if [ $pid -ne 0 ]; then
    echo "Stopping server..."
    kill -SIGTERM "$pid"
  fi
  copy_data
  exit 143 # SIGTERM
}

# copy server-generated files to data dir (that don't already exist)
function copy_data() {
  echo "Copying data to mount..."
  for file in ${FILES[*]}; do
    [[ ! -f "/data/$file" && -f "/opt/bedrock-server/$file" ]] && cp "/opt/bedrock-server/$file" "/data/$file"
  done
  for dir in ${DIRS[*]}; do
    [[ ! -d "/data/$dir" && -d "/opt/bedrock-server/$dir" ]] && cp -R "/opt/bedrock-server/$dir" "/data/$dir"
  done
  return 0
}

# replace server config dirs/files w/ symlinks to data dir (if they exist)
function link_data() {
  echo "Linking data from mount..."
  # link mounted config files
  for file in ${FILES[*]}; do
    if [[ -f "/data/$file" && ! -L "/opt/bedrock-server/$file" ]]; then
      [[ -f "/opt/bedrock-server/$file" ]] && rm "/opt/bedrock-server/$file"
      ln -s "/data/$file" "/opt/bedrock-server/$file"
    fi
  done
  # link mounted data dirs
  for dir in ${DIRS[*]}; do
    if [[ -d "/data/$dir" && ! -L "/opt/bedrock-server/$dir" ]]; then
      [[ -d "/opt/bedrock-server/$dir" ]] && rm -r "/opt/bedrock-server/$dir"
      ln -s "/data/$dir" "/opt/bedrock-server/$dir"
    fi
  done
  return 0
}

### Bedrock Minecraft Server Startup ###

# server process id
pid=0

# trap docker stop signal
trap 'term_handler' SIGTERM

# sync data on startup
copy_data
link_data

# start server and redirect stdin for console commands
echo "Starting server..."
"$@"<&0 &
pid=$!

# wait for server to exit
while kill -0 "$pid" >/dev/null 2>&1; do
  sleep 1
done

echo "Server stopped!"
copy_data
