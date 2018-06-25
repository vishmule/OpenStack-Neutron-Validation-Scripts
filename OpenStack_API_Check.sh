#!/bin/bash

HOST_IP=192.168.56.105

ADMIN_TOKEN=$(\
curl http://192.168.56.105:5000/v3/auth/tokens \
    -s \
    -i \
    -H "Content-Type: application/json" \
    -d '
{
    "auth": {
        "identity": {
            "methods": [
                "password"
            ],
            "password": {
                "user": {
                    "domain": {
                        "name": "Default"
                    },
                    "name": "admin",
                    "password": "openstack"
                }
            }
        },
        "scope": {
            "project": {
                "domain": {
                    "name": "Default"
                },
                "name": "admin"
            }
        }
    }
}' | grep ^X-Subject-Token: | awk '{print $2}' )

#STORE TOKEN
header='X-Auth-Token: '$ADMIN_TOKEN

#NOW USE the AUTH TOKEN TO CHECK TENANTS
curl -X GET http://$HOST_IP:5000/v2.0/tenants/ -H "$header" | python -m json.tool

#NOW USE the AUTH TOKEN TO CHECK NETWORK DETAILS.
curl -H "Content-Type: application/json" -H "$header" -X GET http://$HOST_IP:9696/v2.0/networks | python -m json.tool

