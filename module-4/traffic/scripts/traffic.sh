#!/usr/bin/env bash
#
#GW_DOMAIN="exclusive-quokka-s9q2my.b0mlgjly.traefikhub.io"

random() {
        NUMBER=$RANDOM
        let "NUMBER%=$1"

        echo $NUMBER
}

call() {
   METHOD=$1
   HPATH=$2
   RDNB=$3
   NB=$(random $RDNB)

   echo "$HPATH => "


   # add 10 to have a minimum of 10 for the -c option of hey
   let "NB+=10"
   hey -m "$METHOD" -c 10 -n $NB \
        -H 'accept: application/json' \
        -H "Authorization: Bearer $TOKEN" "https://$GW_DOMAIN$HPATH" | grep responses
   echo ""

}

for (( ; ; ))
do
 call 'GET' "/customers" 1000 2
 call 'GET' "/flights" 1000 5
 call 'GET' "/tickets" 1000 2
 call 'POST' "/tickets" 1000 2
 call 'POST' "/employees" 1000 2

 sleep 2;
done;