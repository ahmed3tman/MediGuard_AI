plugins {
    id("com.android.application")
    id("kotlin-android")
    id("com.google.gms.google-services")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.spider_doctor"
    compileSdk = 35  // Updated for Flutter 3.22+ compatibility

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
        languageVersion = "2.0"  // For Kotlin 2.1.0 compatibility
    }

    defaultConfig {
        applicationId = "com.example.spider_doctor"
        minSdk = 23
        targetSdk = 35  // Updated target SDK
        versionCode = 1
        versionName = "1.0"
        
        // Ensure proper multidex support for larger applications
        multiDexEnabled = true
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = true
            isShrinkResources = true
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
    // Firebase BOM for version management
    implementation(platform("com.google.firebase:firebase-bom:32.8.0"))
    
    // Firebase dependencies with KTX extensions
    implementation("com.google.firebase:firebase-auth-ktx")
    implementation("com.google.firebase:firebase-database-ktx")
    implementation("com.google.firebase:firebase-analytics-ktx")
    
    // AndroidX dependencies
    implementation("androidx.multidex:multidex:2.0.1")
}

flutter {
    source = "../.."
}