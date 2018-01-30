# ca-api-gateway

Scripts that use the CA API Gateway Rest API to automate configuration and administration of the CA API Gateway.

### Pre-requisites

* An instance of the CA API Gateway able to be hit over port 8443

* Rest Managent API Service installed on the Gateway

* Policy Manager Administrative User Credentials


### Running a Script

Script usage is prompted when running the script with no parameters.

```
./create_policy_manager_admin.sh

Usage: ./create_policy_manager_admin.sh [-a <single ip>] [-l <server list> -u <user> -n <new user to create> -t <temp pw>
```
