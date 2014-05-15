#!/bin/bash
#%stage: device

# Based on original work of Robert Plestenjak, robert.plestenjak@xlab.si
# Redesigned for SLES initrd, 2013 Alexander von Gluck IV
#
# Grows the root partition to fill the disk
# when used in an OpenStack or cloud environment
#

# This doesn't work with UUID's or filesystem names and could be improved
root_part=$(grep -oe "root=/dev/\S*" /proc/cmdline | sed 's/root=//')
root_dev=$(echo ${root_part} | sed 's/[^a-z]$//g')
part_num=$(echo ${root_part} | sed 's/\/dev\/[a-z]*//g')
part_array=$(cat /proc/partitions |awk '{print $3}' |sed "s/[^0-9]//g")
part_count=1

echo "Growpart: part: ${root_part}, dev: ${root_dev}, num: ${part_num}"

for part_value in ${part_array}; do
	if [ ${part_count} -eq 1 ]; then
		part_zero=${part_value}
	else
		part_zero=$((part_zero-part_value))
	fi
	part_count=$((part_count+1))
done

# change size only if size diff is greater than 20480 blocks
if [ ${part_zero} -gt 20480 ]; then
	echo "Growpart: Resizing root filesystem ${root_dev} partition ${part_num}"
	growpart --fudge 20480 -v ${root_dev} ${part_num}
	e2fsck -y -f ${root_dev}${part_num}
	resize2fs ${root_dev}${part_num}
else
	echo "Growpart: No change needed on ${root_dev} partition ${part_num}"
fi
