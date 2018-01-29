#!/bin/bash
#Title: import_xml_bundle.sh
#Purpose: Import Bundle(Policies/Services/CWP) from CA API Gateway via Rest API
#Date: 10/11/2017
#Version: 1.0
#Author: Daniel Oh
#Usage: ./import_xml_bundle.sh -a <ip address> -u <user> -p <path of full git bundle> [-f <result_filename>]
#Notes: Pre-Requisite: User must have a full bundle from git to make this work. A bundle extracted by the extract_xml_bundle.sh script is not sufficient.
#	Use the result file after running this script to look for errors
#	Ex. grep -i error result
#	result file is cleared by the script prior to writing to it
##########################################################################
##########################################################################

#Prompt usage if no parameters given

usage='Usage: ./import_xml_bundle.sh -a <ip address> -u <user> -p <path of full git bundle> [-f <custom result file>]'

if [ "$#" -eq 0 ];
then
    echo $usage
    exit 0
    fi

#Map flag arguments to variable

while getopts :a:u:p:f:h option
do
 case "${option}"
 in
 h) echo $usage
    exit 0
    ;;
 a) a=${OPTARG};;
 u) u=${OPTARG};;
 p) p=${OPTARG};;
 f) f="_"${OPTARG};;
 ?) printf "Invalid option -%s\n" "$OPTARG" >&2
    echo "$usage" >&2
    exit 0
    ;;
 esac
done

#Prompt for User's Password and then Base64 encode

read -s -p "$u's password: " PW
base64=$(echo -n $u:$PW| base64)

#Erase contents of result file, create one if it doesn't exist
> result$f

#For loop that uses the CA API Gateway Rest API to import the bundle into the designated gateway

for i in $p/folders/* $p/policies/* $p/services/* ; do for ip in $a ; do echo $i >> result$f; curl -kD - -H "Authorization: Basic $base64" -H "Content-type: application/xml" -X PUT https://$ip:9443/restman/1.0/bundle --data @$i >> result$f ; done; done
