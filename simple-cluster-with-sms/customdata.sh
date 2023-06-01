#!/bin/bash
clish -c 'set user admin shell /bin/bash' -s
config_system -s 'install_security_gw=false&install_ppak=false&gateway_cluster_member=false&install_security_managment=true&install_mgmt_primary=true&install_mgmt_secondary=false&download_info=true&hostname=ckpmgmt&mgmt_gui_clients_radio=any&mgmt_admin_radio=gaia_admin&maintenance_hash=grub.pbkdf2.sha512.10000.A3D229C6F88ACCD24673151593E43F79146507F234248B4209786647E665F2867125FE5FE333BF6FDAAE188D911812AD781A28DC9528F2CD542F8784F5981525.3ADE2C22CD1C54AF68E0832B8AEC39CE8C0F19DE0024760C23B5D33106553566B2D7C9B2FCB35B888EB9109AA09AFDC70D3139037063D39F543222C94E07D394'
while true; do
    status=`api status |grep 'API readiness test SUCCESSFUL. The server is up and ready to receive connections' |wc -l`
    echo "Checking if the API is ready"
    if [[ ! $status == 0 ]]; then
         break
    fi
       sleep 15
    done
echo "API ready " `date`
sleep 5
echo "Set R80 API to accept all ip addresses"
mgmt_cli -r true set api-settings accepted-api-calls-from "All IP addresses" --domain 'System Data'
echo "Restarting API Server"
api restart
