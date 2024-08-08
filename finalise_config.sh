#!/bin/bash

# https://fgimian.github.io/blog/2015/06/27/a-simple-plistbuddy-tutorial/ - check for more info on PlistBuddy

echo This script aims to set up EFI/OC/config.plist with proper values

if [ ! -f generate-unique-machine-values.sh ]
then
    echo "File does not exist, trying to get from github"
    curl -LJO https://raw.githubusercontent.com/sickcodes/osx-serial-generator/master/generate-unique-machine-values.sh
else
    echo "Using SickCodes generator, based on macserial - big thanks to the authors!"
fi

# generate value
if [ ! -f xps9500p5550.env ]
then
    chmod u+x generate-unique-machine-values.sh 
    ./generate-unique-machine-values.sh -m 'MacBookAir9,1' -n 1 --csv xps9500p5550.csv --tsv xps9500p5550.tsv --output-env xps9500p5550.env
else
    echo Env file exists, remove xps9500p5550.env to use new values
fi

# this will get env vars to use, e.g :
#export DEVICE_MODEL="MacBookPro16,4"
#export SERIAL="C02GFP123456"
#export BOARD_SERIAL="C021381014N123456"
#export UUID="A881CFE7-C423-446F-9A27-61C602123456"
#export MAC_ADDRESS=":F3:4B:C7"
#export WIDTH="1920"
#export HEIGHT="1080"
source ./xps9500p5550.env

# fix ROM entry proper with 00:16:CB (Apple)
export MAC_ADDR=$(echo -n "00:16:CB$MAC_ADDRESS" | sed -e 's/://g')
echo -n "$MAC_ADDR" will be used for ROM

# hex to base64 for Data type in plist
export MAC_BASE64=$(echo -n $MAC_ADDR| xxd -r -p | base64)

# using perl because plistBuddy leaves unwanted spaces
# example plistBuddy : /usr/libexec/PlistBuddy -c "Set :PlatformInfo:Generic:SystemProductName $DEVICE_MODEL" EFI/OC/config.plist
perl -0pi -e 's/(ROM<\/key>)(\s*)(<data>).*(<\/data>)/$1$2$3$ENV{'MAC_BASE64'}$4/g' EFI/OC/config.plist
perl -0pi -e 's/(SystemProductName<\/key>)(\s*)(<string>).*(<\/string>)/$1$2$3$ENV{'DEVICE_MODEL'}$4/g' EFI/OC/config.plist
perl -0pi -e 's/(SystemSerialNumber<\/key>)(\s*)(<string>).*(<\/string>)/$1$2$3$ENV{'SERIAL'}$4/g' EFI/OC/config.plist
perl -0pi -e 's/(MLB<\/key>)(\s*)(<string>).*(<\/string>)/$1$2$3$ENV{'BOARD_SERIAL'}$4/g' EFI/OC/config.plist
perl -0pi -e 's/(SystemUUID<\/key>)(\s*)(<string>).*(<\/string>)/$1$2$3$ENV{'UUID'}$4/g' EFI/OC/config.plist

# done with platform info, now we clean boot args for GUI boot
# Detect MacOS version
os_version=$(sw_vers -productVersion)
os_main_version=$(echo "${os_version%%.*}")
# this prevents 3 minutes black screen at boot and differs pre and post Ventura to work properly
# we only discriminate on before or after 13 now, may need improvement for next version of OS
igfxblRorT=igfxblr
if [ "$os_main_version" -gt "13" ]; then
    echo Sonoma or newer
    igfxblRorT=igfxblt
else
    echo Ventura or older
fi
echo "Setting up OpenCore GUI config without debug - relies on Resources folder being setup properly"
CANOPY_BOOL=true perl -0pi -e 's/(OpenCanopy\.efi<\/string>\s*<key>Enabled<\/key>\s*<).*(\/>)/$1$ENV{'CANOPY_BOOL'}$2/g' EFI/OC/config.plist
BOOT_ARGS="agdpmod=vit9696 kext-dev-mode=1 igfxonln=1 igfxfw=2 -$igfxblRorT hbfx-ahbm=3" perl -0pi -e 's/(boot-args<\/key>\s*<string>)(.*)(<\/string>)/$1$ENV{'BOOT_ARGS'}$3/g' EFI/OC/config.plist

echo Enable SIP to prevent update issues
SIP_VALUE="AAAAAA==" perl -0pi -e 's/(csr-active-config<\/key>)(\s*)(<data>).*(<\/data>)/$1$2$3$ENV{'SIP_VALUE'}$4/g' EFI/OC/config.plist

# handle debug : https://dortania.github.io/OpenCore-Install-Guide/troubleshooting/debug.html#config-changes

echo DONE! Making a backup to EFI/OC/config.plist.done - rename it to not have it overwritten!
cp EFI/OC/config.plist EFI/OC/config.plist.done
echo Restoring original EFI/OC/config.plist
git checkout EFI/OC/config.plist
echo Now you can mount your EFI folder and put the new plist file there. Enjoy!

