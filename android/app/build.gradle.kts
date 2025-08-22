plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("com.google.gms.google-services") // 🔹 Firebase
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.exchange_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "29.0.13846066" // 🔹 خليه مربوط بـ flutter بدل ما تكتبه ثابت

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.exchange_app"
        minSdk = 23
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // 🔹 غير التوقيع لو عندك keystore جاهز
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

flutter {
    source = "../.."
}

// 🔹 نخلي Repositories تعتمد على اللي في settings.gradle.kts
repositories {
    google()
    mavenCentral()
    maven { url = uri("https://storage.googleapis.com/download.flutter.io") } // مهم ل Flutter artifacts
}
