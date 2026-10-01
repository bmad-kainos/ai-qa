plugins { java }
repositories { mavenCentral() }
dependencies {
    testImplementation("org.junit.jupiter:junit-jupiter:5.11.0")
    testImplementation("io.rest-assured:rest-assured:5.5.0")
}
tasks.test { useJUnitPlatform() }
