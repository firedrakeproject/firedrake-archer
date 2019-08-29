#!/bin/bash --login
#PBS -N Firedrake
#PBS -l select=1
#PBS -l walltime=01:00:00
#PBS -A YOUR-PROJECT-CODE

# The directory which contains your firedrake installation
myFiredrake=/home/PROJECT/PROJECT/USERNAME/firedrake
# The script you want to run
myScript=script.py
# The number of processors to use
nprocs=24
# Your work directory
work=/work/PROJECT/PROJECT/USERNAME

# The following lines should not require modification ####### 

# Make sure any symbolic links are resolved to absolute path
export PBS_O_WORKDIR=$(readlink -f $PBS_O_WORKDIR) 

# Change to the directory that the job was submitted from
# (remember this should be on the /work filesystem)
cd $PBS_O_WORKDIR

# Set the number of threads to 1
# This prevents any system libraries from automatically 
# using threading.
export OMP_NUM_THREADS=1

echo "Setting up modules"
module swap PrgEnv-cray PrgEnv-gnu
module swap gcc gcc/6.1.0
module load cmake/3.5.2

# Unload the xalt module as this is suggested for python3
# See http://www.archer.ac.uk/documentation/user-guide/python.php#native
module unload xalt

# Allow dynamically linked executables to be built
export CRAYPE_LINK_TYPE=dynamic

# Set compiler for PyOP2
export CC=cc
export CXX=CC

echo "Activating Firedrake virtual environment"
. ${myFiredrake}/firedrake/bin/activate

export MPICH_GNI_FORK_MODE=FULLCOPY

# Set cache directories to locations writable from compute nodes
export PYOP2_CACHE_DIR=${work}/.caches/pyop2cache
export FIREDRAKE_TSFC_KERNEL_CACHE_DIR=${work}/.caches/firedrake-kernel-cache
export XDG_CACHE_HOME=${work}/.caches/xdg-cache

# Make cache directories if they do not exist already
for cache_dir in ${PYOP2_CACHE_DIR} ${FIREDRAKE_TSFC_KERNEL_CACHE_DIR} ${XDG_CACHE_HOME} ; do
    if [[ ! -e ${cache_dir} ]]; then
	mkdir -p ${cache_dir}
    fi
done

# Run Firedrake
aprun -b -n ${nprocs} python ${myScript}

echo "All done"

# End of file ################################################################
