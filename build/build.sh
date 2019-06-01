#!/bin/bash
BASEDIR=`dirname "$0"`
PROJECT_ROOT_DIR=$BASEDIR/..
IMAGE_VERSION=`date '+%Y%m%d%H%M'`
RESTART_REMOTE_STAGE="false"
PROJECT_NAME="puppeteer_application"


showHelp() {
cat << EOF  
Build application

-h,         		--help                  

-v,                 --image_version

-r,         		--restart_remote_stage        
          
EOF
}

options=$(getopt -l "restart_remote_stage:,image_version:,help" -o "r:v:h" -a -- "$@")

eval set -- "$options"

# extract options and their arguments into variables.
while true ; do
    case "$1" in
    	-h|--help)
    		showHelp ; exit 0 ;;
        -r|--restart_remote_stage)
            RESTART_REMOTE_STAGE=$2 ; shift 2 ;;
        -v|--image_version)
            IMAGE_VERSION=$2; shift 2 ;;
        --) shift ; break ;;
		*) echo "Invalid command option: $1" ; exit 1 ;;
    esac
done

#a. prepare
pushd $PROJECT_ROOT_DIR > /dev/null
git pull
popd > /dev/null

#1. build
pushd $PROJECT_ROOT_DIR > /dev/null
sudo docker build --tag="docker-registry.buckyang.com:5050/node-$PROJECT_NAME:latest" 
sudo docker push docker-registry.buckyang.com:5050/node-$PROJECT_NAME:latest
popd > /dev/null	



if [[ $RESTART_REMOTE_STAGE == "true" ]]
then
	echo "Restart remote stage!!!!!!!!!!!!!!!"
	ssh scm.buckyang.com "/opt/gitrepo/server_config/bin/dockerManagement.sh -i tomcat-$PROJECT_NAME -o pullup"
fi
