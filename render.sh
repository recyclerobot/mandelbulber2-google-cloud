#!/bin/bash

cp /root/disk/mandelbulber2 /root && chmod +x /root/mandelbulber2

FRACTAL_PROJECT_PATH=/root/disk/input && mkdir -p $FRACTAL_PROJECT_PATH/output 
FRACTAL_FILE_FULL_PATH=`find $FRACTAL_PROJECT_PATH -name "*.fract"` && echo "FRACTALFULLPATH: $FRACTAL_FILE_FULL_PATH" 
FRACTAL_NAME=`basename $FRACTAL_FILE_FULL_PATH` && FRACTAL_NAME=${FRACTAL_NAME%.*} && echo "FRACTALNAME: $FRACTAL_NAME" 
FILEARR=(/root/disk/input/output/frame*(N))

echo FILEARR = $FILEARR

LASTFILE=${FILEARR[-1]#/root/disk/input/output/frame_} 
LASTFILENR=${${LASTFILE##+(0)}/.png/} 
if [ -z "$LASTFILENR" ]; then LASTFILENR=-1; fi

NEXTFILENR=$((LASTFILENR + 1)) 
nohup /root/mandelbulber2 -o $FRACTAL_PROJECT_PATH/output/ -K -n -s ${NEXTFILENR} $FRACTAL_FILE_FULL_PATH > $FRACTAL_PROJECT_PATH/$FRACTAL_NAME_`date +%s`.log 2>&1