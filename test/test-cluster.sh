#!/bin/sh
set -e

# Create
KITCHEN_YAML=.kitchen-cluster.yml bundle exec kitchen create web-ubuntu1804
KITCHEN_YAML=.kitchen-cluster.yml bundle exec kitchen create worker-ubuntu1804

# Converge
KITCHEN_YAML=.kitchen-cluster.yml bundle exec kitchen converge web-ubuntu1804 -l debug
KITCHEN_YAML=.kitchen-cluster.yml bundle exec kitchen converge worker-ubuntu1804 -l debug
# run again
KITCHEN_YAML=.kitchen-cluster.yml bundle exec kitchen converge web-ubuntu1804

# pause a little
sleep 10

# Verify
KITCHEN_YAML=.kitchen-cluster.yml bundle exec kitchen verify worker
KITCHEN_YAML=.kitchen-cluster.yml bundle exec kitchen verify web

# destory
KITCHEN_YAML=.kitchen-cluster.yml bundle exec kitchen destroy web
KITCHEN_YAML=.kitchen-cluster.yml bundle exec kitchen destroy worker
