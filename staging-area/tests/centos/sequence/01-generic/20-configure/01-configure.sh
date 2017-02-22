#!/bin/bash

#Bash disables history in noninteractive shells by default, but we turn it on here.
HISTFILE=~/.bash_history
set -o history

cd /opt/QA/sources/suricata/ && \
./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var \
CFLAGS="-march=native -O3" --enable-gccprotect --enable-pie
