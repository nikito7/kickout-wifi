#!/bin/sh
### kickout.sh #####

signal=-80
maclist="mac1 mac2"

function kick () {
mac=$1
dev=$2
echo kicked $1 with $3 at $2 | logger
ubus call hostapd.$dev del_client "{'addr':'$mac', 'reason':5, 'deauth':false, 'ban_time':0}"
}

### kickout.sh #####

devlist=$(ifconfig | grep wlan | grep -v sta | awk '{ print $1 }')

###
for mac in $maclist
do
####
for dev in $devlist
do
stalist=""
stalist=$(iw $dev station dump | grep Station | awk '{ print $2 }')
#####
for sta in $stalist
do
rssi=$(iw $dev station get $sta | grep "signal avg" | awk '{ print $3 }')
if [ $sta = $mac ] && [ $rssi -lt $signal ]
then
kick $mac $dev $rssi
fi
done
#####
done
####
done
###

sleep 8

/bin/sh $0 &

###
##
#

