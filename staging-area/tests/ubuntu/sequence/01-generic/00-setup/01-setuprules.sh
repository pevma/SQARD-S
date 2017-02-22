#!/bin/bash

#Bash disables history in noninteractive shells by default, but we turn it on here.
HISTFILE=~/.bash_history
set -o history

#remove if any existing previous output is present
mkdir -p /etc/suricata/rules/
cp /opt/QA/sources/rules/* /etc/suricata/rules/
cp /opt/QA/sources/suricata/rules/* /etc/suricata/rules/

