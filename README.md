## Building Firedrake on Archer

The build process will work better if you upload your Archer public SSH key to GitHub (see https://help.github.com/articles/connecting-to-github-with-ssh/ for how to do this). You can build Firedrake without uploading an SSH key but you will see some warnings during the build processes. 

A full Firedrake build will take over an hour to complete which may result in your SSH connection timing out due to inactivity. To stop this happening you can add `-o ServerAliveInterval=600 -o ServerAliveCountMax=` to your SSH command e.g. log in by running 
```
ssh -o ServerAliveInterval=600 -o ServerAliveCountMax=1 username@login.archer.ac.uk
```

Building Firedrake requires a Python installation with a working pip. The Python versions available as modules on Archer do not have a working pip so you will need to build your own Python distribution before building Firedrake.

The build process will only work correctly on the `/home` filesystem. However this filesytem is not mounted on the compute nodes so we will build in `/home` and then copy the installation to `/work`.

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
    bash firedrake-archer/install_firedrake_archer.sh --install gusto
    ```
5.  Copy the installation to the `/work` filesystem:
    ```bash
    cd ${work}
    rsync -avx ${HOME}/firedrake .
    ```
where `${work}` is a directory on the `/work` filesystem.

If you need to update Firedrake then you need to repeat step 5 again (but it won't take as long as rsync will only replace files that have changed).

You will need a job script to submit a job to the queue, which can be based on the example `submit_firedrake_archer.sh`. You will need to edit the script to specify the location of your Firedrake build, the name of the Python script you want to run and your project code.
