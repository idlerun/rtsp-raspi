#!/bin/bash
cd $(dirname $0)
docker build -t rtsp-raspi .
docker rm -f rtsp-raspi &>/dev/null
docker create --name rtsp-raspi rtsp-raspi
rm -rf bin
mkdir -p bin
docker cp rtsp-raspi:/src/v4l2rtspserver-0.1.0/v4l2rtspserver-0.1.0 bin/v4l2rtspserver
docker rm -f rtsp-raspi &>/dev/null
