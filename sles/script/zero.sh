#!/bin/bash

docfiles=`find /usr/share/doc/packages -type f |grep -iv "copying\|license\|copyright"`
rm -f $docfiles
rm -rf /usr/share/info
rm -rf /usr/share/man

dd if=/dev/zero of=/zerofile
rm -f /zerofile
