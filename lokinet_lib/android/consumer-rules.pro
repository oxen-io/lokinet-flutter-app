# The native JNI code in liblokinet-android.so looks up these classes'
# members by name (GetFieldID/GetMethodID), so they must not be renamed
# or removed by R8.
-keep class network.loki.lokinet.** { *; }
