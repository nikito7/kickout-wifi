#!/bin/sh

### kickout.sh #####

noise=-95
snr=10

maclist="00:00:00:00:00:00 00:00:00:00:00:00"

function kick () {
mac=$1
dev=$2
echo kicked $1 with $3 snr: $4 at $2 | logger
ubus call hostapd.$dev \
del_client "{'addr':'$mac', \
'reason':5, 'deauth':true, 'ban_time':0}"
}

devlist=$(ifconfig | grep wlan | \
grep -v sta | awk '{ print $1 }')

####
for dev in $devlist
do
stalist=""; stalist=$(iw $dev station dump | \
grep Station | awk '{ print $2 }')
####
for sta in $stalist
do
echo "$maclist" | grep -q -e $sta
if  [ $? -eq 0 ]
then
rssi=""; rssi=$(iw $dev station get $sta | \
grep "signal avg" | awk '{ print $3 }')
result=$(( $rssi - $noise ))
if [ $result -lt $snr ]
then
kick $sta $dev $rssi $result
fi
fi
####
done
done
####

sleep 9; /bin/sh $0 &

###
##
#

