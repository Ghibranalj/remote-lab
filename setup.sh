#!/usr/bin/env bash

setuprouteros() {
    mkdir routeros
    cd routeros || exit
    wget 'https://download.mikrotik.com/routeros/7.6/chr-7.6.vdi.zip'
    unzip chr-7.6.vdi.zip
    mv chr-7.6.vdi chr.vdi
    cd ..
}
[ -f "./routeros/chr.vdi" ] || setuprouteros

tar -xvf chr-7.7.img.tar.gz
mkdir -p gns3/images gns3/projects gns3/appliances
mv chr-7.7.img gns3/images/
cp *.gns3a gns3/appliances/

sudo dnf copr enable tgerov/vpcs
sudo dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
sudo dnf -y install gns3-gui gns3-server python3 nginx novnc vpcs dynamips
sudo dnf -y install bridge-utils libvirt virt-install qemu-kvm virt-manager

sudo dnf -y install dnf-plugins-core
sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo

sudo dnf install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

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
ubridge_path = $(which ubridge)
auth = False
user = bimbel
password = mikrotik

[VPCS]
vpcs_path = $(which vpcs)

[Dynamips]
allocate_aux_console_ports = False
mmap_support = True
dynamips_path = $(which dynamips)
sparse_memory_support = True
ghost_ios_support = True

[IOU]
iouyap_path = $(which iouyap)
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
