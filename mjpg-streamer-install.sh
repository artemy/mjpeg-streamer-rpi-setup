#!/usr/bin/env sh
# update the system
sudo apt-get update
sudo apt-get dist-upgrade -y
# prerequisites
sudo apt-get install git cmake libjpeg-dev rubygems -y
sudo gem install fpm
# clone repo
git clone https://github.com/jacksonliam/mjpg-streamer.git
cd mjpg-streamer/mjpg-streamer-experimental
# patch setup
sed -i 's/\/opt\/vc\/include/\/usr\/include/g' plugins/input_raspicam/CMakeLists.txt
sed -i '/ExecStart/c\ExecStart=/usr/bin/mjpg_streamer -i "input_raspicam.so -x 400 -y 300 -fps 30" -o "output_http.so -w /usr/share/mjpg_streamer/www -p 8000"' mjpg_streamer@.service
sed -i '/install -D mjpg_streamer@.service/c\install -D mjpg_streamer@.service _pkg/etc/systemd/system/mjpg_streamer.service' makedeb.sh
# build
make
# create debian package
./makedeb.sh
# install debian package
sudo dpkg -i mjpg-streamer_*.deb
# enable & start daemon
sudo systemctl enable mjpg_streamer
sudo systemctl start mjpg_streamer
