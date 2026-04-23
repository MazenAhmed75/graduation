allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val projectDir = project.projectDir.canonicalPath
    val rootDir = rootProject.projectDir.canonicalPath
    if (projectDir.startsWith(rootDir)) {
        val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
        project.layout.buildDirectory.value(newSubprojectBuildDir)
    } else {
        // For projects outside the root (like plugins in pub cache), 
        // use a build directory on the same drive as the project to avoid "different roots" error.
        project.layout.buildDirectory.value(project.layout.projectDirectory.dir("build"))
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
