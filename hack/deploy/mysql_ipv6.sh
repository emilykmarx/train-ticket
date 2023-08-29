#!/bin/bash

set -e

for pod in $(kubectl get pods --no-headers -o custom-columns=":metadata.name" | grep $1); do
  echo "Adding root@::1 to $pod"
  kubectl exec $pod -- mysql -uroot -e "CREATE USER 'root'@'::1' IDENTIFIED WITH mysql_native_password BY '' ; GRANT ALL ON *.* TO 'root'@'::1' WITH GRANT OPTION ;"
  kubectl exec $pod -c xenon -- /sbin/reboot
done
