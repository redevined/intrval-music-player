pluginManagement {
    val flutterSdkPath =
        run {
            val properties = java.util.Properties()
            file("local.properties").inputStream().use { properties.load(it) }
            val flutterSdkPath = properties.getProperty("flutter.sdk")
            require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
            flutterSdkPath
        }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

// Pinned to AGP 8.7.2 / Kotlin 2.1.0 (rather than the newer defaults
// `flutter create` selected) because AGP 9.x hard-fails the build (instead of
// just warning) when a plugin's bundled Android module declares a
// compileSdk lower than what its own transitive androidx dependencies
// require - which `file_picker` (via `flutter_plugin_android_lifecycle`)
// does, and there is no way to override it from the consuming app's Gradle
// files once AGP has read it. AGP 8.7.x only warns about this mismatch.
// (audiotags used to be a second offender here - removed in favor of the
// pure-Dart audio_metadata_reader - but file_picker alone still blocks the
// AGP bump.)
plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.7.2" apply false
    id("org.jetbrains.kotlin.android") version "2.1.0" apply false
}

include(":app")
