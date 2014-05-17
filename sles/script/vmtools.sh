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
    zypper ref
    zypper -n in cloud-init openstack-heat-cfntools

    # Remove the default cloud.cfg configuration file
    rm /etc/cloud/cloud.cfg

    # Create the new cloud.cfg file
    cat << EOF > /etc/cloud/cloud.cfg


# adapted default config for (open)SUSE systems
user: devopsadmin
disable_root: False
preserve_hostname: False
cc_ready_cmd: [ /bin/true ]
syslog_fix_perms: root:root
# datasource_list: ["NoCloud", "ConfigDrive", "OVF", "MAAS", "Ec2", "CloudStack"]

cloud_init_modules:
 - bootcmd
 - growpart
 - resizefs
 - set_hostname
 - update_hostname
 - update_etc_hosts
 - ca-certs
 - rsyslog
 - ssh

cloud_config_modules:
 - disk-setup
 - mounts
 - ssh-import-id
 - locale
 - set-passwords
 - landscape
 - timezone
 - puppet
 - chef
 - salt-minion
 - mcollective
 - disable-ec2-metadata
 - runcmd

cloud_final_modules:
 - rightscale_userdata
 - scripts-per-once
 - scripts-per-boot
 - scripts-per-instance
 - scripts-user
 - keys-to-console
 - final-message
ssh_genkeytypes: ['rsa', 'dsa']
EOF

# Stick the correct hostname for the cloud templates
dd of=/etc/cloud/templates/hosts.tmpl << EOF
#*
    This file /etc/cloud/templates/hosts.redhat.tmpl is only utilized
    if enabled in cloud-config.  Specifically, in order to enable it
    you need to add the following to config:
      manage_etc_hosts: True
*#
# Your system has configured 'manage_etc_hosts' as True.
# As a result, if you wish for changes to this file to persist
# then you will need to either
# a.) make changes to the master file in /etc/cloud/templates/hosts.redhat.tmpl
# b.) change or remove the value of 'manage_etc_hosts' in
#     /etc/cloud/cloud.cfg or cloud-config from user-data
#
# The following lines are desirable for IPv4 capable hosts
127.0.0.1 localhost.localdomain localhost
127.0.0.1 localhost4.localdomain4 localhost4
1.2.3.4   \${fqdn} \${hostname}


# The following lines are desirable for IPv6 capable hosts
::1 localhost.localdomain localhost
::1 localhost6.localdomain6 localhost6

EOF

  chkconfig cloud-init-local on
  chkconfig cloud-init on
  chkconfig cloud-config on
  chkconfig cloud-final on

fi
