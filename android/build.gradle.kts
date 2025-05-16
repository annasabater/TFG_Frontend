// IMPORTS NECESARIOS
import org.gradle.api.tasks.Delete
import com.android.build.gradle.LibraryExtension

buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // Ajusta la versión de AGP si hace falta
        classpath("com.android.tools.build:gradle:8.0.0")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// ------------------------------
// Redirigir carpeta build global
// ------------------------------
val newBuildDir = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.set(newBuildDir)

// ------------------------------
// Configuración común de subproyectos
// ------------------------------
subprojects {
    // Cada módulo apunta su buildDir a build/<module>
    project.layout.buildDirectory.set(newBuildDir.dir(project.name))

    // Queremos que :app se evalúe primero (por si lo necesitas)
    evaluationDependsOn(":app")

    // INYECCIÓN “fallback” de namespace en bibliotecas Android
    plugins.withId("com.android.library") {
        afterEvaluate {
            // Si la extensión LibraryExtension no declara namespace, le damos uno
            extensions.findByType(LibraryExtension::class.java)
                ?.takeIf { it.namespace.isNullOrEmpty() }
                ?.apply { namespace = project.group.toString() }
        }
    }
}

// ------------------------------
// Tarea clean estandarizada
// ------------------------------
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
