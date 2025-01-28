--- port/cpl_base64.cpp.orig	2024-08-21 02:45:13.759925430 +0000
+++ port/cpl_base64.cpp	2024-08-21 02:45:27.372016149 +0000
@@ -100,7 +100,7 @@ int CPLBase64DecodeInPlace(GByte* pszBas
         }
 
         for (k=0; k<j; k+=4) {
-            register unsigned char b1, b2, b3, b4, c3, c4;
+            unsigned char b1, b2, b3, b4, c3, c4;
 
             b1 = CPLBase64DecodeChar[pszBase64[k]];
 

