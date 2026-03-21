# Add project specific ProGuard rules here.
# By default, the flags in this file are appended to flags specified
# in android-sdk/tools/proguard/proguard-android.txt
# You can edit the include path and order by changing the proguardFiles
# directive in build.gradle.
#
# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

-dontobfuscate
#-renamesourcefileattribute SourceFile
#-keepattributes SourceFile,LineNumberTable

# Flutter embedding uses ReLinker optionally — suppress missing class warnings
-dontwarn com.getkeepsafe.relinker.**
-keep class com.getkeepsafe.relinker.** { *; }

# Keep Flutter JNI and embedding classes
-keep class io.flutter.** { *; }
-dontwarn io.flutter.**
