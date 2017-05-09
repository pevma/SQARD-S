=================
SQARD-S (Scripts)
=================

Requirements
============

SQARD-S has been tested on Debian Jessie.
On the system that you run the SQARD-S you should have: 

- docker installed
- the git, wget packages

What does it do
===============

It is a Suricata QA tool that allows for a particular github branch/repository remote or local to be tested against:  

- complete and multiple different configure/compile routines (clang/asan)
- tests pfring/netmap compilation
- makecheck
- Suricata output/checks like -T, --build-info, unittests, --dump-config, --list-runmodes, --list-app-layer-protos, --list-keywords=all, --engine-analysis
- offering multiple switches for a flexible and fast tests
- it will spin up multiple different OS dockers in parallel to test on
- after each docker is finished with the tests it will automatically exit and be stopped and removed. (atm there is a hard time limit of 1hr for a run on a docker - todo)

The OSs flavors for the SQARD-S docker testing available are:  

- debian-unstable debian-latest debian-testing
- ubuntu-latest ubuntu-devel ubuntu-trusty ubuntu-precise
- fedora-latest fedora-rawhide
- opensuse-latest opensuse-tumbleweed
- centos-6 centos-latest

from the repo here - https://hub.docker.com/r/pevma/sqard/tags/
These dockers are build with all the tools and packages needed to compile Suricata and enable the maximum configurational 
features in a particular OS flavor.

In the sqard_config you can choose the staging and log dir location.

All the specified dockers will execute the tests on each individual container and return the logs and 
results in the master log directory specified in sqard_conf file.

The script will return fail upon a single failure during the whole run or success only upon successful completion of all runs.


Examples of usage
=================

Get the source ::

 git clone git@github.com:pevma/SQARD-S.git

Rename the config file and adjust accordingly the folder locations if you wish ::

 cp sample.sqard_config sqard_config

To see examples of usage: 

- ./sqard.sh -h


*NOTE:* This script is BETA version. Feedback is welcome.

TODO: 

- Add in vagrant for BSD tests. 
- Maybe add more dockers -  Alpine, Gentoo etc..
- Add more tests and iron out the process of adding tests itself
- Suggestions and feedback are welcome.

