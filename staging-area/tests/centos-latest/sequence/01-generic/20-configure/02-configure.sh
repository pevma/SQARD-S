#!/bin/bash

#Bash disables history in noninteractive shells by default, but we turn it on here.
HISTFILE=~/.bash_history
set -o history

cd /opt/QA/sources/suricata/ && (cd libhtp && git clean -xdf) 
git clean -xdf

./autogen.sh

./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var \
CFLAGS="-ggdb -O0" --enable-unittests --enable-debug --enable-profiling \
--enable-nfqueue --enable-nflog \
--enable-lua --disable-gccmarch-native --enable-hiredis --enable-geoip