#!/bin/bash

set -e
kind create cluster --config=kind_deploy.yml
# Wait for cluster pods (all 9)
# TODO these sleeps may not be long enough - haven't tested
sleep 10
kubectl get pods -A
helm install openebs --namespace openebs openebs/openebs --create-namespace
# Wait for openebs pods
sleep 5
make deploy
# Wait for app pods
sleep 5

# Expose rmq for logstash (should do this by changing the yamls, or kubectl proxy, or something)
RMQ=$(kubectl get pods -l app=rabbitmq --no-headers -o custom-columns=":metadata.name")
# In a loop to restart forwarding if channel closes
while true; do kubectl port-forward $RMQ 5672:5672; done # not sure how to get 8080:15672 working for UI...

# LEFT OFF:
# modify one of the tt svcs to publish msgs to logstash (create exchange first, or do that in logstash)
