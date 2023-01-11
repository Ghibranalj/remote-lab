setuprouteros() {
    mkdir routeros
    cd routeros || exit
    wget 'https://download.mikrotik.com/routeros/7.6/chr-7.6.vdi.zip'
    unzip chr-7.6.vdi.zip
    mv chr-7.6.vdi chr.vdi
    cd ..
}
[ -f "./routeros/chr.vdi" ] || setuprouteros

add-apt-repository ppa:gns3/ppa
apt update                                
apt install gns3-gui gns3-server
