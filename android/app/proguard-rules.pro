# Keep TensorFlow Lite classes
-keep class org.tensorflow.lite.** { *; }

# Specifically keep the GpuDelegate related classes
-keep class org.tensorflow.lite.gpu.** { *; }
-keep class org.tensorflow.lite.gpu.GpuDelegateFactory$Options { *; }

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Basic ProGuard rules
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes SourceFile,LineNumberTable 