#!/bin/bash
zypper clean
zypper lr | grep "^[0-9]" | while read line;do zypper rr 1;done
zypper ref

docfiles=`find /usr/share/doc/packages -type f |grep -iv "copying\|license\|copyright"`
rm -f $docfiles
rm -rf /usr/share/info /usr/share/man /tmp/files

dd if=/dev/zero of=/zerofile
rm -f /zerofile
