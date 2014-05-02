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
fi
