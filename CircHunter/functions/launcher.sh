#!/bin/sh

arguments=$*

echo
echo "NOW INSIDE DOCKER"
cd circhunter/functions

echo "R script arguments:      $arguments"
echo "Current folder:          ${PWD}"

launcher="Rscript main.R ${arguments}"
echo
echo "Wil launch R script with the following command"
echo "$launcher"

eval $launcher
