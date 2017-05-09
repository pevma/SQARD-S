#!/bin/bash

COUNTER=0
FAILURE=

usage()
{
cat << EOF

usage: $0 options

OPTIONS:
   -h      Help info
   
   -b      Use branch (must be used with repo -r). Uses "master" by default
   
   -c      Include make distcheck (very CPU and time intensive when used with multiple dockers OSes at the same time)
   
   -d      Download and use a full Suricata ETOpen ruleset. That option should always be used on a first run.
   
   -e      Exclude dockers (ex: -e latest - will exclude all "latest" SQARD dockers) - no wild cards
   
   -f      Full all inclusive run - NOTE - this will be very CPU intensive. It is recommended to have minimum 8 CPUs with 16G RAM
   
   -j      Run just a specific SQARD docker(s)
   
   -l      Use local repository located in /path/to/my/local/suricata/repository/
   
   -n      Include Netmap
   
   -p      Include pf_ring
   
   -r      Use repository. Uses "git://phalanx.openinfosecfoundation.org/oisf.git" by default
   
           
   NOTE: At a first time run always use "-d".
   
   EXAMPLE 1: 
   ./sqard.sh -f 
   
   The example above will do a full all test inclusive run. 
   WARNING: 
   This could take a while and be very resource intensive!
   It is recommended to have minimum 8 CPUs with 16G RAM!
   
   EXAMPLE 2: 
   ./sqard.sh -j debian -e stable -p -n -c -l /path/to/my/local/suricata/repository/
   
   Start the tests with just the debian dockers
   Exclude any container that has "stable" in its tag - aka test just debian testing and debian unstable
   Include pfring 
   Include netmap
   Do use make distcheck
   Use local repository located in /path/to/my/local/suricata/repository/
   
   EXAMPLE 3: 
   ./sqard.sh -j fedora -p -n -b next/20170221/v5 -r git@github.com:inliniac/suricata.git
   
   Run a pfring/netmap enabled build tests and install/verification on 
   branch - next/20170221/v5
   from github repo - git@github.com:inliniac/suricata.git
   on all Fedora dockers.
   
   EXAMPLE 4: 
   ./sqard.sh -j suse -p -n -d -c
   
   Build and test
   Include pfring 
   Include netmap
   Download and use full ETOpen ruleset for Suricata.
   Include make distcheck
   Use default branch master and git://phalanx.openinfosecfoundation.org/oisf.git repo.
   on all Suse dockers.
   

   
   
EOF
}

PFRING=
NETMAP=
MAKE_DISTCHECK=
JUST_THESE=
DOWNLOAD_RULESET=
EXCLUDE_THESE=
LOCAL_REPOSITORY=
BRANCH="master" 
# default if not specified
REPOSITORY="git://phalanx.openinfosecfoundation.org/oisf.git"
# default if not specified

while getopts “hb:cj:de:r:pf:nl:” OPTION
do
     case $OPTION in
         h)
             usage
             exit 1
             ;;
         b)
             BRANCH=$OPTARG
             ;;
         c)
             MAKE_DISTCHECK="yes"
             ;;
         d)
             DOWNLOAD_RULESET="yes"
             ;;
         e)
             EXCLUDE_THESE=$OPTARG
             ;;
         j)
             JUST_THESE=$OPTARG
             ;;
         l)
             LOCAL_REPOSITORY=$OPTARG
             BRANCH=
             REPOSITORY=
             if [ ! -d ${LOCAL_REPOSITORY} ];
             then
                 echo "The supplied local repository -"
                 echo "${LOCAL_REPOSITORY}"
                 echo "does not exist. Please check the name and try again"
                 exit 1
             fi
             ;;
         n)
             NETMAP="yes"
             ;;
         p)
             PFRING="yes"
             ;;
         r)
             REPOSITORY=$OPTARG
             ;;
         f)
             MAKE_DISTCHECK="yes"
             NETMAP="yes"
             PFRING="yes"
             ;;
         *)
             usage
             ;;
     esac
done
shift $((OPTIND -1))

if [ -f sqard_config ];then 
	. sqard_config
  else
  echo " \"sqard_config \" NOT FOUND !! !"
  exit 1;
fi

if [ ! ${STAGING_AREA} ];
then 

    STAGING_AREA="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/staging-area"
    echo "Using the default ${STAGING_AREA} folder location for staging area."
    
else
    
    mkdir -p "${STAGING_AREA}/sources"
    STAGING_TESTS="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/staging-area/tests"
    yes | cp -rf ${STAGING_TESTS} ${STAGING_AREA}
    echo "Using ${STAGING_AREA} folder location for staging area."
fi

if [ ! -d ${RESULT_LOGS} ];
then 

    echo "Creating ${RESULT_LOGS} !"
    mkdir -p ${RESULT_LOGS}
    
fi

if [ ${DOWNLOAD_RULESET} ];
then

    #make sure we start clean
    rm -rf ${STAGING_AREA}/sources/rules/
    echo "Downloading a full ETOpen Suricata ruleset in ${STAGING_AREA}/sources/rules"
    /usr/bin/wget -qO - https://rules.emergingthreats.net/open/suricata-git/emerging.rules.tar.gz | tar -x -z -C ${STAGING_AREA}/sources/ -f - 
    
fi

if [ -d ${STAGING_AREA}/sources/rules ];
then

    echo "Using ${STAGING_AREA}/sources/rules for a full ruleset location"
    
else
    
    echo "${STAGING_AREA}/sources/rules is not present"
    echo "Please use/add the \"-d\" option to your sqard.sh line to download a full ruleset "
    exit 1
    
fi

# add in all the dockers
docker_containers=(${OS_DEBIAN} ${OS_UBUNTU} ${OS_FEDORA} ${OS_CENTOS} ${OS_OPENSUSE})

CONTAINERS_LEFT="yes"

if [ ${LOCAL_REPOSITORY} ];
then 
        
    # if we have a local repo - clean it up first
    rm -rf ${STAGING_AREA}/sources/suricata/*
    cp ${LOCAL_REPOSITORY}/* ${STAGING_AREA}/sources/suricata/ -rf
    #/usr/bin/wget -qO - https://rules.emergingthreats.net/open/suricata-git/emerging.rules.tar.gz | tar -x -z -C "${STAGING_AREA}/sources/" -f -
    
else
    
    # we pull the repository (make sure we start clean first)
    rm -rf ${STAGING_AREA}/sources/suricata/
    git clone -b $BRANCH $REPOSITORY ${STAGING_AREA}/sources/suricata &&  \
    git clone https://github.com/OISF/libhtp.git -b 0.5.x ${STAGING_AREA}/sources/suricata/libhtp
    if [ $? -ne 0 ];
    then 
    
        echo "Could not get the remote repository. Please check the name or connectivity."
        exit 1
        
    fi
    
fi

# make sure we start with a clean log dir
rm -rf ${RESULT_LOGS}

for container in "${docker_containers[@]}"
do
   
   if [  ${JUST_THESE} ] &&  [[ ! ${container} == *"${JUST_THESE}"* ]]; 
   then
       echo "SKIPPING ${container} AS REQUESTED"
       continue
   fi

   # if certain sqard docker name pattern (aka "latest") should be 
   # excluded and current one does not match - skip it.
   if [  ${EXCLUDE_THESE} ] &&  [[ ${container} == *"${EXCLUDE_THESE}"* ]]; 
   then
       echo "SKIPPING ${container} AS REQUESTED"
       continue
   fi

   # check if we have container secific tasks or just generic
   if [ -d ${STAGING_AREA}/tests/${container} ];
   then
       # we have container specific tests - 
       # aka debian vs debian-latest / generic v specific
       staging_os=$(echo ${container}) 
   else
       #we have generic OS tests
       staging_os=$(echo ${container} |awk -F  "-" '{print $1}')
   fi 
   
   # start the docker container build
   docker pull pevma/sqard:${container}
   docker create --name sqard-${container}-01 --entrypoint=/opt/QA/${staging_os}/entrypoint/launch-sequence.sh -ti pevma/sqard:${container} 
   
   container_id=$(docker ps -aqf "name=sqard-${container}-01")
   
   # check if MAKE_DISTCHECK is needed to be included in the run
   if [ ${MAKE_DISTCHECK} ]; 
   then
       rm -rf ${STAGING_AREA}/tests/${staging_os}/sequence/SKIP_MAKE_DISTCHECK
   else
       touch ${STAGING_AREA}/tests/${staging_os}/sequence/SKIP_MAKE_DISTCHECK
   fi
   
   # check if just pfring is needed to be included in the run
   if [ ${PFRING} ] && [ ! ${NETMAP} ]; 
   then
   
       rm -rf ${STAGING_AREA}/tests/${staging_os}/sequence/SKIP_PFRING
       
   else
       
       touch ${STAGING_AREA}/tests/${staging_os}/sequence/SKIP_PFRING
       
   fi
   
   # check if just netmap is needed to be included in the run
   if [ ${NETMAP} ] && [ ! ${PFRING} ]; 
   then
       
       rm -rf ${STAGING_AREA}/tests/${staging_os}/sequence/SKIP_NETMAP
       
   else
       
       touch ${STAGING_AREA}/tests/${staging_os}/sequence/SKIP_NETMAP
       
   fi

   # in case both pfring and netmap are needed - 
   if [ ${NETMAP} ] && [ ${PFRING} ]; 
   then
       
       rm -rf ${STAGING_AREA}/tests/${staging_os}/sequence/SKIP_PFRING_NETMAP
       
   else
       
       touch ${STAGING_AREA}/tests/${staging_os}/sequence/SKIP_PFRING_NETMAP
       
   fi
   
   docker cp ${STAGING_AREA}/tests/${staging_os}/ ${container_id}:/opt/QA/
   docker cp ${STAGING_AREA}/sources/ ${container_id}:/opt/QA/
   docker start sqard-${container}-01 
   
   # make sure we have a log dir
   mkdir -p ${RESULT_LOGS}/${container}
done

while [ "${CONTAINERS_LEFT}" == "yes" ]
do

for container in "${docker_containers[@]}"
do 
   container_id=$(docker ps -aqf "name=sqard-${container}-01")
   
   # if there is a container
   if [ ${container_id} ];
   then
     container_status=$(docker inspect -f {{.State.Status}} ${container_id})
   else 
     continue
   fi
      
   # if the container has exited
   if [ "${container_status}" == "exited" ];
   then
     # one less container left 
     container_exit_code=$(docker inspect -f {{.State.ExitCode}} ${container_id})
     # if container exited gracefuly and ok
     if [ "${container_exit_code}" -eq 0 ];
     then
       docker cp ${container_id}:/opt/QA/results/logs/ ${RESULT_LOGS}/${container}
       docker stop sqard-${container}-01
       docker rm sqard-${container}-01
       CONTAINERS_LEFT="no"
     else
       # else container exited with some err
       # print all available info also
       # take all we have in terms of logs as well.
       docker cp ${container_id}:/opt/QA/results/logs/ ${RESULT_LOGS}/${container}
       docker inspect ${container_id} > ${RESULT_LOGS}/${container}/ERROR_NON_GRACEFUL_CONTAINER_EXIT
       # we still need to stop and remove the container to avoid potential 
       # contamination of the next sqard run
       docker stop sqard-${container}-01
       docker rm sqard-${container}-01
       CONTAINERS_LEFT="no"
       FAILURE=1
     fi
   else
     # else the container is still running (!= "exited")
     # if the count reaches the set limit
     # we need to force the container to exit/stop
     if [ "${COUNTER}" -eq 60 ];
       then
         # take all we have in terms of logs as well.
         docker cp ${container_id}:/opt/QA/results/logs/ ${RESULT_LOGS}/${container}
         docker stop sqard-${container}-01
         docker rm sqard-${container}-01
         touch ${RESULT_LOGS}/${container}/ERROR_FORCED_CONTAINER_EXIT
         FAILURE=1
     else
       let COUNTER=$COUNTER+1;
       CONTAINERS_LEFT="yes"
       echo "Waiting for sqard-${container}-01 to finish"
       sleep 60
       break
     fi     
   fi
    
done

done

if [[ ${FAILURE} -eq 0 ]];
then
    echo "Finished with SUCCESS"
    exit 0 
else
    echo -e "Finished with ERRORS ! \n"
    find ${RESULT_LOGS}/ -type f -name ERROR 
    exit 1
fi
