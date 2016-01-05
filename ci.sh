#!/bin/bash
set -e

cd tests

rm -rf Export

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
AND_DIR="$DIR/Export/android/TestTesting/build/outputs/apk/TestTesting-release.apk"
IOS_DIR="$DIR/Export/ios/build/Release-iphonesimulator/TestTesting.app"
HTML_DIR="$DIR/Export/html5/web"

printf '\n'
printf ' ---------- UPDATE DEPENDENCIES ----------'
printf '\n'
haxelib run duell_duell update -verbose -yestoall

printf '\n'
printf ' ---------- SETUP ANDROID UNITTESTS ----------'
printf '\n'
haxelib run duell_duell build android -norun -verbose -yestoall -x86 -D jenkins
haxelib run duell_duell run unittest -android -x86 -verbose -wipeemulator -path $AND_DIR

printf '\n'
printf ' ---------- SETUP IOS UNITTESTS ----------'
printf '\n'
haxelib run duell_duell build ios -norun -simulator -verbose -yestoall -D jenkins
haxelib run duell_duell run unittest -ios -verbose -simulator -path $IOS_DIR

printf '\n'
printf ' ---------- SETUP HTML UNITTESTS ----------'
printf '\n'
haxelib run duell_duell build html5 -norun -verbose -D jenkins -yestoall
haxelib run duell_duell run unittest -html5 -verbose -path $HTML_DIR