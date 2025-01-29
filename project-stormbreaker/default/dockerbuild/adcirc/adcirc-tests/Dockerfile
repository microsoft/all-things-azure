FROM spack/ubuntu-jammy:latest

RUN echo source /opt/spack/share/spack/setup-env.sh >> /root/.bashrc
RUN source /opt/spack/share/spack/setup-env.sh

RUN git clone https://github.com/adcirc/adcirc-spack.git \
    && spack repo add adcirc-spack

# install openmpi
RUN spack install openmpi fabrics=auto
# install ADCIRC
RUN spack install --keep-stage \
    adcirc@55.01 \
    +swan \
    +utilities \
    ^hdf5@1.10.11 \
    ^netcdf-c@4.9.0 \
    ^netcdf-fortran@4.6.1 \
    ^openmpi@4.1.6

# add the necessary components for MPI
RUN apt-get update --fix-missing \
    && apt-get install -y openssh-server

# for testing only:
# git clone the adcirc-testsuite
#RUN git clone https://github.com/adcirc/adcirc-testsuite.git

# for some reason, adcircResultsComparison doesn't get copied 
# into to the directory where adcirc is ... This fixes that
RUN spack load adcirc \
    && find /tmp/root/spack-stage/ -name adcircResultsComparison -type f -exec cp {} /usr/bin \; \
    && SPACK_STAGE=/tmp/root/spack-stage \
    && ADCIRC_HOME=$(dirname $(which adcirc)|tail -n1) \
    && cp $(which adcprep) /usr/bin \
    && cp $(which mpiexec) /usr/bin \
    && cp $(which orted) /usr/bin \
    && cp $ADCIRC_HOME/* /usr/bin

CMD mkdir -p /var/run/ssh; /usr/sbin/sshd
