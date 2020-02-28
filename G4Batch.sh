#!/bin/sh
## Stop on error
set -e

## Geant 4 Version
# If a specific Geant4 version should be used, adapt and uncomment these lines.
# source /data/jmayer/software/geant4.10.05/bin/geant4.sh
echo "Using Geant4 Version `geant4-config --version` in `dirname $(dirname $(geant4-config --prefix))`"


## Build Project
# Remove previous build directory if it exists and recreate it
#rm -rf build
mkdir -p build
cd build
cmake ..
make -j 10
cd ..


## Set CAD Directory
if [ -z "${G4HORUS_CAD_DIR}" ]
then
	export G4HORUS_CAD_DIR=`pwd`/cad
fi
echo "CAD Dir: ${G4HORUS_CAD_DIR}"

## Create output dir and run full simulation
mkdir -p out
cd out
TS=$(date +%Y-%m-%dT%H-%M-%S)
mkdir ${TS}
cd ${TS}


## Macro File
if [ -n "$1" ]
then
    MACRO=../../$1
else
    MACRO=../../scripts/test.mac
fi

# Copy main settings over for later reference
cp ../../src/DetectorConstruction.cc .
cp $MACRO .

# Run executable in batch mode, niced and multithreaded
nice -n 19 ../../build/G4Horus -t 32 -k hist -m ${MACRO}
#nice -n 19 ../../build/G4Horus -t 32 -k soco -m ${MACRO}
