--- frmts/wms/md5.cpp.orig	2024-08-21 02:58:52.559100723 +0000
+++ frmts/wms/md5.cpp	2024-08-21 02:59:23.851197416 +0000
@@ -204,7 +204,7 @@ cvs_MD5Transform (
                   cvs_uint32 buf[4],
                   const unsigned char inraw[64])
 {
-    register cvs_uint32 a, b, c, d;
+    cvs_uint32 a, b, c, d;
     cvs_uint32 in[16];
     int i;
 

