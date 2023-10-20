#!/bin/bash
if [ ! -f generate-unique-machine-values.sh ]
then
    echo "File does not exist, trying to get from github"
    curl -LJO https://raw.githubusercontent.com/sickcodes/osx-serial-generator/master/generate-unique-machine-values.sh
else
    echo "File found. your generate script should work. if not, fix your script"
fi

# generate values
chmod u+x generate-unique-machine-values.sh 
./generate-unique-machine-values.sh -m 'MacBookPro16,4' -c 1 --csv xps9500p5550.csv --tsv xps9500p5550.tsv

/usr/libexec/PlistBuddy -h
