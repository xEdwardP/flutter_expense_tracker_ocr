# Flutter's standard rules
# --- ML Kit Text Recognition ---
-keep class com.google.mlkit.vision.** { *; }
-keepclassmembers class com.google.mlkit.vision.** { *; }
-keep class com.google.android.gms.internal.mlkit_vision_text_common.** { *; }
-keep,allowobfuscation class com.google.mlkit.** { *; }
# Lenguajes
-keep class com.google.mlkit.vision.text.chinese.** { *; }
-keep class com.google.mlkit.vision.text.devangari.** { *; }
-keep class com.google.mlkit.vision.text.japanese.** { *; }
-keep class com.google.mlkit.vision.text.korean.** { *; }

# --- Clases
-keep class com.google.mlkit.vision.text.TextRecognizer { *; }
-keep class com.google.mlkit.vision.text.TextRecognition { *; }
-keep class com.google.mlkit.vision.text.TextRecognitionOptions { *; }
-keep class com.google.mlkit.vision.text.Text { *; }