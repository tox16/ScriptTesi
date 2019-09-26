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
                ./replicaMacchina.sh "$1"
             else
                exit $?
             fi
          elif [ $status == 'stopped' ]
          then
             echo "Inserire il vmid della nuova macchina: "
             read newid
             echo "Inserire il nome della nuova macchina: "
             read nome
             count=`echo -n $nome | wc -c`
             storage=$(pvesh get /nodes/"$node"/qemu/"$vmid"/config --output-format=json-pretty 2>/dev/null | jq '. | "\(.ide2)"' | cut '-d"' -f2 | cut -d: -f1)
             if [ $storage != 'local' ]
             then
                echo "Inserire il nome del nodo dove si vuole salvare la macchina: "
                read node
                countNode=`echo -n "$node" | wc -c`
                if [ "$count" -gt 0 ]
                then
                   if [ "$countNode" -gt 0 ]
                   then
                      pvesh create /nodes/"$node"/qemu/"$vmid"/clone --newid "$newid" --name "$nome" --target "$node"
                   else
                      pvesh create /nodes/"$node"/qemu/"$vmid"/clone --newid "$newid" --name "$nome"
                   fi
                elif [ "$countNode" -gt 0]
                then
                   pvesh create /nodes/"$node"/qemu/"$vmid"/clone --newid "$newid" --name "$nome"
                else
                   pvesh create /nodes/"$node"/qemu/"$vmid"/clone --newid "$newid"
                fi
             fi
             if [ "$count" == 0 ]
             then
                echo "è stato inserito solo il vmid"
                pvesh create /nodes/"$node"/qemu/"$vmid"/clone --newid "$newid"
             else
                echo "Sono stati inseriti nome e vmid"
                pvesh create /nodes/"$node"/qemu/"$vmid"/clone --newid "$newid" --name "$nome"
             fi
          else
             exit $?
          fi
       fi
    done
done
