# mjpg-streamer Raspberry Pi setup

This guide covers installation and setup of [mjpg-streamer](https://github.com/jacksonliam/mjpg-streamer) daemon for Raspberry Pi

## Prerequisites

This setup instruction relies on legacy Raspberry Pi camera stack.
To enable legacy camera stack, follow the official Raspberry pi camera [documentation](https://www.raspberrypi.com/documentation/accessories/camera.html#re-enabling-the-legacy-stack)

## Installation

These installation steps follow the contents of included [mjpg-streamer-install.sh](mjpg-streamer-install.sh) script.

1. Update the system
   ```shell
   sudo apt-get update
   sudo apt-get dist-upgrade
   sudo rpi-update
   ```
2. Install required dependencies
   ```shell
   sudo apt-get install git cmake libjpeg-dev rubygems -y
   sudo gem install fpm
   ```
3. Clone the mjpg-streamer repository and change directory
   ```shell
   git clone https://github.com/jacksonliam/mjpg-streamer.git
   cd mjpg-streamer/mjpg-streamer-experimental
   ```
4. build the mjpg-streamer project
   ```shell
   make
   ```
5. Patch the setup files to configure mjpg-streamer to use Raspberry Pi camera
   ```shell
   sed -i '/ExecStart/c\ExecStart=/usr/bin/mjpg_streamer -i "input_raspicam.so -x 400 -y 300 -fps 30" -o "output_http.so -w /usr/share/mjpg_streamer/www -p 8000"' mjpg_streamer@.service
   sed -i '/install -D mjpg_streamer@.service/c\install -D mjpg_streamer@.service _pkg/etc/systemd/system/mjpg_streamer.service' makedeb.sh
   ```
6. create debian package
   ```shell
   ./makedeb.sh
   ```

7. install debian package
   ```shell
   sudo dpkg -i mjpg-streamer_*.deb
   ```

8. enable & start daemon
   ```shell
   sudo systemctl enable mjpg_streamer
   sudo systemctl start mjpg_streamer
   ```

## Usage

Once the installation is successfully completed, you can access camera stream using your browser and navigating to URL http://%RASPBERRY-PI-HOST%:8000/?action=stream

## Configuration

By default, mjpg-streamer daemon is configured to produce camera feed with resolution of 400x300.
If you wish to change the output resolution or any other settings, you can do it via updating the `etc/systemd/system/mjpg_streamer.service` file and changing the line starting with `ExecStart` (see [Documentation](https://github.com/jacksonliam/mjpg-streamer/tree/master/mjpg-streamer-experimental/plugins/output_http) for parameter reference):

```shell
ExecStart=/usr/bin/mjpg_streamer -i "input_raspicam.so -x 400 -y 300 -fps 30" -o "output_http.so -w /usr/share/mjpg_streamer/www -p 8000"
```

Once you have updated the mjpg-streamer configuration, you should reload the configuration and restart the daemon:

```shell
sudo systemctl daemon-reload
sudo systemctl restart mjpg_streamer
```
