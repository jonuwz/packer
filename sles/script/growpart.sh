#!/bin/bash
cd /tmp/files
chmod +x *
./patch-initrd.sh
cd /
rm -rf /tmp/files
sed -i -r 's/^\t/    /' /boot/grub/menu.lst

# convert shit to real paths - not the by-id nonesense
perl -i -pe 's#(/dev/disk/by-\S+)#{$out=qx(readlink -f $1);chomp $out;$out}#eg' /boot/grub/menu.lst
perl -i -ne 'if (m#^(/dev/disk/by-\S+)(.*)#) {$real=qx(readlink -f $1);chomp $real;print "$real $2\n"} else { print }' /etc/fstab

echo "fstab"
cat /etc/fstab
echo "-------"
echo "menu.lst"
cat /boot/grub/menu.lst
echo "-------"
sleep 2
