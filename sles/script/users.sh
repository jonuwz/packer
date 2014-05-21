#
# postinstall.sh
#

# install keys
if [[ -d /home/vagrant ]];then

  echo -e "\ninstall vagrant key ..."
  mkdir -m 0700 /home/vagrant/.ssh
  cd /home/vagrant/.ssh
  echo 'ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key' > /home/vagrant/.ssh/authorized_keys
  chmod 0600 /home/vagrant/.ssh/authorized_keys
  chown -R vagrant.users /home/vagrant/.ssh
  
  # update sudoers
  echo -e "\nupdate sudoers ..."
  echo -e "Defaults:vagrant !requiretty" >> /etc/sudoers
  echo -e "vagrant ALL=(ALL) NOPASSWD: ALL\n" >> /etc/sudoers

elif [[ -d /home/devopsadmin ]];then

  echo -e "\ninstall devopsadmin key ..."
  mkdir -m 0700 /home/devopsadmin/.ssh
  cd /home/devopsadmin/.ssh
  echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCxvparT30YTVhZ4iuZO2qyRr0sTZPU3b/AoyEuNspcudVZz8AaO0VQoEFH6x5l17gSiPnTBXmhPtPjRyurTpgdIqxxerJ0PRnq60nR5vjqUSgPsoUQH8hxXkkyVpo3v8/X382U2hOCPZemFtJOm8s6g8Dn7g7VMapmtFo1yVrkI9PI8hFlb8ovr9SkjODKfIMxMQkTE//WW3yPHXZ9hBVpAlrYOkk5K6u0lALuOp9LANyJgUuuuZhGgmqfPJMggpd96vL5i2TdlN9z0I5fgZdMOZzZzmTBabMpR3yBL0SoGe6sGEQv+6RC83fLD3opazIOzsDXJ+gcGS0kqyQqnAY3 admin@visa.local
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCxvparT30YTVhZ4iuZO2qyRr0sTZPU3b/AoyEuNspcudVZz8AaO0VQoEFH6x5l17gSiPnTBXmhPtPjRyurTpgdIqxxerJ0PRnq60nR5vjqUSgPsoUQH8hxXkkyVpo3v8/X382U2hOCPZemFtJOm8s6g8Dn7g7VMapmtFo1yVrkI9PI8hFlb8ovr9SkjODKfIMxMQkTE//WW3yPHXZ9hBVpAlrYOkk5K6u0lALuOp9LANyJgUuuuZhGgmqfPJMggpd96vL5i2TdlN9z0I5fgZdMOZzZzmTBabMpR3yBL0SoGe6sGEQv+6RC83fLD3opazIOzsDXJ+gcGS0kqyQqnAY3 devopsadmin' > /home/devopsadmin/.ssh/authorized_keys
  chmod 0600 /home/devopsadmin/.ssh/authorized_keys
  chown -R devopsadmin.users /home/devopsadmin/.ssh

  # update sudoers

fi
