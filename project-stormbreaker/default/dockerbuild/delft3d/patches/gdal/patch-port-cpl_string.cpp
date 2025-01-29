--- port/cpl_string.cpp.orig	2024-08-21 21:38:12.571428636 +0000
+++ port/cpl_string.cpp	2024-08-21 21:38:49.247078346 +0000
@@ -2402,7 +2402,7 @@ GByte *CPLHexToBinary( const char *pszHe
 {
     size_t  nHexLen = strlen(pszHex);
     size_t i;
-    register unsigned char h1, h2;
+    unsigned char h1, h2;
     GByte *pabyWKB; 
 
     pabyWKB = (GByte *) CPLMalloc(nHexLen / 2 + 2);
