FROM spack/ubuntu-jammy:latest

# compile ADCIRC
RUN echo source /opt/spack/share/spack/setup-env.sh >> /root/.bashrc
RUN source /opt/spack/share/spack/setup-env.sh && spack install intel-oneapi-mpi
RUN git clone https://github.com/adcirc/adcirc-spack.git && \
    spack repo add adcirc-spack
RUN spack install adcirc@55.01 ^hdf5@1.10.11 ^netcdf-c@4.9.0 ^netcdf-fortran@4.6.1
RUN spack load adcirc && \
    adcirc -v
RUN spack gc -y