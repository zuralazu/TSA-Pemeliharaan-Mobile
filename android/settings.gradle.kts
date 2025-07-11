pluginManagement {
    val flutterSdkPath = run {
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

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    // PASTIKAN VERSI INI SAMA DENGAN YG DI build.gradle.kts (root)
    id("com.android.application") version "8.6.0" apply false // <--- UBAH KE 8.6.0
    // PASTIKAN VERSI INI SAMA DENGAN YG DI build.gradle.kts (root)
    id("org.jetbrains.kotlin.android") version "1.9.22" apply false // <--- UBAH KE 1.9.22
}

include(":app")