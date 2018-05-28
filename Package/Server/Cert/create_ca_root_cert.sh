#!/bin/sh

openssl genrsa -out myCA.key 2048
openssl req -x509 -sha256 -new -key myCA.key -out myCA.cer -days 3365 -subj /CN=PackageCA
