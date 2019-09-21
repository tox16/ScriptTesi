#!/bin/bash

for node in $(pvesh get /nodes --output-format=json-pretty 2>/dev/null | jq '.[] | "\(.node)"' | cut '-d"' -f2 )
do
if [  $1 == 'qemu'  ];
then
   if [  $2 == 'running'  ];
   then
      for vmid in $(pvesh get /nodes/"$node"/qemu --output-format=json-pretty 2>/dev/null | jq '.[] | "\(.vmid)"' | cut '-d"' -f2 )
      do
        status=$(pvesh get /nodes/"$node"/qemu/"$vmid"/status/current --output-format=json-pretty 2>/dev/null | jq '. | "\(.status)"' | cut '-d"' -f2)
        if [ $status == 'running' ]
        then
             pvesh get /nodes/"$node"/qemu/"$vmid"/config --output-format=json-pretty 2>/dev/null | jq '. | "Nome macchina: \(.name)"' | cut '-d"' -f2
             pvesh get /nodes/"$node"/qemu/"$vmid"/status/current --output-format=json-pretty 2>/dev/null | jq '. | "VMID: \(.vmid) + Uptime: \(.uptime)"' | cut '-d"' -f2
             echo "-----------------------------------------"
        fi
      done
   elif [  $2 == 'stopped'  ];
   then
     for vmid in $(pvesh  get /nodes/"$node"/qemu --output-format=json-pretty 2>/dev/null | jq '.[] | "\(.vmid)"' | cut '-d"' -f2 )
     do
       status=$(pvesh get /nodes/"$node"/qemu/"$vmid"/status/current --output-format=json-pretty 2>/dev/null | jq '. | "\(.status)"' | cut '-d"' -f2)
       if [ $status == 'stopped' ]
       then
            pvesh get /nodes/"$node"/qemu/"$vmid"/config --output-format=json-pretty 2>/dev/null | jq '. | "Nome macchina: \(.name)"'  | cut '-d"' -f2
            pvesh get /nodes/"$node"/qemu/"$vmid"/status/current --output-format=json-pretty 2>/dev/null | jq '. | "VMID: \(.vmid) + Uptime: \(.uptime)"' | cut '-d"' -f2
            echo "------------------------------------------"
       fi
     done
   else
      echo "Le macchine virtuali disponibili sono: "
      pvesh get /nodes/"$node"/qemu --output-format=json-pretty 2>/dev/null | jq '.[] | "Nome: \(.name) + VMID:  \(.vmid) + Stato: \(.status)"' | cut '-d"' -f2
   fi
elif [  $1 == 'lxc' ];
then
   if [  $2 == 'running'  ];
   then
    for vmid in $(pvesh get /nodes/"$node"/lxc --output-format=json-pretty 2>/dev/null | jq '.[] | "\(.vmid)"' | cut '-d"' -f2 )
    do
      status=$(pvesh get /nodes/"$node"/lxc/"$vmid"/status/current --output-format=json-pretty 2>/dev/null | jq '. | "\(.status)"' | cut '-d"' -f2)
      if [ $status == 'running' ]
      then
           pvesh get /nodes/"$node"/lxc/"$vmid"/config --output-format=json-pretty 2>/dev/null | egrep hostname | awk '{ print $3 }' | cut '-d"' -f2
      fi
     done
   elif [  $2 == 'stopped'  ];
   then
    for vmid in $(pvesh get /nodes/"$node"/lxc --output-format=json-pretty 2>/dev/null | jq '.[] | "\(.vmid)"' | cut '-d"' -f2 )
    do
      status=$(pvesh get /nodes/"$node"/lxc/"$vmid"/status/current --output-format=json-pretty 2>/dev/null | jq '. | "\(.status)"' | cut '-d"' -f2)
      if [ $status == 'stopped' ]
      then
         pvesh get /nodes/"$node"/lxc/"$vmid"/config --output-format=json-pretty 2>/dev/null | egrep hostname | awk '{ print $3 }' | cut '-d"' -f2
      fi
    done
   else
      pvesh get /nodes/"$node"/lxc --output-format=json-pretty 2>/dev/null | jq '.[] | "Nome: \(.name) + VMID:  \(.vmid) + Mem Libera: \(.mem)"'  | cut '-d"' -f2
   fi
else
      pvesh get /nodes/"$node"/qemu --output-format=json-pretty 2>/dev/null | jq '.[] | "Nome: \(.name) + VMID:  \(.vmid)"' | cut '-d"' -f2
      pvesh get /nodes/"$node"/lxc --output-format=json-pretty 2>/dev/null | jq '.[] | "Nome: \(.name) + VMID:  \(.vmid)"' | cut '-d"' -f2
fi
done
