--- frmts/gtiff/geotiff.cpp.orig	2024-08-21 02:50:13.128751456 +0000
+++ frmts/gtiff/geotiff.cpp	2024-08-21 02:54:53.533892084 +0000
@@ -4411,7 +4411,7 @@ CPLErr GTiffOddBitsBand::IReadBlock( int
 /*      Translate 1bit data to eight bit.                               */
 /* -------------------------------------------------------------------- */
         int	  iDstOffset=0, iLine;
-        register GByte *pabyBlockBuf = poGDS->pabyBlockBuf;
+        GByte *pabyBlockBuf = poGDS->pabyBlockBuf;
 
         for( iLine = 0; iLine < nBlockYSize; iLine++ )
         {
@@ -4598,7 +4598,7 @@ CPLErr GTiffOddBitsBand::IReadBlock( int
         if( (nBitsPerLine & 7) != 0 )
             nBitsPerLine = (nBitsPerLine + 7) & (~7);
 
-        register GByte *pabyBlockBuf = poGDS->pabyBlockBuf;
+        GByte *pabyBlockBuf = poGDS->pabyBlockBuf;
         iPixel = 0;
 
         for( iY = 0; iY < nBlockYSize; iY++ )

