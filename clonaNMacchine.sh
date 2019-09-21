#!/bin/bash


for node in $(pvesh get /nodes --output-format=json-pretty 2>/dev/null | jq '.[] | "\(.node)"' | cut '-d"'  -f2 )
do
    for vmid in $(pvesh get /nodes/"$node"/qemu --output-format=json-pretty 2>/dev/null | jq '.[] | "\(.vmid)"' | cut '-d"' -f2 )
    do
       if [ $vmid == "$1" ]
       then
          status=$(pvesh get /nodes/"$node"/qemu/"$vmid"/status/current --output-format=json-pretty 2>/dev/null | jq '. | "\(.status)"' | cut '-d"' -f2)

          if [ $status == 'running' ]
          then
             echo "La macchina  e' accesa. La si vuole spegnere per clonarla?"
             read result
             if [ $result == 'si' ]
             then
                qm shutdown "$1"
                sleep 30s
                ./clonaNMacchine.sh "$1" "$2"
             else
                exit $?
             fi
          elif [ $status == 'stopped' ]
          then
             echo "Si sta per clonare la macchina $1 per $2 volte"
             for num in `seq 1 "$2"`
             do
                newid=$(pvesh get /cluster/nextid)
                newname="$1"-copy-n-"$num"
                ./clona.sh "$node" "$1" "$newid" "$newname"
                sleep 2s
                echo "Creata la macchina con id $newid e nome $newname"
             done
          else
             exit $?
          fi
       fi
    done
done
