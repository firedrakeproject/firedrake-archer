## Building Firedrake on Archer

Building Firedrake requires a Python installation with a working pip. The Python versions available as modules on Archer do not have a working pip so you will need to build your own Python distribution before building Firedrake.

The build process will only work correctly on the /home filesystem. However this filesytem is not mounted on the compute nodes so we will build in /home and then copy the installation to /work.

The build process is set out in detail in the following steps:

1.	Make a new directory on Archer to use for building Firedrake. This can be called anything you like but it needs to be somewhere in your home directory. For the purposes of these instructions we will assume the directory is `${HOME}/firedrake`:
    ```bash
    cd ~
    mkdir firedrake
    cd firedrake
2.  Clone this repository:
    ```bash
    git clone https://github.com/firedrakeproject/firedrake-archer.git
    ```
3.  Build Python:
    ```bash
    bash firedrake-archer/build_python3.7_archer.sh
    ```
4.  Build Firedrake using the specialised Archer install script. Additional arguments to `firedrake-install` can be passed to this script. For example, to install Firedrake with Gusto you would type:
    ```bash
    bash firedrake-archer/install_firedrake_archer.sh
    ```
5.  Copy the installation to the /work filesystem. For example if your directory on /work is called /work/proj/proj/username then run:
    ```bash
    cd /work/proj/proj/username
    rsync -avx ${HOME}/firedrake
    ```

You will need a job script to submit a job to the queue, which can be based on the example submit_firedrake_archer.sh. You will need to edit the script to specify the location of your Firedrake build, the name of the Python script you want to run and your project code.
