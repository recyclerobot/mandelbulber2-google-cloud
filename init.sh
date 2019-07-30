#!/bin/bash
set -e

# Set some vars
INSTANCE_NAME=render-instance

# Remove any previous instance with this name
echo Y | gcloud compute instances delete ${INSTANCE_NAME}

# Create a new instance
gcloud compute instances create ${INSTANCE_NAME} \
  --image-family=ubuntu-minimal-1904 --image-project=ubuntu-os-cloud \
  --machine-type=f1-micro

# SSH Into the box and install all dependencies
gcloud compute ssh ${INSTANCE_NAME} --force-key-file-overwrite << EOF
  df -h
  echo 'hello world'
EOF
