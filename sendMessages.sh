#!/bin/bash 

for i in {1..10}; do az storage message put --auth-mode login --queue-name daprtest --account-name mfdaprstore01 --content $i; done
