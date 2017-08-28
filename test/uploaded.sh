#!/bin/sh

# Upload pipeline
fly -t docker sp -p test  -c tests/test-pipeline.yml -n
# unpause pipeline
fly -t docker unpause-pipeline -p test
# Trigger job
fly -t docker trigger-job -j test/job-hello-world
COUNTER=0
pending() { /Users/ahelal/bin//fly -t docker builds | grep test/job-hello-world | grep pending; }
pending
pending_rc=$?
while [ "${pending_rc}" = "0" ]; do
    sleep 2
    pending
    pending_rc=$?
    echo The counter is $COUNTER
    let COUNTER=COUNTER+1
done


# Check if
fly -t docker builds | grep test/job-hello-world | grep succeeded