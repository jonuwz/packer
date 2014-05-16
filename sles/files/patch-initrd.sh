#!/bin/bash
# Modifies the initrd to resize the root partition to the whole disk at boot
# This enables dynamic root disks in OpenStack and SUSE Cloud
#
# Based on original work of Robert Plestenjak, robert.plestenjak@xlab.si
# Redesigned for SLES, 2013 Alexander von Gluck IV
#
# depends:
#   cloud-init from SUSE-Cloud repo and chkconfig cloud-init on
#
# what it does:
# - installs itself in '/usr/libexec/sles-initrd-growpart' directory, change
#   '${install_dir}' to change install path
# - automatic partition resize and filesystem increase of root partition
#   during boot
#
install_dir=/usr/libexec/sles-initrd-growpart

function deps () {
	for file in ${@}; do
		[ ! -z $(echo $file | grep -o "$lib") ] &&
			cp -v ${file} ${lib}/
	done
}

function modify-initrd () {
	echo "--- copying tools and dependencies ..."
	cp -v ${install_dir}/51-growpart.sh boot/
	cp -v ${install_dir}/growpart sbin/
	cp -v $(which awk) bin/
	cp -v $(which readlink) bin/
	cp -v $(which sfdisk) sbin/
	cp -v $(which e2fsck) sbin/
	cp -v $(which resize2fs) sbin/
	cp -v $(which partprobe) sbin/
	deps "($(ldd bin/awk))"
	deps "($(ldd bin/readlink))"
	deps "($(ldd sbin/sfdisk))"
	deps "($(ldd sbin/e2fsck))"
	deps "($(ldd sbin/resize2fs))"
	deps "($(ldd sbin/partprobe))"
	echo "--- adding initrd task to resize '/'"
	chmod 755 boot/51-growpart.sh
	sed -i '/preping 21-devinit_done.sh/i\
[ "$debug" ] && echo running 51-growpart.sh\nsource boot/51-growpart.sh' run_all.sh
	echo "--- done"
}

# exit if not root
if [ "$USER" != "root" ]; then
	echo "Run as root!"
	exit 1
fi


echo "Starting SLES initrd modification process ..."

# collect system and partitions info
kernel_version=$(uname -r)
root_dev=$(cat /etc/fstab |grep "\/dev\/.*\/ .*" |awk '{print $1}')

# create install dir and copy scripts
[ ! -d ${install_dir} ] && mkdir -p ${install_dir}
cp growpart patch-initrd.sh 51-growpart.sh ${install_dir}/

# create backup of important files
echo "- backing up menu.lst >> ${install_dir}/menu.lst.$(date +%Y%m%d-%H%M)"
cp /boot/grub/menu.lst ${install_dir}/menu.lst.$(date +%Y%m%d-%H%M)

# prepare initamfs copy
echo -n "- extracting initrd /boot/initrd-${kernel_version}, size: "
[ "$(uname -m)" == "x86_64" ] && \
	lib=lib64 || \
	lib=lib
[ -d /tmp/initrd-${kernel_version} ] && \
	rm -rf /tmp/initrd-${kernel_version}
mkdir /tmp/initrd-${kernel_version}
cd /tmp/initrd-${kernel_version}
gunzip -c /boot/initrd-${kernel_version} | cpio -i --make-directories

# modify initrd
echo "- modify initrd copy /tmp/initrd-${kernel_version}"
modify-initrd

# remove existing initrd grow images
echo "- removing all previous mod setups"
rm -fv /boot/initrd-grow-*

# create new initrd
echo -n "- new initrd /boot/initrd-grow-${kernel_version}, size: "
find ./ | cpio -H newc -o > /tmp/initrd.cpio
gzip -c /tmp/initrd.cpio > /boot/initrd-grow-${kernel_version}

# set grub root
root_grub=$(cat /boot/grub/menu.lst |grep -v "^#" |grep -m1 -o "root (hd[0-9],[0-9])")

# modify grub menu
echo "- setting up menu.lst"
grub_entry_title="title SUSE Linux Enterprise GrowPart ${kernel_version}"
grub_entry_root="	${root_grub}"
grub_entry_kernel="	kernel /boot/vmlinuz-${kernel_version} root=${root_dev} splash=silent crashkernel=256M-:128M showopts vga=0x314"
grub_entry_initrd="	initrd /boot/initrd-grow-${kernel_version}"
# remove existing entry
grub_entry_start="title SUSE Linux Enterprise GrowPart ${kernel_version}"
grub_entry_end="\tinitrd \/boot\/initrd-grow-${kernel_version}"
sed -i "/${grub_entry_start}/,/${grub_entry_end}/d" /boot/grub/menu.lst
# insert new entry
echo "${grub_entry_title}" >> /boot/grub/menu.lst
echo "${grub_entry_root}" >> /boot/grub/menu.lst
echo "${grub_entry_kernel}" >> /boot/grub/menu.lst
echo "${grub_entry_initrd}" >> /boot/grub/menu.lst

# ensure default is new entry (TODO: check index)
sed -i 's/^default ./default 2/g' /boot/grub/menu.lst

# cleanup
echo "- clean up"
rm -rf /tmp/initrd-${kernel_version}
rm -f /tmp/initrd.cpio
rm -f /tmp/root_part.tmp

echo "+ Done. The next system reboot will resize the root filesystem if needed"
echo "  Please remember to chkconfig cloud-init on!"
