#!/bin/bash
set -e

# Set some vars
INSTANCE_NAME=render-instance
FRACTAL_FILE=./testfile.txt

# Remove any previous instance with this name
echo Y | gcloud compute instances delete ${INSTANCE_NAME}

# Create a new instance
# Instance will be preemptible: much cheaper but can be stopped at any time and max 24h
# https://cloud.google.com/compute/docs/instances/preemptible
# Set machine type to desired size
gcloud compute instances create ${INSTANCE_NAME} \
  --image-family=ubuntu-minimal-1904 --image-project=ubuntu-os-cloud \
  --preemptible --machine-type=f1-micro

# Send local file to box
gcloud compute scp ${FRACTAL_FILE} ${INSTANCE_NAME}:~ --force-key-file-overwrite

# SSH Into the box 
# - install all dependencies
# - mount bucket as disk
# - start rendering
gcloud compute ssh ${INSTANCE_NAME} --force-key-file-overwrite << EOF
  ls
  echo 'hello world'
EOF
