#!/bin/bash -eux

if test -f linux.iso ; then
    cd /tmp
    mkdir -p /mnt/cdrom
    mount -o loop /home/vagrant/linux.iso /mnt/cdrom
    tar zxf /mnt/cdrom/VMwareTools-*.tar.gz -C /tmp/
    /tmp/vmware-tools-distrib/vmware-install.pl -d
    rm /home/vagrant/linux.iso
    umount /mnt/cdrom
    rmdir /mnt/cdrom
elif test -f VBoxGuestAdditions.iso ; then
    echo -e "\ninstall the virtualbox guest additions ..."
    zypper --non-interactive remove `rpm -qa virtualbox-guest-*`
    mount -o loop VBoxGuestAdditions.iso /mnt
    sh /mnt/VBoxLinuxAdditions.run
    umount /mnt
    rm -f VBoxGuestAdditions.iso
elif test -e /dev/vda1 ;then

    zypper ar http://192.168.0.101/repos/SLES-11.2 SLES-11.2
    zypper ar http://192.168.0.101/repos/SLES-11.2-sdk SLES-11.2-sdk
    zypper ar -G http://192.168.0.101/repos/SLES-11.2-custom SLES-11.2-custom
    zypper ar -G http://download.opensuse.org/repositories/Cloud:/Tools/SLE_11_SP2 Cloud:Tools
    zypper ar -G http://download.opensuse.org/repositories/Cloud:/OpenStack:/Havana/SLE_11_SP3 Cloud:Openstack:Havana
    zypper ar -G http://download.opensuse.org/repositories/devel:/languages:/python/SLE_11_SP2 devel:languages:python
    zypper mr -p 98 Cloud:Openstack:Havana
    zypper mr -p 97 SLES-11.2-custom
    zypper ref
    zypper -n in cloud-init openstack-heat-cfntools

    chkconfig cloud-init-local on
    chkconfig cloud-init on
    chkconfig cloud-config on
    chkconfig cloud-final on

fi
