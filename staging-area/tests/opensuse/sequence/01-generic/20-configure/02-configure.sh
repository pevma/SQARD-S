#!/bin/bash

#Bash disables history in noninteractive shells by default, but we turn it on here.
HISTFILE=~/.bash_history
set -o history

cd /opt/QA/sources/suricata/ && (cd libhtp && git clean -xdf) 
git clean -xdf

./autogen.sh

./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var \
CPPFLAGS="-I/usr/include/libnetfilter_queue -I/usr/include/libnfnetlink-1.0.1 -I/usr/include/libnetfilter_log" \
CFLAGS="-ggdb -O0" --enable-unittests --enable-debug --enable-profiling \
--enable-nfqueue --enable-nflog \
--enable-lua --disable-gccmarch-native --enable-geoip
