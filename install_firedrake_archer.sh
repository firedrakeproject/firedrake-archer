#!/bin/bash

set -eu

python_version_num=3.7.0
python_install_dir=${PWD}/python/${python_version_num}

echo "Setting up modules"
module swap PrgEnv-cray PrgEnv-gnu
module swap gcc gcc/6.1.0
module load cmake/3.5.2
module list

export PATH=${python_install_dir}/bin:${PATH}
export LD_LIBRARY_PATH=${python_install_dir}/lib:${LD_LIBRARY_PATH}
export LDFLAGS="-Wl,-rpath,${python_install_dir}/lib"

# Make sure PYTHONPATH is not set otherwise install script will bail out
unset PYTHONPATH

# Set PETSc options
export PETSC_CONFIGURE_OPTIONS='-with-cc=cc -with-cxx=CC --download-fblaslapack=1 --with-make-np=8 --download-pnetcdf --download-pnetcdf-configure-arguments=\"MPICC=cc\"'

export MPIF90=ftn

# Allow dynamically linked executables to be built
export CRAYPE_LINK_TYPE=dynamic

# Set compiler for PyOP2
export CC=cc

# Pick up HDF5 and netCDF libraries from the PETSc build
export    HDF5_DIR=${PWD}/firedrake/lib/python3.7/site-packages/petsc
export NETCDF4_DIR=${PWD}/firedrake/lib/python3.7/site-packages/petsc

echo "Fetching install script"
curl -O https://raw.githubusercontent.com/firedrakeproject/firedrake/master/scripts/firedrake-install
echo "Installing"
python3 firedrake-install --verbose --no-package-manager --show-petsc-configure-options --mpicc=cc --mpicxx=CC --mpif90=ftn --mpiexec=aprun $@

echo "Done"
