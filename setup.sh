#!/usr/bin/env bash

setuprouteros() {
    mkdir routeros
    cd routeros || exit
    wget 'https://download.mikrotik.com/routeros/7.6/chr-7.6.vdi.zip'
    apt install unzip
    unzip chr-7.6.vdi.zip
    mv chr-7.6.vdi chr.vdi
    cd ..
}
[ -f "./routeros/chr.vdi" ] || setuprouteros

add-apt-repository ppa:gns3/ppa
apt update
apt install gns3-gui gns3-server python
snap install docker
snap install novnc

ln $PWD/nginx.conf /etc/ngnx/nginx.conf

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
