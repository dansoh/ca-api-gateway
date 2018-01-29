#!/bin/bash
#Title: change_policy_manager_password.sh
#Purpose: Change Policy Manager Password via REST API
#Date: 10/30/2017
#Version: 1.0
#Author: Daniel Oh
#Usage: ./change_policy_manager_password.sh [-a <single ip>] [-l <server list>] -u <user> -n <user account to modify> -t <new password>
#
#
##########################################################################
##########################################################################

#Prompt usage if no parameters given

usage='Usage: ./change_policy_manager_password.sh [-a <single ip>] [-l <server list> -u <user> -n <user account to modify> -t <new password>'

if [ "$#" -eq 0 ];
then
    echo $usage
    exit 0
    fi

#Map flag argument to variable

while getopts :a:l:u:n:t:h option
do
 case "${option}"
 in
 h) echo $usage
    exit 0
    ;;
 a) a=${OPTARG};;
 l) l=${OPTARG};;
 u) u=${OPTARG};;
 n) n=${OPTARG};;
 t) t=${OPTARG};;
 ?) printf "Invalid option -%s\n" "$OPTARG" >&2
    echo "$usage" >&2
    exit 0
    ;;
 esac
done

#Prompt for User Password and then Base64 encode

read -s -p "$u's password: " PW
base64=$(echo -n $u:$PW| base64)

#Find User ID
id=$(curl -ki https://$a:8443/restman/1.0/identityProviders/0000000000000000fffffffffffffffe/users/ -H "Authorization: Basic $base64" | grep $n -a1 | grep Id | cut -d">" -f2 | cut -d"<" -f1)

#Change Password for Given User for a single IP
if [ -z "$l" ];
then
curl -ki https://$a:8443/restman/1.0/identityProviders/0000000000000000fffffffffffffffe/users/$id/password -X PUT -H "Content-Type: application/xml" -H "Authorization: Basic $base64" -d "$t"
fi

#Change User for Given User for a list of IPs
if [ -z "$a" ];
then
	while read line
	do
		curl -ki https://$a:8443/restman/1.0/identityProviders/0000000000000000fffffffffffffffe/users/$id/password -X PUT -H "Content-Type: application/xml" -H "Authorization: Basic $base64" -d "$t"
	done < $l
fi
