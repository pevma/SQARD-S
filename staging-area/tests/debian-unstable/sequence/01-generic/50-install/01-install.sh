#!/bin/bash

#Bash disables history in noninteractive shells by default, but we turn it on here.
HISTFILE=~/.bash_history
set -o history

cd /opt/QA/sources/suricata/ && \
make install && \
make install-conf && ldconfig

#if pfrng is present on the docker
# ldcofnig it 
if [ -d /tmp/sqard/PF_RING ];
then 
    ldconfig /usr/local/lib 
fi
