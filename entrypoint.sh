#!/usr/bin/env bash

##
# Bedrock Dedicated Server Entrypoint
#
# There are currently no flags or configuration settings to customize the
# bedrock dedicated server data paths, so this script handles syncing data to
# the volume mounted at '/data' for persistence.
#
# At startup, files and directories that don't already exist on the mounted
# volume are copied over. Then paths in the default location are replaced with
# symlinks to '/data' so that modifications made while the server is running
# will be persisted on the mounted volume. Finally, when the server or
# container is stopped, any newly generated files are also copied over.
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

# handle docker stop signal by passing signal to server and then copying data
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

# copy server generated files to data dir (that don't already exist)
function copy_data() {
  echo "Copying data to mount..."
  # copy server files that don't exist on mount
  for file in ${FILES[*]}; do
    if [[ ! -f "/data/$file" && -f "/opt/bedrock-server/$file" ]]; then
      echo "Copying bedrock-server/$file to /data"
      cp "/opt/bedrock-server/$file" "/data/$file"
    fi
  done
  # copy server directories that don't exist on mount
  for dir in ${DIRS[*]}; do
    if [[ ! -d "/data/$dir" && -d "/opt/bedrock-server/$dir" ]]; then
      echo "Copying bedrock-server/$dir to /data"
      cp -r "/opt/bedrock-server/$dir" "/data/$dir"
    fi
  done
  return 0
}

# replace server config files/dirs w/ symlinks to data dir (if they exist)
# this will overwrite any conflicting non-symlink paths in the server dir
function link_data() {
  echo "Linking data from mount..."
  # link mounted config files
  for file in ${FILES[*]}; do
    if [[ -f "/data/$file" && ! -L "/opt/bedrock-server/$file" ]]; then
      [[ -f "/opt/bedrock-server/$file" ]] && rm "/opt/bedrock-server/$file"
      echo "Linking bedrock-server/$file to /data/$file"
      ln -s "/data/$file" "/opt/bedrock-server/$file"
    fi
  done
  # link mounted data dirs
  for dir in ${DIRS[*]}; do
    if [[ -d "/data/$dir" && ! -L "/opt/bedrock-server/$dir" ]]; then
      [[ -d "/opt/bedrock-server/$dir" ]] && rm -r "/opt/bedrock-server/$dir"
      echo "Linking bedrock-server/$dir to /data/$dir"
      ln -s "/data/$dir" "/opt/bedrock-server/$dir"
    fi
  done
  return 0
}

### Start Minecraft Bedrock Server ###

# server process id
pid=0

# trap docker stop signal
trap 'term_handler' SIGTERM

# sync data on startup
copy_data
link_data

# start server and redirect stdin to console
echo "Starting server..."
"$@"<&0 &
pid=$!

# wait for server to exit
wait

echo "Server stopped!"
# copy files created during execution
copy_data
