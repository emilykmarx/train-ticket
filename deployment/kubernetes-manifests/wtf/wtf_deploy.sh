#!/bin/bash

set -e

# TrainTicket
kind create cluster --config=kind_deploy.yml
# Wait for cluster pods (all 9)
# TODO these sleeps are likely not long enough - haven't tested
sleep 10
kubectl get pods -A
helm install openebs --namespace openebs openebs/openebs --create-namespace
# Wait for openebs pods
sleep 10
pushd ../../..
make deploy
popd
# Wait for app pods
sleep 10

# Expose rmq for logstash (should do this by changing the yamls, or kubectl proxy, or running logstash in the same cluster, or something)
RMQ=$(kubectl get pods -l app=rabbitmq --no-headers -o custom-columns=":metadata.name")
# In a loop to restart forwarding if channel closes
while true; do kubectl port-forward $RMQ 5672:5672; done # not sure how to get 8080:15672 working for UI...

# ELK
