#!/bin/bash

echo
echo -e "\e[1mDOCKER CONTAINER CLEANER\e[0m"
echo

containers="$(docker ps -a | grep -ve 'WARNING\|CONTAINER' | awk -v OFS='\t' '{print $1}' | tr '\n' ' ')"
eval "docker rm ${containers}"
echo "Executed. Now showing containers"
eval "docker ps -a"
