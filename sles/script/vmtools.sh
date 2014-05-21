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

    export http_proxy=http://10.61.77.249:8080
    echo -e "10.61.77.250 fileserver" >> /etc/hosts

    patch=$(awk '/^PATCH/ {print $NF}' /etc/SuSE-release)
    zypper ar -G http://fileserver/repos/SLES-11.${patch} SLES-11.${patch}
    zypper ar -G http://fileserver/repos/SLES-11.${patch}-sdk SLES-11.${patch}-sdk
    zypper ar -G http://fileserver/repos/SLES-11.${patch}-custom SLES-11.${patch}-custom
    zypper ar -G http://download.opensuse.org/repositories/Cloud:/Tools/SLE_11_SP${patch} Cloud:Tools
    zypper ar -G http://download.opensuse.org/repositories/Cloud:/OpenStack:/Havana/SLE_11_SP3 Cloud:Openstack:Havana
    zypper ar -G http://download.opensuse.org/repositories/devel:/languages:/python/SLE_11_SP${patch} devel:languages:python
    zypper mr -p 98 Cloud:Openstack:Havana
    zypper mr -p 97 SLES-11.${patch}-custom
    zypper ref
    zypper -n in cloud-init openstack-heat-cfntools

    sed -i '/fileserver/d' /etc/hosts

    # Allow local access to the magic 169 address
    sed -i 's/eth\*\[0-9\]|//g' /etc/sysconfig/network/config

    if [[ -e /tmp/files/cloud.cfg ]];then
      /bin/mv /tmp/files/cloud.cfg /etc/cloud/cloud.cfg
    fi

    echo -e "# ec2-user for cloud-init\nec2-user ALL=(ALL) NOPASSWD: ALL\n" >> /etc/sudoers

    sed -i 's/^#ChallengeResponseAuthentication.*/ChallengeResponseAuthentication no/' /etc/ssh/sshd_config

    chkconfig cloud-init-local on
    chkconfig cloud-init on
    chkconfig cloud-config on
    chkconfig cloud-final on

fi
