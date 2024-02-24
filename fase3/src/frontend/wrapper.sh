#!/bin/sh
## https://stackoverflow.com/questions/74726224/opensslerrorstack-error03000086digital-envelope-routinesinitialization-e
## https://github.com/bitwarden/clients/issues/6689
export NODE_OPTIONS="--openssl-legacy-provider --no-deprecation"
#npm start
serve -s build