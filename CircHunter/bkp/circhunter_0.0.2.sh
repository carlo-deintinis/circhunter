#!/bin/bash

echo
echo "==========================================="
echo "          Welcome to CircHunter"
echo "==========================================="

arguments="$*"

# Checking if help was requested or if no argument was supplied
if [[ $1 == "-h" || $1 == "--help" || $# -eq 0 ]] ; then
	eval "bash help.sh"
	exit 0

elif [[ $1 != "f" && $1 != "c" && $1 != "s" && $1 != "r" && $1 != "q" ]] ; then
	echo "Please enter a valid execution mode."
	echo "Use -h or --help for help file."
	exit 1
fi

# Testing for docker installation on system
dockertest="$(which docker)"

if [ -n "$dockertest" ]; then
	echo "Docker installed"
else
	echo "Please install docker"
	exit 1
fi

# Testing for image installation on system
if [[ "$(docker images -q carlodeintinis/circhunter:latest 2> /dev/null)" == "" ]] ; then
	echo "Please install the docker image carlodeintinis/circhunter:latest"
	exit 1
else
	echo "Docker image carlodeintinis/circhunter installed"
fi


if [[ $* != *"-guimode" ]]; then
	echo "CLI MODE: relative paths will be converted into absolute paths"
else
	echo "GRAPHICAL MODE: supplied paths are already absolute"
fi

# BUILDING DOCKER LAUNCHER BODY
# Searching arguments
while [[ $# -gt 1 ]]
do
key="$1"

case $key in
	-cr|--circrna)
	circlocation="$2" # Defining circRNA location
	if [[ $* != *"-guimode" ]]; then
		circlocation="${PWD}/${circlocation}"
	fi
	dockerlauncherbody="$dockerlauncherbody -v ${circlocation}:/circhunter/circRNA"
	shift
	;;

	-sg|--suppliedgenome)
	genomelocation="$2" # Defining genome location to mount with docker
	if [[ $* != *"-guimode" ]]; then
		genomelocation="${PWD}/${genomelocation}"
	fi
	dockerlauncherbody="$dockerlauncherbody -v ${genomelocation}:/circhunter/genome"
	shift
	;;

	-as|--assembly)
	assembly="$2" # Defining assembly variable
	shift
	;;

	-rs|--rnaseq)
	rnaseqlocation="$2" # Defining RNA-seq location to mount with docker
	if [[ $* != *"-guimode" ]]; then
		rnaseqlocation="${PWD}/${rnaseqlocation}"
	fi
	dockerlauncherbody="$dockerlauncherbody -v ${rnaseqlocation}:/circhunter/rnaseq"
	shift
	;;

	-bj|--bksjunctions)
	bksjunctionlocation="$2" # Defining backsplicing junction file to mount with docker
	if [[ $* != *"-guimode" ]]; then
		bksjunctionlocation="${PWD}/${bksjunctionlocation}"
	fi
	dockerlauncherbody="$dockerlauncherbody -v ${bksjunctionlocation}:/circhunter/bksj"
	shift
	;;

	-hc|--hashcirc)
	hashcircargs="$2 $3 $4 $5 $6 $7"
	shift
	;;
esac
shift
done

# GETTING ABSOLUTE PATH OF SCRIPT DIRECTORY
script_abspath=${PWD}/${BASH_SOURCE[0]}
circhunter_wd=${script_abspath: : -14}
echo "Script absolute path: ${script_abspath}"
echo "CircHunter directory to mount: ${circhunter_wd}"

echo
echo "==========================================="
echo "             SUPPLIED ARGUMENTS"
echo "==========================================="
echo "CircRNA file =   ${circlocation}"        # Mounted in /circhunter/circRNA
echo "Genome file =    ${genomelocation}"      # Mounted in /circhunter/genome
echo "RNA-Seq file =   ${rnaseqlocation}"      # Mounted in /circhunter/rnaseq
echo "BKS junctions =  ${bksjunctionlocation}" # Mounted in /circhunter/bksj
echo "Assembly =       ${assembly}"            # No mount
echo "HashCirc args =  ${hashcircargs}"
echo "Arguments =      ${arguments}"           # No mount

#dockerlauncherhead="docker run -i --privileged=true -v ${PWD}/CircHunter:/circhunter"
dockerlauncherhead="docker run -i --privileged=true -v ${circhunter_wd}:/circhunter"
dockerlaunchertail=" carlodeintinis/circhunter /bin/bash /circhunter/functions/launcher.sh ${arguments}"

echo
echo "Docker launcher command"
echo "${dockerlauncherhead}${dockerlauncherbody}${dockerlaunchertail}"
echo


# Launching docker
#eval "${dockerlauncherhead}${dockerlauncherbody}${dockerlaunchertail}"

#eval "rm ${PWD}/circRNA ${PWD}/genome"
