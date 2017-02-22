#!/bin/bash

#Bash disables history in noninteractive shells by default, but we turn it on here.
HISTFILE=~/.bash_history
set -o history

cd /opt/QA/sources/suricata/ && \
LSAN_OPTIONS=suppressions=qa/lsan.suppress ASAN_OPTIONS=detect_leaks=0 \
/usr/bin/suricata -T
