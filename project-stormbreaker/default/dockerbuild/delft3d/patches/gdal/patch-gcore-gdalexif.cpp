--- gcore/gdalexif.cpp.orig	2024-08-21 02:48:58.788570680 +0000
+++ gcore/gdalexif.cpp	2024-08-21 02:52:02.128933883 +0000
@@ -82,7 +82,7 @@ static void EXIFPrintData(char* pszData,
     break;
 
   case TIFF_SHORT: {
-    register GUInt16 *wp = (GUInt16*)data;
+    GUInt16 *wp = (GUInt16*)data;
     for(;count>0;count--) {
       sprintf(pszTemp, "%s%u", sep, *wp++), sep = " ";
       if (strlen(pszTemp) + pszDataEnd - pszData >= MAXSTRINGLENGTH)
@@ -93,7 +93,7 @@ static void EXIFPrintData(char* pszData,
     break;
   }
   case TIFF_SSHORT: {
-    register GInt16 *wp = (GInt16*)data;
+    GInt16 *wp = (GInt16*)data;
     for(;count>0;count--) {
       sprintf(pszTemp, "%s%d", sep, *wp++);
       sep = " ";
@@ -105,7 +105,7 @@ static void EXIFPrintData(char* pszData,
     break;
   }
   case TIFF_LONG: {
-    register GUInt32 *lp = (GUInt32*)data;
+    GUInt32 *lp = (GUInt32*)data;
     for(;count>0;count--) {
       sprintf(pszTemp, "%s%lu", sep, (unsigned long) *lp++);
       sep = " ";
@@ -117,7 +117,7 @@ static void EXIFPrintData(char* pszData,
     break;
   }
   case TIFF_SLONG: {
-    register GInt32 *lp = (GInt32*)data;
+    GInt32 *lp = (GInt32*)data;
     for(;count>0;count--) {
       sprintf(pszTemp, "%s%ld", sep, (long) *lp++), sep = " ";
       if (strlen(pszTemp) + pszDataEnd - pszData >= MAXSTRINGLENGTH)
@@ -128,7 +128,7 @@ static void EXIFPrintData(char* pszData,
     break;
   }
   case TIFF_RATIONAL: {
-    register GUInt32 *lp = (GUInt32*)data;
+    GUInt32 *lp = (GUInt32*)data;
       //      if(bSwabflag)
       //      TIFFSwabArrayOfLong((GUInt32*) data, 2*count);
     for(;count>0;count--) {
@@ -149,7 +149,7 @@ static void EXIFPrintData(char* pszData,
     break;
   }
   case TIFF_SRATIONAL: {
-    register GInt32 *lp = (GInt32*)data;
+    GInt32 *lp = (GInt32*)data;
     for(;count>0;count--) {
       CPLsprintf(pszTemp, "%s(%g)", sep,
           (float) lp[0]/ (float) lp[1]);
@@ -163,7 +163,7 @@ static void EXIFPrintData(char* pszData,
     break;
   }
   case TIFF_FLOAT: {
-    register float *fp = (float *)data;
+    float *fp = (float *)data;
     for(;count>0;count--) {
       CPLsprintf(pszTemp, "%s%g", sep, *fp++), sep = " ";
       if (strlen(pszTemp) + pszDataEnd - pszData >= MAXSTRINGLENGTH)
@@ -174,7 +174,7 @@ static void EXIFPrintData(char* pszData,
     break;
   }
   case TIFF_DOUBLE: {
-    register double *dp = (double *)data;
+    double *dp = (double *)data;
     for(;count>0;count--) {
       CPLsprintf(pszTemp, "%s%g", sep, *dp++), sep = " ";
       if (strlen(pszTemp) + pszDataEnd - pszData >= MAXSTRINGLENGTH)

