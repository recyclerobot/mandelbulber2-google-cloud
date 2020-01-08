#!/bin/bash
set -e

# Set some vars
INSTANCE_BASE=renderer
INSTANCE_NAME=${INSTANCE_BASE}-$(date +'%F--%H%M')
GOOGLE_SERVICE_ACCOUNT_KEY=~/Dropbox/Thijs/_BASH/gke.json
BUCKET_NAME=mandelbulber
PROJECT=$1

if [ -z "$PROJECT" ]; then
  echo "[ X ] Error! No Input path defined, pass in project path as parameter to continue"
  exit 0
fi

echo "PROJECT: $PROJECT"

# Remove any previous instance
# !!! Will remove any instance running in your account !!!
gcloud compute instances list | grep "RUNNING\|TERMINATED" | awk '{printf "gcloud compute instances delete -q %s --zone %s\n", $1, $2}' | bash

# Create a new instance
# Instance will be preemptible: much cheaper but can be stopped at any time and max 24h
# https://cloud.google.com/compute/docs/instances/preemptible
# Set machine type to desired size
gcloud compute instances create ${INSTANCE_NAME} \
  --verbosity=info \
  --preemptible \
  --image-family=ubuntu-minimal-1804-lts \
  --image-project=ubuntu-os-cloud \
  --machine-type=n1-highcpu-16

# wait 20 sec for startup
echo "sleeping for 30 sec (waiting for the instance to boot)..."
sleep 30
echo "wake up!"

# Send local file to box
gcloud compute scp ${GOOGLE_SERVICE_ACCOUNT_KEY} root@${INSTANCE_NAME}:~ --force-key-file-overwrite

# SSH Into the box 
# - mount bucket as disk
# - install all dependencies
# - start rendering
gcloud compute ssh root@${INSTANCE_NAME} --force-key-file-overwrite -- '
  export GOOGLE_APPLICATION_CREDENTIALS="/root/gke.json" && \
  export GCSFUSE_REPO=gcsfuse-`lsb_release -c -s` && \
  echo "deb http://packages.cloud.google.com/apt $GCSFUSE_REPO main" | sudo tee /etc/apt/sources.list.d/gcsfuse.list && \
  curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add - && \
  sudo apt-get update && \
  sudo apt-get install -y gcsfuse wget && \
  sudo apt-get install --only-upgrade bash && \
  mkdir /root/disk && \
  gcsfuse mandelbulber /root/disk && \
  ls /root/disk && \
  sudo apt-get install -y build-essential libqt5gui5 qt5-default libpng16-16 \
    libpng-dev qttools5-dev qttools5-dev-tools libgomp1 libgsl-dev \
    libsndfile1-dev qtmultimedia5-dev libqt5multimedia5-plugins liblzo2-2 \
    liblzo2-dev && \
  cp /root/disk/render.sh /root && chmod +x /root/render.sh && \
  bash -vx /root/render.sh
' &

# wget https://github.com/buddhi1980/mandelbulber2/releases/download/2.19/mandelbulber2-2.19.tar.gz && \
# mkdir mandelbulber2 && tar -xzf mandelbulber2*.tar.gz -C mandelbulber2 --strip-components=1 && \
# cd mandelbulber2 && echo "y" | ./install && \


# if [ -f $FRACTAL_PROJECT_PATH/$FRACTAL_NAME.log ]; then mv $FRACTAL_PROJECT_PATH/$FRACTAL_NAME.log $FRACTAL_PROJECT_PATH/$FRACTAL_NAME_`date +%s`.log fi && \