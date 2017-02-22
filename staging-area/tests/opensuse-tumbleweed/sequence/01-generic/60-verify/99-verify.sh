#!/bin/bash

#Bash disables history in noninteractive shells by default, but we turn it on here.
HISTFILE=~/.bash_history
set -o history

# if there is a core file copy it to logs
# to be picked up by the report harvesting
if [ -f /opt/QA/sources/suricata/core ]; then
    
    cp /opt/QA/sources/suricata/core /opt/QA/results/logs/
    
fi
