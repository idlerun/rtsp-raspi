---
page: https://idle.run/baby-raspi
title: "RTSP Raspberry Pi Camera"
tags: raspberry pi stream rtsp
date: 2018-11-10
---

## Overview

Builds the absolutely wonderful `v4l2rtspserver` project (https://github.com/mpromonet/v4l2rtspserver) for the Raspberry PI.

The build is fully self-contained in a docker environment and the resulting binary pulled out for use on the host.

## Requirements

Install Docker as described here: https://www.raspberrypi.org/blog/docker-comes-to-raspberry-pi/

```
curl -sSL https://get.docker.com | sh
```

## Build

Run `./build.sh`

Statically compiled binary will appear in the `./bin` folder


### v4l2

Enable module to create the `/dev/video0` device for the camera

```
modprobe bcm2835-v4l2
echo bcm2835-v4l2 >> /etc/modules
```

### ALSA device ID

Check `arecord -L` to see device ID for alsa device. In my case it's `hw:1`

My device requires channel count 1 `-C 1`. It was pretty clear in the logs when that wasn't set

## Run Manually

```
/opt/rtsp-raspi/bin/v4l2rtspserver -C 1 /dev/video0,hw:1
```

## Run as Service

Create `/opt/stream.sh`

Customize args for `v4l2rtspserver` as appropriate. `-C 1` sets audio device to 1 channel which is required for my specific mic. Username and password should probably be set as well.

```
#!/bin/sh
exec /opt/rtsp-raspi/bin/v4l2rtspserver -C 1 /dev/video0,hw:1
```

Create `/etc/systemd/system/stream.service`
```
[Unit]
Description=RTSP Camera Service

[Service]
User=pi
ExecStart=/opt/stream.sh
Restart=always
RestartSec=30s

[Install]
WantedBy=multi-user.target
```

Load the SystemD module

```
sudo systemctl enable stream
sudo systemctl daemon-reload
sudo systemctl start stream
sudo systemctl status stream
```

Check logs with

```
sudo journalctl -u stream
```


## Test Client

Connect to the stream on another machine with `ffplay`:

```
ffplay -sync ext -fflags nobuffer -framedrop rtsp://192.168.56.31:8554/unicast
```

## Case

See STLs for a case mounting option
