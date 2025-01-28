--- src/utils_lgpl/deltares_common/packages/deltares_common_c/src/meminfo.cpp.orig	2024-08-21 03:32:28.306953469 +0000
+++ src/utils_lgpl/deltares_common/packages/deltares_common_c/src/meminfo.cpp	2024-08-21 03:32:42.162981447 +0000
@@ -1,7 +1,4 @@
 #include "meminfo.h"
-#if linux
-#include <sys/sysctl.h>
-#endif
 
 #ifdef WIN32
 
