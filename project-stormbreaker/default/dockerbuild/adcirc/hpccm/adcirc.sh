#!/usr/bin/bash
# export FC and CC to the compilers you want to use
export FC=gfortran
export CC=gcc

apt-get update && apt-get install -y \
    automake \
    autoconf \
    libtool \
    gcc \
    gfortran \
    wget \
    make \
    libxml2-dev \
    openssh-server \
    build-essential \
    m4 \
    vim \
    unzip \
    libcurl4-gnutls-dev \
    build-essential \
    g++

mkdir -p /home/stormbreaker/src
mkdir -p /home/stormbreaker/install

# change the src dir
cd /home/stormbreaker/src

##############################
# get zlib
wget http://zlib.net/zlib-1.3.1.tar.gz

# get hdf5
wget www.hdfgroup.org/ftp/HDF5/current/src/hdf5-1.10.5.tar.gz

# get netcdf-c
wget https://github.com/Unidata/netcdf-c/archive/refs/tags/v4.9.2.tar.gz
# get netcdf-fortran
wget https://downloads.unidata.ucar.edu/netcdf-fortran/4.6.1/netcdf-fortran-4.6.1.tar.gz

####################
# install zlib
tar -xzvf zlib-1.3.1.tar.gz
cd zlib-1.3.1
./configure
make test
make install prefix=/home/stormbreaker/install
cd ../

#######################
# install hdf5
tar -xzvf hdf5-1.10.5.tar.gz
cd hdf5-1.10.5
./configure -with-zlib=/home/stormbreaker/install -prefix=/home/stormbreaker/install -enable-fortran
make
make check
make install
cd ../

#########################
# install netcdf c library
tar -xzvf v4.9.2.tar.gz
cd netcdf-c-4.9.2
export CPPFLAGS=-I/home/stormbreaker/install/include
export LDFLAGS=-L/home/stormbreaker/install/lib
./configure -prefix=/home/stormbreaker/install --disable-dap

make
make check
make install
cd ../

#########################
# install netcdf fortran library

tar -xzvf netcdf-fortran-4.6.1.tar.gz 
cd netcdf-fortran-4.6.1
export CPPFLAGS =-I/home/stormbreaker/install/include
export LDFLAGS = '-L/home/stormbreaker/install/lib  -lnetcdf'
export LD_LIBRARY_PATH=/home/stormbreaker/install/lib  
./configure --prefix=/home/stormbreaker/install  
make
make check
make install
cd ../

# note: to link fortran codes must use "-L/home/stormbreaker/install/lib -lnetcdff"
export LD_LIBRARY_PATH=/home/stormbreaker/install/lib  # must do this before running  padcirc. E.g. put it in pbs script.

##########################
# installing adcirc etc.
# look here http://www.unc.edu/ims/adcirc/ADCIRCDevGuide.pdf for detailed instructions
# change to the adcirc "work" directory
# edit the cmplrflags.mk file according to the system and compilers 
# in cmplrflags.mk I set as a default:
# NETCDF=enable 
# NETCDF4=enable
# NETCDF4_COMPRESSION=enable
# NETCDFHOME=/home/stormbreaker/install 
# alternatively(additionally) you can set(override) these on the command line
# as described in the ADCIRC development guide. 
wget https://github.com/adcirc/adcirc/releases/download/v55.02/adcirc_v55.02.tar.gz
mkdir -p adcirc_v55.02/build\
cd adcirc_v55.02/build\
cmake .. \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_ADCIRC=ON    \
    -DBUILD_PADCIRC=ON   \
    -DBUILD_ADCSWAN=ON   \
    -DBUILD_PADCSWAN=ON  \
    -DBUILD_ADCPREP=ON   \
    -DBUILD_UTILITIES=ON \
    -DBUILD_ASWIP=ON     \
    -DBUILD_SWAN=ON      \
    -DBUILD_PUNSWAN=ON   \
    -DENABLE_OUTPUT_NETCDF=ON \
    -DNETCDFHOME=/home/stormbreaker/install
make install