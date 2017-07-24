#!/bin/bash

echo
echo "==========================================="
echo "        Welcome to CircHunter 0.0.5"
echo "==========================================="

arguments="$*"

# Checking if help was requested or if no argument was supplied
if [[ $* == *"-h" || $* == *"--help" || $# -eq 0 || $# -eq 1 ]] ; then
	eval "bash help.sh"
	exit 0
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


if [[ $* != *"-guimode"* ]]; then
	echo "CLI MODE: relative paths will be converted into absolute paths"
else
	echo "GRAPHICAL MODE: supplied paths are already absolute"
fi


# Defining variable for intelligent mountpoints rm and file check
usedfiles=""


# BUILDING DOCKER LAUNCHER BODY
# Parsing arguments

ExModeCheck=false       # Used to check if a valid execution mode was provided
GuiModeCheck=true       # Used to check if CircHunter was launched by the GUI
OutputFolderCheck=false # Used to check if an output folder was provided
TestModeCheck=false     # Used to check if test mode is enabled

# Sets GuiModeCheck to false if the appropriate argument is found
	if [[ $* != *"-guimode"* ]]; then
		GuiModeCheck=false
	fi



while [[ $# -gt 1 ]]
do
key="$1"

case $key in
	-cr|--circrna)
	circlocation="$2" # Defining circRNA location
	if [[ $GuiModeCheck == false ]]; then
		circlocation="${PWD}/${circlocation}"
	fi
	dockerlauncherbody="$dockerlauncherbody -v ${circlocation}:/circhunter/circRNA"
	usedfiles="$usedfiles circRNA"
	shift
	;;

	-sg|--suppliedgenome)
	genomelocation="$2" # Defining genome location to mount with docker
	if [[ $GuiModeCheck == false ]]; then
		genomelocation="${PWD}/${genomelocation}"
	fi
	dockerlauncherbody="$dockerlauncherbody -v ${genomelocation}:/circhunter/genome"
	usedfiles="$usedfiles genome"
	shift
	;;

	-as|--assembly)
	assembly="$2" # Defining assembly variable
	shift
	;;

	-rs|--rnaseq)
	rnaseqlocation="$2" # Defining RNA-seq location to mount with docker
	if [[ $GuiModeCheck == false ]]; then
		rnaseqlocation="${PWD}/${rnaseqlocation}"
	fi
	dockerlauncherbody="$dockerlauncherbody -v ${rnaseqlocation}:/circhunter/rnaseq"
	usedfiles="$usedfiles rnaseq"
	shift
	;;

	-bj|--bksjunctions)
	bksjunctionlocation="$2" # Defining backsplicing junction file to mount with docker
	if [[ $GuiModeCheck == false ]]; then
		bksjunctionlocation="${PWD}/${bksjunctionlocation}"
	fi
	dockerlauncherbody="$dockerlauncherbody -v ${bksjunctionlocation}:/circhunter/bksj"
	usedfiles="$usedfiles bksj"
	shift
	;;

	-id|--isoformdata)
	isoformdata="$2" # Defining backsplicing junction file to mount with docker
	if [[ $GuiModeCheck == false ]]; then
		isoformdata="${PWD}/${isoformdata}"
	fi
	dockerlauncherbody="$dockerlauncherbody -v ${isoformdata}:/circhunter/isoformdata"
	usedfiles="$usedfiles isoformdata"
	shift
	;;

	-hc|--hashcirc)
	hashcircargs="$2 $3 $4 $5 $6 $7"
	shift
	;;

	-of|--outputfolder)
	outputfolder="$2" # Defining backsplicing junction file to mount with docker
	if [[ $GuiModeCheck == false ]]; then
		outputfolder="${PWD}/${outputfolder}"
	fi
	dockerlauncherbody="$dockerlauncherbody -v ${outputfolder}:/output"
	shift
	;;

	-f)
	echo "Execution mode -f: FULL"
	ExModeCheck=true
	;;

	-c)
	echo "Execution mode -c: CLASSIFICATION"
	ExModeCheck=true
	;;

	-s)
	echo "Execution mode -s: SEQUENCES"
	ExModeCheck=true
	;;

	-r)
	echo "Execution mode -r: RNA-Seq hash"
	ExModeCheck=true
	;;

	-q)
	echo "Execution mode -q: Fasta to Fastq conversion"
	ExModeCheck=true
	;;

	--test)
	echo "Execution mode --test: used to test circhunter.sh execution. No docker launch."
	ExModeCheck=true
	TestModeCheck=true
	;;

esac
shift
done

if [ "$check" == false ]; then
	echo "No valid execution mode was provided."
	echo "Please type -h or --help to \"git gud\"."
	exit 1
fi


# Getting absolute path of script directory
script_abspath=${PWD}/${BASH_SOURCE[0]}
circhunter_wd=${script_abspath: : -14}
echo "Script absolute path: ${script_abspath}"
echo "CircHunter directory to mount: ${circhunter_wd}"

echo
echo "==========================================="
echo "             SUPPLIED ARGUMENTS"
echo "==========================================="
echo "CircRNA file  =  ${circlocation}"        # Mounted in /circhunter/circRNA
echo "Genome file   =  ${genomelocation}"      # Mounted in /circhunter/genome
echo "RNA-Seq file  =  ${rnaseqlocation}"      # Mounted in /circhunter/rnaseq
echo "BKS junctions =  ${bksjunctionlocation}" # Mounted in /circhunter/bksj
echo "Isoform data  =  ${isoformdata}"         # Mounted in /circhunter/isoformdata
echo "Output folder =  ${outputfolder}"        # Mounted in /circhunter/output
echo "Assembly      =  ${assembly}"            # No mount
echo "HashCirc args =  ${hashcircargs}"        # No mount
echo "Arguments     =  ${arguments}"           # No mount

#dockerlauncherhead="docker run -it --privileged=true -v ${PWD}/CircHunter:/circhunter"
dockerlauncherhead="docker run -i --privileged=true -v ${circhunter_wd}:/circhunter"
dockerlaunchertail=" carlodeintinis/circhunter /bin/bash /circhunter/functions/launcher.sh ${arguments}"

echo
echo "Docker launcher command"
echo "${dockerlauncherhead}${dockerlauncherbody}${dockerlaunchertail}"
echo


# Checking for file existance
for file in $usedfiles; do
	case $file in
		circRNA)
		if [ ! -f "${circlocation}" ]; then
			echo "ERROR: the following $file file does not exist"
			echo "${circlocation}"
			exit 1
		fi
		;;

		genome)
		if [ ! -f "${genomelocation}" ]; then
			echo "ERROR: the following $file file does not exist"
			echo "${genomelocation}"
			exit 1
		fi
		;;

		rnaseq)
		if [ ! -f "${rnaseqlocation}" ]; then
			echo "ERROR: the following $file file does not exist"
			echo "${rnaseqlocation}"
			exit 1
		fi
		;;

		bksj)
		if [ ! -f "${bksjunctionlocation}" ]; then
			echo "ERROR: the following $file file does not exist"
			echo "${bksjunctionlocation}"
			exit 1
		fi
		;;

	esac
done

# Launching docker
if [[ $TestModeCheck == false ]]; then
	eval "${dockerlauncherhead}${dockerlauncherbody}${dockerlaunchertail}"
else
	echo "Test mode enabled: Docker not launched"
fi

# Deleting used mountpoints
for file in $usedfiles; do
	if [ -f "${circhunter_wd}/$file" ]; then
		rm -f -v "${circhunter_wd}/${file}"
	else
		echo "$file will not be removed"
		echo "${circhunter_wd}/${file}"
	fi
done

