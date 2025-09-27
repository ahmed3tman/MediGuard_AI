plugins {
    id("com.android.application")
    id("kotlin-android")
    id("com.google.gms.google-services")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.spider_doctor"
    compileSdk = 36  // Updated to satisfy plugin requirements

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    
    // Add this to handle legacy plugins that don't specify namespace
    androidComponents {
        onVariants { variant ->
            variant.packaging.resources.excludes.addAll(
                listOf(
                    "/META-INF/{AL2.0,LGPL2.1}",
                    "/META-INF/versions/9/previous-compilation-data.bin"
                )
            )
        }
    }

    kotlinOptions {
        jvmTarget = "17"
        languageVersion = "2.0"  // For Kotlin 2.1.0 compatibility
    }

    defaultConfig {
        applicationId = "com.example.spider_doctor"
        minSdk = flutter.minSdkVersion
    targetSdk = 36  // Updated target SDK
        versionCode = 1
        versionName = "1.0"
        
        // Ensure proper multidex support for larger applications
        multiDexEnabled = true
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
            // Disable code shrinking/minification for now to avoid R8 missing-class
            // errors (Play Core classes) during release builds. This yields a larger
            // APK but ensures the build completes. If you want minification later,
            // re-enable and add the required ProGuard rules (see
            // build/app/outputs/mapping/release/missing_rules.txt).
            isMinifyEnabled = false
            isShrinkResources = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
        debug {
            isDebuggable = true
            isMinifyEnabled = false
        }
    }

    // Packaging options to resolve conflicts
    packaging {
        resources {
            excludes += listOf(
                "/META-INF/{AL2.0,LGPL2.1}",
                "/META-INF/versions/9/previous-compilation-data.bin"
            )
        }
    }
}

dependencies {
    // Firebase BOM for version management (uses root project property if provided)
    implementation(platform("com.google.firebase:firebase-bom:${project.findProperty("FirebaseSDKVersion") ?: "34.0.0"}"))

    // Firebase dependencies (BOM provides versions)
    implementation("com.google.firebase:firebase-auth")
    implementation("com.google.firebase:firebase-database")
    implementation("com.google.firebase:firebase-analytics")
    
    // AndroidX dependencies
    implementation("androidx.multidex:multidex:2.0.1")
}

flutter {
    source = "../.."
}
