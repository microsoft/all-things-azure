#!/usr/bin/env bash
# shfmt -i 2 -ci -w
MODEL="NOMODEL"
WORKDIR=/mnt/input/$HECRAS_USER/$HECRAS_DATADIR
RAS_LIB_PATH=/ras/libs:/ras/libs/mkl:/ras/libs/centos_7
OUTPUT_DIR=/mnt/output/$HECRAS_USER/$HECRAS_DATADIR
RAS_EXE_PATH=/ras/v61

export LD_LIBRARY_PATH=$RAS_LIB_PATH:$LD_LIBRARY_PATH
export PATH=$RAS_EXE_PATH:$PATH

__usage="
Available Commands:
    [-x  model]        model to be executed on the Muncie directory.

    Possible models are:
        geompre         runs the Geometric Preprocessor sample. 
        steady          runs the RAS Steady sample.
	unsteady        runs the RAS Unsteady sample.
"

usage() {
  echo "usage: ${0##*/} [options]"
  echo "${__usage/[[:space:]]/}"
  exit 1
}

# cwd to the working directory and execture the model
run() {
  cd $WORKDIR
  mkdir -p $OUTPUT_DIR/$MODEL

  # run the model
  eval $MODEL_BIN $MODEL_BIN_FLAGS

  # move sim results into /mnt/
  # remove the tmp string from the output filename
  if [ -f "$SIM_RESULTS_TMP" ]; then
    mv $SIM_RESULTS_TMP ${SIM_RESULTS_TMP/.tmp/}
  fi

  cp $SIM_RESULTS $OUTPUT_DIR/$MODEL
}

# cwd to the working directory and execture the model
do_geompre() {
  MODEL=geompre
  MODEL_BIN=RasGeomPreprocess
  MODEL_BIN_FLAGS="Muncie.x04"
  SIM_RESULTS_TMP="Muncie.c04.tmp"
  SIM_RESULTS="Muncie.c04"
  
  run
}

do_unsteady() {
   MODEL=unsteady
   MODEL_BIN=RasUnsteady
   MODEL_BIN_FLAGS="Muncie.c04 b04"
   SIM_RESULTS_TMP="Muncie.p04.tmp.hdf"
   SIM_RESULTS="Muncie.p04.hdf Muncie.dss"

   cp $WORKDIR/wrk_source/Muncie.p04.tmp.hdf $WORKDIR
   
   run 
}

do_steady() {

  # steady needs unsteady to run first
  if [ ! -f "Muncie.p04.hdf" ]; then
   do_unsteady
  fi

  MODEL=steady
  MODEL_BIN=RasSteady
  MODEL_BIN_FLAGS=Muncie.r04
  SIM_RESULTS_TMP=Muncie.O04.tmp
  SIM_RESULTS=Muncie.O04

  run 
}

exec_case() {
  local _opt=$1

  case ${_opt} in
    geompre) do_geompre ;;
    steady) do_steady ;;
    unsteady) do_unsteady ;;
    *) usage ;;
  esac
  unset _opt
}

while getopts "x:" opt; do
  case $opt in
    x)
      exec_flag=true
      EXEC_OPT="${OPTARG}"
      ;;
    *) usage ;;
  esac
done
shift $((OPTIND - 1))

if [ $OPTIND = 1 ]; then
  usage
  exit 0
fi

if [[ "${exec_flag}" == "true" ]]; then
  exec_case "${EXEC_OPT}"
fi

exit 0
