// Top-level build file where you can add configuration options common to all sub-projects/modules.
@file:Suppress("UnstableApiUsage")

buildscript {
    val kotlin_version by extra("1.9.22") // Pastikan ini 1.9.22

    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // PASTIKAN VERSI INI SAMA DENGAN YG DI settings.gradle.kts
        classpath("com.android.tools.build:gradle:8.6.0") // <--- PASTIKAN INI ADALAH 8.6.0
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: org.gradle.api.file.Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: org.gradle.api.file.Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

// SOLUSI UNTUK ERROR 'different roots' (dari sebelumnya)
// Memaksa Kotlin compiler untuk tidak menggunakan incremental caching.
allprojects {
    tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().all {
        kotlinOptions {
            freeCompilerArgs = freeCompilerArgs.filter { it != "-Xuse-fast-jar-filesystem" }.toMutableList()
            freeCompilerArgs = freeCompilerArgs.filter { it != "-Xallow-result-overrides" }.toMutableList()
            freeCompilerArgs = freeCompilerArgs + "-Xno-param-assertions"
            freeCompilerArgs = freeCompilerArgs + "-Xno-call-assertions"
            freeCompilerArgs = freeCompilerArgs + "-Xno-optimize-non-public-api"
            freeCompilerArgs = freeCompilerArgs + "-Xno-check-source-only-deps"
        }
    }
}