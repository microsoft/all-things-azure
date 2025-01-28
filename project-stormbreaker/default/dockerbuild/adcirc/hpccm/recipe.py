"""
MPI Bandwidth

Contents:
  Ubuntu 22.04
  GNU compilers (upstream)
  Mellanox OFED
  OpenMPI
  PMI2 (SLURM)
  UCX

Building:
  1. Using podman
     $ hpccm --recipe mpi_bandwidth.py > Dockerfile
     $ sudo podman build --format docker -t base -f Dockerfile .
"""

Stage0 += comment(__doc__, reformat=False)

# Ubuntu base image
Stage0 += baseimage(image='ubuntu:22.04', _as='build')

# GNU compilers
Stage0 += gnu(fortran=True)

# Mellanox OFED
Stage0 += mlnx_ofed(version="5.6-2.0.9.0")

# UCX
Stage0 += ucx(cuda=False, version="1.15.0")

# PMI2
Stage0 += slurm_pmi2()

# OpenMPI (use UCX instead of IB directly)
Stage0 += openmpi(version="4.1.6",cuda=False, infiniband=False, pmi='/usr/local/slurm-pmi2',
                  ucx='/usr/local/ucx')

# MPI Bandwidth
Stage0 += shell(commands=[
    'wget -q -nc --no-check-certificate -P /var/tmp https://hpc-tutorials.llnl.gov/mpi/examples/mpi_bandwidth.c',
    'mpicc -o /usr/local/bin/mpi_bandwidth /var/tmp/mpi_bandwidth.c'])

### Runtime distributable stage
Stage1 += baseimage(image='ubuntu:22.04')
Stage1 += Stage0.runtime()
Stage1 += copy(_from='build', src='/usr/local/bin/mpi_bandwidth',
               dest='/usr/local/bin/mpi_bandwidth')
