# Flutter registers plugins by reflecting on this generated class.
# Keep only that entry point. Package-wide -keep rules lower Play's obfuscation score.
-keep class io.flutter.plugins.GeneratedPluginRegistrant {
    public static void registerWith(io.flutter.embedding.engine.FlutterEngine);
}

# in_app_update references optional Play Feature Delivery types that are not on the classpath.
-dontwarn com.google.android.play.core.**
