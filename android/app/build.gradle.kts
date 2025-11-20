plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

    // Flutter version properties are provided to the project by the Flutter tooling.
    // Bind them into Kotlin variables so the Kotlin DSL can use them.
    // Safely read Flutter-provided properties if present; otherwise use sensible defaults
    val flutterVersionCode: String = (project.findProperty("flutterVersionCode") as String?) ?: "1"
    val flutterVersionName: String = (project.findProperty("flutterVersionName") as String?) ?: "1.0"


android {
    namespace = "com.example.fitai_posture_app"
    compileSdk = 36  // ← Change this
    ndkVersion = "27.0.12077973"  // ← Add this line

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    defaultConfig {
        applicationId = "com.example.fitai_posture_app"
        // Use Kotlin DSL property names
        minSdk = 21
        targetSdk = flutter.targetSdkVersion
        // flutterVersionCode/flutterVersionName are provided by the Flutter Gradle plugin
        versionCode = flutterVersionCode.toInt()
        versionName = flutterVersionName
    }
    buildTypes {
        // Configure release buildType
        getByName("release") {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
