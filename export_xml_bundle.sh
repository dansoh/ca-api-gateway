#!/bin/bash
#Title: export_xml_bundle.sh
#Purpose: Export Bundle(Policies/Services/CWP) from CA API Gateway via REST API
#Date: 10/11/2017
#Version: 1.0
#Author: Daniel Oh
#Usage: ./export_xml_bundle.sh -a <ip address> -u <user> -p <path of id_mapping_file/ENV> -f <folder to create where export will be stored>'
#Notes: Pre-requisite: In order for this script to work, the user must have the id_mapping_file folder with service ID mappings to the correct environment
#
#
##########################################################################
##########################################################################

#Prompt usage if no parameters given

usage='Usage: ./export_xml_bundle.sh -a <ip address> -u <user> -p <path of id_mapping_file/ENV> -f <folder to create where export will be stored>'

if [ "$#" -eq 0 ];
then
    echo $usage
    exit 0
    fi

#Map flag argument to variable

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
 f) f=${OPTARG};;
 ?) printf "Invalid option -%s\n" "$OPTARG" >&2
    echo "$usage" >&2
    exit 0
    ;;
 esac
done

#Prompt for User Password and then Base64 encode

read -s -p "$u's password: " PW
base64=$(echo -n $u:$PW| base64)

#Creates the folder to save the exported policies and services

mkdir -p $f/{policies,services}


#For loop that exports the policies from the given IP via Restman and saves it inside the given directory path2

export IP=$a

for TYPE in policies services
do FILE=$p/${TYPE}_id_to_name
if [ "${TYPE}" = "policies" ]
then URL=policy
SINGULAR_TYPE=POLICY
else URL=service
SINGULAR_TYPE=SERVICE
fi
for line in `cat $FILE`
do ID=$(echo $line | cut -d':' -f1)
BUNDLE_NAME=$(echo $line | cut -d':' -f2)
curl -k https://${IP}:9443/restman/1.0/bundle/${URL}/${ID} -H "Authorization: Basic $base64" | sed '3,8d' | sed '2s/Item/Bundle/' | sed '/CLUSTER_PROPERTY/{N
s/\(CLUSTER_PROPERTY.*\n.*Properties.*\)/\1\n\t\t\t<l7:Property key="FailOnNew">\n\t\t\t\t<l7:BooleanValue>true<\/l7:BooleanValue>\n\t\t\t<\/l7:Property>/}' | sed 's#\(.*action="\)NewOrExisting\(".*type="SECURE_PASSWORD">$\)#\1Ignore\2#g' | sed 's#\(.*action="\)NewOrExisting\(".*type="SSG_KEY_ENTRY">$\)#\1Ignore\2#g' | sed "s#\(.*action=\"\)NewOrExisting\(\".*type=\"${SINGULAR_TYPE}\"/>$\)#\1NewOrUpdate\2#g" | sed "s# srcUri=\".*\" # #g" | head -n -2 > $f/${TYPE}/${BUNDLE_NAME}_bundle.xml
done
done
