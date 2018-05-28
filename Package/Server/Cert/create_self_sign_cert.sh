#!/bin/sh

IP=$1

pushd $(dirname "${0}") > /dev/null
basedir=$(pwd -L)
# Use "pwd -P" for the path without links. man bash for more info.
popd > /dev/null

set -x

openssl genrsa -out server.key 2048
openssl req -new -out mycert1.req -key server.key -subj /CN=${IP}
openssl x509 -req -sha256 -in mycert1.req -out server.cer -CAkey "${basedir}/myCA.key" -CA "${basedir}/myCA.cer" -days 3365 -CAcreateserial
rm -rf mycert1.req
