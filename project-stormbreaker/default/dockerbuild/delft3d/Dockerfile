# build with: 
# podman build --format docker -t stormbreakeracrdc.azurecr.io/delft3d:1.0 .
# Use the provided base image
FROM stormbreakeracrdc.azurecr.io/hpccm:base-4

# Set environment to bash
SHELL ["/bin/bash", "-c"]

# Install prerequisites
RUN apt-get update && apt-get install -y \
  bison \
  cmake \
  file \
  flex \
  g++ \
  gfortran \
  libblosc-dev \
  libcurl4-openssl-dev \
  libhdf5-serial-dev \
  m4 \
  make \
  patch \
  patchelf \
  pkg-config \
  python3 \
  python3-pip \
  ruby \
  sqlite3 \
  subversion \
  unzip \
  util-linux \
  uuid-dev && \
  rm -rf /var/lib/apt/lists/*

# Download and install Intel HPC Kit
RUN wget https://registrationcenter-download.intel.com/akdlm/IRC_NAS/d461a695-6481-426f-a22f-b5644cd1fa8b/l_HPCKit_p_2024.2.1.79_offline.sh && \
    chmod +x l_HPCKit_p_2024.2.1.79_offline.sh && \
    ./l_HPCKit_p_2024.2.1.79_offline.sh -a --silent --cli --eula accept && \
    rm l_HPCKit_p_2024.2.1.79_offline.sh

# Set environment variables for compilers
ENV LD_LIBRARY_PATH="/opt/intel/oneapi/2024.2/lib:/opt/intel/oneapi/compiler/2024.2/lib:/home/delft3d/lib:$LD_LIBRARY_PATH"
ENV PATH="/home/delft3d/bin:$PATH"
ENV MAKEFLAGS="-j $(nproc)"
ENV SRCDIR="/home/delft3d/src"
ENV PKG_CONFIG_PATH="/home/delft3d/lib/pkgconfig:$PKG_CONFIG_PATH"
ENV PKG_CONFIG_PATH="/home/delft3d/lib64/pkgconfig:$PKG_CONFIG_PATH"
ENV C_INCLUDE_PATH="/home/delft3d/include"
ENV CPLUS_INCLUDE_PATH="/home/delft3d/include"
ENV PATH=/home/delft3d/bin:$PATH


COPY patches /home/deflt3d/src/patches

# Create necessary directories
RUN mkdir -p /home/delft3d/src && mkdir -p /home/delft3d/

# Download sources
WORKDIR /home/delft3d/src
RUN wget https://github.com/madler/zlib/releases/download/v1.3.1/zlib-1.3.1.tar.gz -O zlib-1.3.1.tar.gz && \
    wget https://github.com/HDFGroup/hdf5/archive/refs/tags/hdf5-1_10_5.tar.gz -O hdf5-1_10_5.tar.gz && \
    wget https://github.com/Unidata/netcdf-c/archive/refs/tags/v4.9.2.tar.gz -O netcdf-c-4.9.2.tar.gz && \
    wget https://downloads.unidata.ucar.edu/netcdf-fortran/4.6.1/netcdf-fortran-4.6.1.tar.gz -O netcdf-fortran-4.6.1.tar.gz && \
    wget https://web.cels.anl.gov/projects/petsc/download/release-snapshots/petsc-with-docs-3.21.1.tar.gz -O petsc-with-docs-3.21.1.tar.gz && \
    wget https://github.com/google/googletest/archive/refs/tags/v1.14.0.tar.gz -O googletest-1.14.0.tar.gz && \
    wget https://github.com/OSGeo/gdal/archive/refs/tags/v2.0.0.tar.gz -O gdal-2.0.0.tar.gz && \
    wget https://download.osgeo.org/proj/proj-4.9.3.tar.gz -O proj-4.9.3.tar.gz

# Install zlib
RUN tar -xzvf zlib-1.3.1.tar.gz && \
    cd zlib-1.3.1 && \
    ./configure --prefix=/home/delft3d && \
    make && \
    make check && \
    make install && \
    cd $SRCDIR

# Install hdf5
RUN tar -xzvf hdf5-1_10_5.tar.gz && \
    cd hdf5-hdf5-1_10_5 && \
    ./configure --with-zlib=/home/delft3d --enable-parallel --enable-fortran --prefix=/home/delft3d && \
    make && \
    make install && \
    cd $SRCDIR

# Set Intel compiler environment variables
ENV FC=mpiifx
ENV CXX=mpiicpx
ENV CC=mpiicx

# Install netcdf-c library
RUN source /opt/intel/oneapi/setvars.sh && \
    tar -xzvf netcdf-c-4.9.2.tar.gz && \
    cd netcdf-c-4.9.2 && \
    export CPPFLAGS='-I/home/delft3d/include' && \
    export LDFLAGS='-L/home/delft3d/lib' && \
    ./configure --prefix=/home/delft3d/ --disable-libxml2 && \
    make && \
    make check && \
    make install && \
    cd $SRCDIR

# Install netcdf-fortran library
RUN source /opt/intel/oneapi/setvars.sh && \
    tar -xzvf netcdf-fortran-4.6.1.tar.gz && \
    cd netcdf-fortran-4.6.1 && \
    export CPPFLAGS='-I/home/delft3d/include' && \
    export LDFLAGS='-L/home/delft3d/lib' && \
    ./configure --prefix=/home/delft3d/ && \
    make && \
    make check && \
    make install && \
    cd $SRCDIR

# Install petsc
RUN tar xvzf petsc-with-docs-3.21.1.tar.gz && \
    cd petsc-3.21.1 && \
    ./configure --prefix=/home/delft3d --download-fblaslapack=1 && \
    make PETSC_DIR=/home/delft3d/src/petsc-3.21.1 PETSC_ARCH=arch-linux-c-debug all && \
    make PETSC_DIR=/home/delft3d/src/petsc-3.21.1 PETSC_ARCH=arch-linux-c-debug install && \
    cd $SRCDIR

# Install googletest
RUN source /opt/intel/oneapi/setvars.sh && \
    tar -xvzf googletest-1.14.0.tar.gz && \
    cd googletest-1.14.0/ && mkdir build && \
    cd build/ && cmake -DCMAKE_PREFIX_PATH=/home/delft3d -DCMAKE_INSTALL_PREFIX=/home/delft3d .. && \
    cmake --build . && \
    cmake --build . --target install && \
    cd $SRCDIR
# Install proj-4.9.3
RUN source /opt/intel/oneapi/setvars.sh && \
    tar -xvzf proj-4.9.3.tar.gz && \
    cd proj-4.9.3 && \
    CFLAGS=-O0 ./configure --prefix=/home/delft3d && \
    make && \
    make check && \
    make install && \
    cd $SRCDIR

# Install gdal-2.0.0
COPY patches/ ./patches/
RUN source /opt/intel/oneapi/setvars.sh && \
    tar -xvzf gdal-2.0.0.tar.gz && \
    ls && \
    cp patches/gdal/* gdal-2.0.0/gdal/ && \
    cd gdal-2.0.0/gdal && \
    sed -i 's/\r$//g' frmts/jpeg2000/jpeg2000_vsil_io.cpp && \
    for patch in patch-*.cpp; do \
      echo "Applying $patch..."; \
      patch -p0 <"$patch" | tee patch_log.txt 2>&1; \
    done && \
    ./configure --prefix=/home/delft3d --without-jasper CFLAGS='-std=gnu89' && \
    make && \
    make install && \
    cd $SRCDIR

# Checkout Delft3D from SVN and apply patches
RUN svn checkout -r 142633 https://svn.oss.deltares.nl/repos/delft3d/trunk /home/delft3d/src/delft3d_142633
RUN cp -r patches/delft3d/* delft3d_142633/ && \
    cd delft3d_142633/ && \
    sed -i 's/\r$//g' src/utils_lgpl/deltares_common/packages/deltares_common_c/src/meminfo.cpp && \
    sed -i 's/\r$//g' src/cmake/CMakeLists.txt && \
    patch -p0 < patch-src-setenv.sh && \
    patch -p0 < patch-src-cmake-CMakeLists.txt && \
    patch -p0 < patch-src-utils_lgpl-deltares_common-packages-deltares_common_c-src-meminfo.cpp && \
    patch -p0 < patch-build.sh

RUN source /opt/intel/oneapi/setvars.sh  && \
    cd delft3d_142633/ && \
    ./build.sh delft3d4 --compiler intel21

# setup environment
RUN echo source /opt/intel/oneapi/setvars.sh >> /root/.bashrc && \
    echo source /opt/intel/oneapi/setvars.sh >> /root/.profile  
