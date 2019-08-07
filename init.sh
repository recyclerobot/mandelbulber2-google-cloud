#!/bin/bash
set -e

# Set some vars
INSTANCE_BASE=render-instance
INSTANCE_NAME=${INSTANCE_BASE}-$(date +'%F--%H%M')
FRACTAL_FILE=./testfile.txt
GOOGLE_SERVICE_ACCOUNT_KEY=~/Dropbox/Thijs/_BASH/gke.json
BUCKET_NAME=mandelbulber

# Remove any previous instance with this name
# echo Y | gcloud compute instances delete -q ${INSTANCE_BASE}-*
gcloud compute instances list | grep RUNNING | awk '{printf "gcloud compute instances delete -q %s --zone %s\n", $1, $2}' | bash

# Create a new instance
# Instance will be preemptible: much cheaper but can be stopped at any time and max 24h
# https://cloud.google.com/compute/docs/instances/preemptible
# Set machine type to desired size
gcloud compute instances create ${INSTANCE_NAME} \
  --image-family=ubuntu-minimal-1804-lts --image-project=ubuntu-os-cloud \
  --preemptible --machine-type=f1-micro

# Send local file to box
gcloud compute scp ${FRACTAL_FILE} ${GOOGLE_SERVICE_ACCOUNT_KEY} ${INSTANCE_NAME}:~ --force-key-file-overwrite

# SSH Into the box 
# - mount bucket as disk
# - install all dependencies
# - start rendering
gcloud compute ssh ${INSTANCE_NAME} --force-key-file-overwrite -- '
  pwd && \
  ls -al && \
  export GOOGLE_APPLICATION_CREDENTIALS="~/gke.json" && \
  export GCSFUSE_REPO=gcsfuse-`lsb_release -c -s` && \
  echo "deb http://packages.cloud.google.com/apt $GCSFUSE_REPO main" | sudo tee /etc/apt/sources.list.d/gcsfuse.list && \
  curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add - && \
  sudo apt-get update && \
  sudo apt-get install gcsfuse && \
  sudo mkdir /disk && \
  gcsfuse mandelbulber /disk && \
  ls /disk \
'
