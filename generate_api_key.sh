#!/bin/bash
#Title: generate_api_key.sh
#Purpose: Generate an API Key
#Date: 10/10/2017
#Version: 1.0
#Author: Daniel Oh
#Usage: ./generate_api_key.sh -a <ip address> -s <sub> -n <source system name> -e <environment> -c <color> [-d <duration_in_seconds>] [-i <iat>]

##########################################################################
##########################################################################

#If no parameters are given, prompt usage

usage='Usage: ./generate_api_key.sh -a <ip address> -s <sub> -n <source system name> -e <environment> -c <color> [-d <duration_in_seconds>] [-i <iat>] -u <user>'

if [ "$#" -eq 0 ];
then
    echo $usage
    exit 0
    fi

#Map the flag arguments to a variable
#Flag argument is put as a variable first, instead of making the variable equal to the curl parameter value, in case of the variable is needed elsewhere

while getopts :a:s:n:e:c:u:d:i:h option
do
 case "${option}"
 in
 h) echo $usage
    exit 0
    ;;
 a) a=${OPTARG};;
 s) s=${OPTARG};;
 n) n=${OPTARG};;
 e) e=${OPTARG};;
 c) c=${OPTARG};;
 u) u=${OPTARG};;
 d) d=${OPTARG};;
 i) i=${OPTARG};;
 ?) printf "Invalid option -%s\n" "$OPTARG" >&2
    echo "$usage" >&2
    exit 0
    ;;
 esac
done

#Map the flag variable to the curl parameter
#Required Arguments

ip=$a
sub="sub=$s"
sn="sn=$n"
env="env=$e"
color="color=$c"
user=$u

#Optional Arguments

duration="&duration=$d"
iat="&iat=$i"

#Curl using the Rest API to hit the generateApiKey service with user inputted arguments

curl -kD - "https://$ip:8443/generateApiKey?$sub&$sn&$env&$color$duration$iat" -u $user
