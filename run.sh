#!/bin/bash
buildDir="build"
packageName="src"
targetClass="Main"
logPath="log"

rm -rf "./${buildDir}"
mkdir $buildDir
rm -rf "./${logPath}"
mkdir $logPath
# # -d : <directory> Specify where to place generated class files
javac -d "./${buildDir}" "./${packageName}/${targetClass}.java"
# # -v : vervose 
# # -c : Disassemble the code
javap -v -c "./${buildDir}/${packageName}/${targetClass}.class" > "./${logPath}/${targetClass}.decompiled.txt"
# # -cp : --class-path
java -cp "./${buildDir}" -verbose:class "${packageName}.${targetClass}" > "./${logPath}/${targetClass}.log.txt"
