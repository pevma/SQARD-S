#!/bin/bash

#Bash disables history in noninteractive shells by default, but we turn it on here.
HISTFILE=~/.bash_history
set -o history

#current script native directory
SELF_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PARENT_DIR=$( dirname "${SELF_DIR}" )
SEQUENCE_DIR=$( dirname "${PARENT_DIR}" )

if [ ! -f ${SEQUENCE_DIR}/SKIP_PFRING ]; then
    
    rm -rf /tmp/sqard/PF_RING
    git clone --depth 1 https://github.com/ntop/PF_RING.git /tmp/sqard/PF_RING
    cd /tmp/sqard/PF_RING/userland/lib && ./configure --prefix=/usr/local/pfring && make && make install
    ldconfig /usr/local/lib && ldconfig /usr/local/pfring/lib/
    cp /tmp/sqard/PF_RING/kernel/linux/pf_ring.h  /usr/include/linux/
    
    cd /opt/QA/sources/suricata/ && (cd libhtp && git clean -xdf) 
    git clean -xdf
    
    ./autogen.sh
    
    ./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var \
    CFLAGS="-ggdb -O0" \
    CPPFLAGS="-I/usr/include/libnetfilter_queue -I/usr/include/libnfnetlink-1.0.1 -I/usr/include/libnetfilter_log" \
    --enable-unittests --enable-debug --enable-profiling \
    --enable-nfqueue --enable-nflog --enable-pfring \
    --enable-lua --disable-gccmarch-native --enable-geoip \
    --with-libpfring-includes=/usr/local/pfring/include/ \
    --with-libpfring-libraries=/usr/local/pfring/lib/
    
fi
