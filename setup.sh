#!/usr/bin/env bash

setuprouteros() {
    mkdir routeros
    cd routeros || exit
    wget 'https://download.mikrotik.com/routeros/7.6/chr-7.6.vdi.zip'
    sudo apt install unzip
    unzip chr-7.6.vdi.zip
    mv chr-7.6.vdi chr.vdi
    cd ..
}
[ -f "./routeros/chr.vdi" ] || setuprouteros

tar -xvf chr-7.7.img.tar.gz
mkdir -p gns3/images gns3/projects gns3/appliances
mv chr-7.7.img gns3/images/
cp *.gns3a gns3/appliances/

sudo add-apt-repository ppa:gns3/ppa
sudo apt update
sudo apt install gns3-gui gns3-server python3 nginx novnc websockify
# check if you have docker
[ -x "docker version" ] && snap install docker

[[ -f  /etc/nginx/nginx.conf ]] && sudo mv /etc/nginx/nginx.conf{,.bak}
sudo cp $PWD/nginx.conf /etc/nginx/nginx.conf

cat <<EOF > server.conf
[Server]
host = 0.0.0.0
port = 3080
images_path = $PWD/gns3/images
projects_path = $PWD/gns3/projects
appliances_path = $PWD/gns3/appliances
report_errors = False
console_start_port_range = 2001
console_end_port_range = 5000
udp_start_port_range = 10000
udp_start_end_range = 20000
ubridge_path = /usr/bin/ubridge
auth = False
user = bimbel
password = mikrotik

[VPCS]
vpcs_path = /usr/bin/vpcs

[Dynamips]
allocate_aux_console_ports = False
mmap_support = True
dynamips_path = /usr/bin/dynamips
sparse_memory_support = True
ghost_ios_support = True

[IOU]
iouyap_path = /usr/bin/iouyap
iourc_path = $PWD/gns3/.iourc
license_check = True

[Qemu]
enable_kvm = True
require_kvm = True

EOF
mkdir -p gns3/{images,projects,appliances}

echo "" > token
for i in $(seq  0 150) ; do
    PORT=$((5900 + $i))
    echo ID$PORT: localhost:$PORT >> token
done

cat <<EOF > gns3.service
[Unit]
Description=gns3 server

[Service]
User=$USER
WorkingDirectory=$PWD
ExecStart=/bin/sh $PWD/start.sh
Restart=always

[Install]
WantedBy=multi-user.target
EOF

sudo cp gns3.service /etc/systemd/system/gns3.service
sudo systemctl daemon-reload
sudo systemctl enable gns3.service
