#!/bin/bash
mkdir -p /tmp/grow 
cd /tmp/grow
for i in 51-growpart.sh growpart patch-initrd.sh;do
  wget -O $i --no-check-certificate https://github.com/kallisti5/sles-initrd-growpart/raw/master/$i
done
chmod +x *
sed -i 's#default 0/default 3#default ./default 2#' /tmp/grow/patch-initrd.sh
sed -i 's#e2fsck -f#e2fsck -y -f#' /tmp/grow/51-growpart.sh
./patch-initrd.sh
cd /
rm -rf /tmp/grow
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
