#!/bin/bash
#Title: create_policy_manager_admin.sh
#Purpose: Create Policy Manager User with Admin Role via REST API
#Date: 10/17/2017
#Version: 1.0
#Author: Daniel Oh
#Usage: ./create_policy_manager_admin.sh [-a <single ip>] [-l <server list>] -u <user> -n <new user to create> -t <temp pw>
#
#
##########################################################################
##########################################################################

#Prompt usage if no parameters given

usage='Usage: ./create_policy_manager_admin.sh [-a <single ip>] [-l <server list> -u <user> -n <new user to create> -t <temp pw>'

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

#Create User and Give Admin Role to Single IP
if [ -z "$l" ];
then
curl -ki https://$a:8443/restman/1.0/identityProviders/0000000000000000fffffffffffffffe/users -H "Content-Type: application/xml" -d "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>
<l7:User providerId=\"0000000000000000fffffffffffffffe\" xmlns:l7=\"http://ns.l7tech.com/2010/04/gateway-management\">
            <l7:Login>$n</l7:Login>
            <l7:Password>$t</l7:Password>
        </l7:User>" -X POST -H "Authorization: Basic $base64"

curl -ki https://$a:8443/restman/1.0/roles/0000000000000000ffffffffffffff9c/assignments -H "Content-Type: application/xml" -d  "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>
<l7:AddAssignmentsContext xmlns:l7=\"http://ns.l7tech.com/2010/04/gateway-management\">
       <l7:assignments>
         <l7:assignment>
            <l7:providerId>0000000000000000fffffffffffffffe</l7:providerId>
              <l7:identityName>$n</l7:identityName>
               <l7:entityType>User</l7:entityType>
                </l7:assignment>
            </l7:assignments>
        </l7:AddAssignmentsContext>" -X PUT -H "Authorization: Basic $base64"
fi

#Create User and Give Admin Role to Single IP
if [ -z "$a" ];
then
	while read line
	do
		curl -ki https://$line:8443/restman/1.0/identityProviders/0000000000000000fffffffffffffffe/users -H "Content-Type: application/xml" -d "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>
       		 <l7:User providerId=\"0000000000000000fffffffffffffffe\" xmlns:l7=\"http://ns.l7tech.com/2010/04/gateway-management\">
           		 <l7:Login>$n</l7:Login>
           		 <l7:Password>$t</l7:Password>
        		</l7:User>" -X POST -H "Authorization: Basic $base64";

		curl -ki https://$line:8443/restman/1.0/roles/0000000000000000ffffffffffffff9c/assignments -H "Content-Type: application/xml" -d  "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>
       		 <l7:AddAssignmentsContext xmlns:l7=\"http://ns.l7tech.com/2010/04/gateway-management\">
            		<l7:assignments>
               		 <l7:assignment>
                    		<l7:providerId>0000000000000000fffffffffffffffe</l7:providerId>
                    		<l7:identityName>$n</l7:identityName>
                  		  <l7:entityType>User</l7:entityType>
               		 </l7:assignment>
           		 </l7:assignments>
       		 </l7:AddAssignmentsContext>" -X PUT -H "Authorization: Basic $base64"
	done < $l
fi
