#!/bin/bash

#Bash disables history in noninteractive shells by default, but we turn it on here.
HISTFILE=~/.bash_history
set -o history

cd /opt/QA/sources/suricata/ && \
(cd libhtp && git clean -xdf) 

git clean -xdf

./autogen.sh 
