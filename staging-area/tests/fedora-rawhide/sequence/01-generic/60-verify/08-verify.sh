#!/bin/bash

#Bash disables history in noninteractive shells by default, but we turn it on here.
HISTFILE=~/.bash_history
set -o history

cd /opt/QA/sources/suricata/ && \
/usr/bin/suricata --engine-analysis -l /var/log/suricata/

cp /var/log/suricata/*perf.log /opt/QA/results/logs/
