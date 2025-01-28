#!/usr/bin/bash

case_name="adcirc_katrina-2d-parallel"

...Check on what is provided
if [ $# -ne 2 ] ; then
   echo "ERROR: Script requires 2 arguments!"
   echo "    Argument 1: Folder containing adcirc and adccmp executables."
   echo "    Argument 2: Maximum error"
   echo "Exiting with status 1, Failed."
   exit 1
fi

#...Set variables
err=$1
np=9
SLOTS=3
MPI_HOST=$(sed -E 's/(lm-mpi-job-mpiworker-[0-9]+\.lm-mpi-job)/\1:'"$SLOTS"'/g' < /etc/volcano/mpiworker.host | tr '\n' ',')

nfiles=9
files=( "fort.63.nc" "fort.64.nc" "fort.73.nc" "fort.74.nc"
        "maxele.63.nc" "maxvel.63.nc" "maxwvel.63.nc" "minpr.63.nc" 
        "windDrag.173.nc" )

#...Run the case
echo ""
echo "|---------------------------------------------|"
echo "    TEST CASE: $case_name"
echo ""
echo -n "    Prepping case..."
adcprep --np $np --partmesh | tee adcprep.log
adcprep --np $np --prepall  | tee adcprep.log
if [ $? == 0 ] ; then
    echo "done!"
else
    echo "ERROR!"
    exit 1
fi

echo -n "    Runnning case..."
mpiexec --allow-run-as-root -np $np --host $MPI_HOST padcirc | tee padcirc.log

exitstat=$?
echo "Finished"
echo "    ADCIRC Exit Code: $exitstat"
if [ "x$exitstat" != "x0" ] ; then
    echo "    ERROR: ADCIRC did not exit cleanly."
    exit 1
fi
echo ""


#...Run the comparison test
echo -n "    Running comparison..."
for((i=0;i<$nfiles;i++))
do
    echo "" >> comparison.log
    echo "${files[$i]}" >> comparison.log
    CLOPTIONS="-t $err"
    if [[ ${files[$i]} = "maxvel.63" || ${files[$i]} = "maxele.63" || ${files[$i]} = "maxwvel.63" || ${files[$i]} = "minpr.63" ]]; then
       CLOPTIONS="$CLOPTIONS --minmax"
    fi    
    adcircResultsComparison $CLOPTIONS -f1 ${files[$i]} -f2 control/${files[$i]} >> comparison.log 2>>comparison.log
    error[$i]=$?
done
echo "Finished"

#...Check the number of failed steps
fail=0
for((i=0;i<$nfiles;i++))
do
    echo -n "      "${files[$i]}": "
    if [ "x${error[$i]}" != "x0" ] ; then
        echo "Failed"
        fail=1
    else
        echo "Passed"
    fi
done

if [ $fail == 1 ] ; then
    echo "    Comparison Failed!"
else
    echo "    Comparison Passed!"
fi

echo "|---------------------------------------------|"
echo ""
exit 0
#if [ $fail == 1 ] ; then
#    exit 1
#else
#    exit 0
#fi
