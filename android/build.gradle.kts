import com.android.build.api.dsl.LibraryExtension
import java.util.Properties

plugins {
    id("com.android.library")
}

group = "com.etranzact.gh.device_security"
version = "1.0-SNAPSHOT"

repositories {
    google()
    mavenCentral()
}

extensions.configure<LibraryExtension> {
    namespace = "com.etranzact.gh.device_security"
    compileSdk = 36

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    sourceSets {
        getByName("main") {
            java.directories.add("src/main/kotlin")
        }
        getByName("test") {
            java.directories.add("src/test/kotlin")
        }
    }

    defaultConfig {
        minSdk = 24
    }

    testOptions {
        unitTests {
            isIncludeAndroidResources = true
            all {
                it.useJUnitPlatform()
                it.outputs.upToDateWhen { false }
                it.testLogging {
                    events("passed", "skipped", "failed", "standardOut", "standardError")
                    showStandardStreams = true
                }
            }
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
    }
}

val localProperties = Properties()
val localPropertiesFile = rootProject.file("local.properties")
if (localPropertiesFile.exists()) {
    localPropertiesFile.inputStream().use { localProperties.load(it) }
}
val flutterRoot = localProperties.getProperty("flutter.sdk")

dependencies {
    if (flutterRoot != null) {
        compileOnly(files("$flutterRoot/bin/cache/artifacts/engine/android-arm-release/flutter.jar"))
    }
    testImplementation("org.jetbrains.kotlin:kotlin-test")
    testImplementation("org.mockito:mockito-core:5.0.0")
}

