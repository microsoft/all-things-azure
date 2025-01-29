--- build.sh.orig	2024-08-23 19:56:40.267352810 -0600
+++ build.sh	2024-08-23 19:57:12.137352061 -0600
@@ -79,7 +79,7 @@ function DoCMake () {
     echo "Executing CMake for $1 ..."
     cd    $root/build_$1$2
     echo "cmake ../src/cmake -G "$generator" -B "." -D CONFIGURATION_TYPE="$1" -D CMAKE_BUILD_TYPE=${buildtype} &>build_$1$2/cmake_$1.log"
-          cmake ../src/cmake -G "$generator" -B "." -D CONFIGURATION_TYPE="$1" -D CMAKE_BUILD_TYPE=${buildtype} &>cmake_$1.log
+          cmake ../src/cmake -G "$generator" -B "." -D CONFIGURATION_TYPE="$1" -D CMAKE_BUILD_TYPE=${buildtype} | tee cmake_$1.log
     if [ $? -ne 0 ]; then
         echo "CMake configure resulted in an error. Check log files."
         exit 1
@@ -98,7 +98,7 @@ function BuildCMake () {
     echo "Building (make) based on CMake preparations for $1 ..."
     cd    $root/build_$1$2
     echo "make VERBOSE=1 install &>build_$1$2/make_$1.log"
-          make VERBOSE=1 install &>make_$1.log
+          make VERBOSE=1 install | tee make_$1.log
     if [ $? -ne 0 ]; then
         echo "CMake build resulted in an error. Check log files."
         exit 1
