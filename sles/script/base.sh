#
# base.sh
#

# speed-up remote logins
echo -e "\nspeed-up remote logins ..."
sed -i 's/^#UseDNS.*/UseDNS no/' /etc/ssh/sshd_config

# remove zypper locks, preventing installation of additional packages,
# present because of the autoinst <software><remove-packages>
echo -e "\nremove zypper package locks ..."
rm -f /etc/zypp/locks
rm /etc/udev/rules.d/70-persistent-net.rules

