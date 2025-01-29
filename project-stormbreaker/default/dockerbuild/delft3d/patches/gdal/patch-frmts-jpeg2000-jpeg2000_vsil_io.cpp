--- frmts/jpeg2000/jpeg2000_vsil_io.cpp.orig	2024-08-20 20:56:01.321719206 +0000
+++ frmts/jpeg2000/jpeg2000_vsil_io.cpp	2024-08-20 20:56:11.385714011 +0000
@@ -206,7 +206,7 @@ static void JPEG2000_VSIL_jas_stream_ini
 			/* The buffer must be large enough to accommodate maximum
 			  putback. */
 			assert(bufsize > JAS_STREAM_MAXPUTBACK);
-			stream->bufbase_ = JAS_CAST(uchar *, buf);
+			stream->bufbase_ = JAS_CAST(u_char *, buf);
 			stream->bufsize_ = bufsize - JAS_STREAM_MAXPUTBACK;
 		}
 	} else {
