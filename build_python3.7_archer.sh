#!/bin/bash

# Script for building Python on Archer based on instructions at 
# https://github.com/ARCHER-CSE/build-instructions/blob/master/Python/build_python_3.6.0_gcc6_ivybrg.md
# D. Acreman, September 2018
# Updated to handle uncompressed Python tar file (3/10/18)
# Updated to download Python (12/10/18 D. Ham)

set -eu

version_num=3.7.0
base_dir=${PWD}
install_dir=${base_dir}/python/${version_num}

# Check that we're not going to overwrite an existing build
if [[ -e ${install_dir} ]]; then
    echo "${install_dir} aleady exists. Aborting ..."
    exit 1
else
    mkdir -p ${install_dir}
fi
    
if [[ -e Python-${version_num} ]]; then
    echo "Python-${version_num} already exists. Aborting ..."
    exit 1
fi

if [[ -e libffi-3.2.1 ]]; then
    echo "libffi-3.2.1 already exists. Aborting ..."
    exit 1
fi

echo "Downloading Python ${version_num}"
curl -O https://www.python.org/ftp/python/${version_num}/Python-${version_num}.tgz

if [[ -e Python-${version_num}.tgz ]]; then
    echo "Unpacking Python distribution"
    tar -zxf Python-${version_num}.tgz
elif [[ -e Python-${version_num}.tar ]]; then
    echo "Unpacking Python distribution"
    tar -xf Python-${version_num}.tar
else
    echo "Could not find Python-${version_num}.tgz or Python-${version_num}.tar. Aborting ..."
    exit 1
fi

# libffi is no longer bundled with python from version 3.7 onwards so build it now
echo "Building libffi"
wget ftp://sourceware.org/pub/libffi/libffi-3.2.1.tar.gz 
tar zxf libffi-3.2.1.tar.gz
cd libffi-3.2.1
./configure --prefix=${install_dir}
make
make install
# setup.py looks in lib not lib64
cd ${install_dir}/lib
ln -s ../lib64/* .

# Move into Python directory and start building
cd ${base_dir}/Python-${version_num}

echo "Loading environment modules"
module swap PrgEnv-cray PrgEnv-gnu
module swap gcc gcc/6.1.0
echo

echo "Loaded modules are:"
module list
echo

echo "Enabling OpenMP with CFLAGS and LDFLAGS"
export CFLAGS=-fopenmp
export LDFLAGS="-fopenmp -Wl,-rpath,${install_dir}/lib"
echo

echo "Setting LD_LIBRARY_PATH and PKG_CONFIG_PATH to lick up libffi"
export LD_LIBRARY_PATH=${install_dir}/lib:${LD_LIBRARY_PATH}
export PKG_CONFIG_PATH=${install_dir}/lib/pkgconfig:${PKG_CONFIG_PATH}
echo

# Configure is not set to enable-optimizations as this causes the installation to hang when running test_threading
echo "Configuring ..."
./configure --prefix=${install_dir} --enable-shared #--enable-optimizations
if [[ $? -eq 0 ]]; then
    echo "Finished configuring"
else
    echo "Error in configure step"
    exit 1
fi
echo

echo "Running make"
make
if [[ $? -eq 0 ]]; then
    echo "Finished make"
else
    echo "Error in make step"
    exit 1
fi
echo

echo "Installing ..."
make install
if [[ $? -eq 0 ]]; then
    echo "Finished installing"
else
    echo "Error in install setp"
    exit 1
fi
echo

echo "All done"

# End of file ########################################################################
