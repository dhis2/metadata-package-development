#!/bin/bash
cd ../metadata
FILES=$(ls -lhno ./*/*_conf.json | awk '{print $8}' | xargs)
d2metapack $FILES
