plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.tunassiakanugrah" // <--- UBAH: PASTIKAN INI ADALAH NAMESPACE ANDA
    compileSdk = 35 // <--- Set compileSdk ke 34 secara eksplisit
    ndkVersion = "27.0.12077973" // <--- PASTIKAN INI ADA

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11 // <--- UBAH KE JAVA 11
        targetCompatibility = JavaVersion.VERSION_11 // <--- UBAH KE JAVA 11
    }

    kotlinOptions {
        jvmTarget = "11" // <--- UBAH KE '11'
    }

    defaultConfig {
        applicationId = "com.example.tunassiakanugrah" // <--- UBAH: PASTIKAN INI ADALAH ID APLIKASI ANDA
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}