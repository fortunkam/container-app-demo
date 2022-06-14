#!/bin/bash 

for i in {1..2}; do az storage message put --auth-mode login --queue-name "ca-sa-queue-input" --account-name "cappmfimqpyajp2usy2" --content $i; done
