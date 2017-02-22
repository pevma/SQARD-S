#!/bin/bash

#Bash disables history in noninteractive shells by default, but we turn it on here.
HISTFILE=~/.bash_history
set -o history

#current script native directory
SELF_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PARENT_DIR=$( dirname "${SELF_DIR}" )
SEQUENCE_DIR=$( dirname "${PARENT_DIR}" )

if [ ! -f ${SEQUENCE_DIR}/SKIP_NETMAP ]; then
    
    rm -rf /tmp/sqard/netmap
    git clone --depth 1 https://github.com/luigirizzo/netmap.git /tmp/sqard/netmap
    
    cd /opt/QA/sources/suricata/ && (cd libhtp && git clean -xdf) 
    git clean -xdf
    
    ./autogen.sh
    
    ./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var \
    CFLAGS="-ggdb -O0" \
    CPPFLAGS="-I/usr/include/libnetfilter_queue -I/usr/include/libnfnetlink-1.0.1 -I/usr/include/libnetfilter_log" \
    --enable-unittests --enable-debug --enable-profiling \
    --enable-nfqueue --enable-nflog --enable-netmap \
    --enable-lua --disable-gccmarch-native --enable-hiredis --enable-geoip\
    --with-netmap-includes=/tmp/sqard/netmap/sys/ 
    
fi
