# Changelog


All notable changes to the `tomcat-ant-demo-app` (Tomcat-Ant demo) build and deployment.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).


## [1.1.0]

### Fixed
- **WAR 404 after deploy — servlet not registered.** The WAR was packaging
  compiled classes at the WAR **root** (`classes/`) instead of under
  `WEB-INF/classes/`. Tomcat's web application classloader only scans
  `WEB-INF/classes` and `WEB-INF/lib`, so the `@WebServlet` annotation was never
  discovered, the servlet was not registered, and `GET /`, `/hello`, and
  `/helloworld/hello` all returned HTTP 404 (the webapp still deployed and
  returned a 302 welcome-file redirect).

  `build.xml` now compiles with
  `destdir="${build.dir}/WEB-INF/classes"` and packages the WAR from
  `basedir="${build.dir}"`, so classes land at `WEB-INF/classes/` inside the
  archive. Deployed app now responds with HTTP 200 on all endpoints.

  ```xml
  <target name="compile" depends="init" description="Compile the Java sources">
    <javac srcdir="src/main/java"
           destdir="${build.dir}/WEB-INF/classes"
           source="21" target="21" includeantruntime="false">
      <classpath>
        <pathelement location="${servlet.api.jar}"/>
      </classpath>
    </javac>
  </target>
  ```

### Changed
- `build.xml` `war` target now declares `depends="clean,compile"` so a stale
  WAR from a prior run cannot be re-packaged into a new one (Ant would otherwise
  fail with "A zip file cannot include itself").
- Servlet-api is bundled into `WEB-INF/lib/servlet-api.jar` so the WAR is
  self-contained. (Bundle-vs-not bundle was tested both ways; neither change
  affected the 404, which was caused by class placement, not classpath.)

## [1.0.0]

### Added
- Initial build/deploy pipeline: `build.sh` (BACKUP_HOME-aware) + `build.xml`
  (Ant) + `deptools.py --deploy-war` against the Tomcat Manager text interface.
- Container layout under `BACKUP_HOME`:
  `${BACKUP_HOME}/helloworld/{src,build}` with the WAR at
  `${BACKUP_HOME}/helloworld/build/helloworld.war`.
