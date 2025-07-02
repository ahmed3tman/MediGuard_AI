// android/build.gradle.kts

import org.gradle.api.tasks.Delete
import org.gradle.api.file.Directory

plugins {
    // Google Services plugin for Firebase
    id("com.google.gms.google-services") version "4.4.3" apply false

    // ✅ تم تعديل الإصدارين ليتطابقوا مع الكلاسباث الموجود
    id("com.android.application") version "8.7.3" apply false
    id("org.jetbrains.kotlin.android") version "2.1.0" apply false
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// تغيير مكان مجلد البناء إلى مجلد build خارج android
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

// ضبط build directory لكل subproject
subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

// تأكد أن تقييم المشاريع الفرعية يحصل بعد app
subprojects {
    project.evaluationDependsOn(":app")
}

// أمر clean
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
