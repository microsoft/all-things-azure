--- frmts/grib/degrib18/degrib/fileendian.cpp.orig	2024-08-21 03:01:53.235798373 +0000
+++ frmts/grib/degrib18/degrib/fileendian.cpp	2024-08-21 03:02:02.195829375 +0000
@@ -330,7 +330,7 @@ int fileBitRead (void *Dst, size_t dstLe
                  uChar * gbuf, sChar * gbufLoc)
 {
    static uChar BitRay[] = { 0, 1, 3, 7, 15, 31, 63, 127, 255 };
-   register uChar buf_loc, buf, *ptr;
+   uChar buf_loc, buf, *ptr;
    uChar *dst = (uChar*)Dst;
    size_t num_bytes;
    uChar dst_loc;

