#!/bin/bash

# Build version file
echo "; This file is auto-generated" > version.h
echo " dc.b " \"`cat version.txt`\" >> version.h

# Assembly
tigcc -v --optimize-nops as.asm -o as

# Cleanup
mv *.??z ../bin/
rm -f *.o

# Debug
cp ../bin/as.9xz ../../VTI/
