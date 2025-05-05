#!/bin/sh

# Build version file
echo "; This file is auto-generated" > version.h
echo " dc.b " \"`cat version.txt`\" >> version.h

# Build info file
echo "; This file is auto-generated" > info.h
echo " dc.b " \"`git rev-parse --short HEAD` `date -u +%F\ %H:%M:%S`\" >> info.h

# Assembly
tigcc -v --optimize-nops as.asm -o as

# Cleanup
mv *.??z ../bin/
rm -f *.o version.h 

# Debug
cp ../bin/as.??z ../../VTI/
