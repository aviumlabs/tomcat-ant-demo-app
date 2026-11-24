#!/bin/sh
#
# Build the Hello World WAR on the server and print deployment directions.
#
# Run this inside the running container (as the tomcat user). build.sh lives in
# the source root (the directory that contains build.xml, build.properties, and
# the Maven src layout), so:
#
#     ./build.sh
#
# When run from the source directory (the normal case) the source tree already
# lives under ${BACKUP_HOME}/helloworld and Ant is run in place, producing
# helloworld.war in ${BACKUP_HOME}/helloworld/build. If run from a different
# directory, the source tree is copied into ${BACKUP_HOME}/helloworld/src first.

set -eu

# --- Resolve directories -----------------------------------------------------
# build.sh lives in the source root, which contains build.xml, build.properties,
# and the Maven source layout (src/main/...). That directory is what gets built.
# build.properties is (re)generated below with the resolved BACKUP_HOME so Ant
# can locate the servlet-api and the web.xml.
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SRC_DIR="${SCRIPT_DIR}"

# --- Required environment ----------------------------------------------------
if [ -z "${ANT_HOME:-}" ]; then
    ANT_HOME="${ANT_HOME:-/usr/share/java/apache-ant}"
fi
CATALINA_HOME="${CATALINA_HOME:-/usr/local/tomcat}"
BACKUP_HOME="${BACKUP_HOME:-/opt/backup}"
# The Tomcat instance is derived from INSTANCE_NAME (set at image build time),
# never hardcoded to a specific instance name.
INSTANCE_NAME="${INSTANCE_NAME:-tc1}"
CATALINA_BASE="${CATALINA_BASE:-/opt/tomcat/instances/${INSTANCE_NAME}}"

if [ ! -d "${SRC_DIR}" ]; then
    echo "ERROR: source directory not found: ${SRC_DIR}" >&2
    exit 1
fi

# --- New build layout (under BACKUP_HOME) ------------------------------------
#   ${BACKUP_HOME}/helloworld          <- source tree (build.xml, build.properties, src/main/...)
#   ${BACKUP_HOME}/helloworld/build    <- compiled classes, WEB-INF/lib, and the WAR
#   ${BACKUP_HOME}/helloworld/src      <- (copy-only mode) relocated source tree
HELLOWORLD_DIR="${BACKUP_HOME}/helloworld"
BUILD_DIR="${HELLOWORLD_DIR}/build"
BUILD_ROOT="${HELLOWORLD_DIR}"
#
# build.sh is normally run from the source directory (SRC_DIR == HELLOWORLD_DIR),
# in which case the Maven src already lives at ${HELLOWORLD_DIR}/src and Ant runs
# in place. If run from a different directory, the source tree is copied into
# ${HELLOWORLD_DIR}/src first and Ant runs from there.
if [ "${SRC_DIR}" = "${HELLOWORLD_DIR}" ]; then
    echo "==> Source already at ${HELLOWORLD_DIR}; running Ant in place"
else
    echo "==> Copying sources into ${HELLOWORLD_DIR}/src"
    rm -rf "${HELLOWORLD_DIR}"
    mkdir -p "${HELLOWORLD_DIR}/src"
    cp -r "${SRC_DIR}/." "${HELLOWORLD_DIR}/src/"
    BUILD_ROOT="${HELLOWORLD_DIR}/src"
fi

# --- Generate build.properties with the resolved base directory -------------
# Ant cannot read environment variables from a static properties file, so we
# write build.properties here with BACKUP_HOME substituted for the base dir.
cat > "${SRC_DIR}/build.properties" <<EOF
# Build properties for the Hello World WAR.
# Paths are based on the BACKUP_HOME directory.
servlet.api.jar=/usr/local/tomcat/lib/servlet-api.jar
war.name=helloworld.war
webapp.dir=${CATALINA_BASE:-/opt/tomcat/instances/${INSTANCE_NAME}}/webapps
base.dir=${BACKUP_HOME}
build.dir=\${base.dir}/helloworld/build
EOF

echo "==> Building WAR (Java ${JAVA_HOME:-/usr/lib/jvm/default-jvm})"
(
    cd "${BUILD_ROOT}"
    ANT_HOME="${ANT_HOME}" ant -f build.xml
)

# build.xml writes the WAR into ${build.dir}, which now includes the /build
# suffix (set in build.properties).
WAR="${BUILD_DIR}/helloworld.war"
if [ ! -f "${WAR}" ]; then
    echo "ERROR: build did not produce ${WAR}" >&2
    exit 1
fi

echo
echo "=================================================="
echo " Build complete: ${WAR}"
echo "=================================================="
echo
echo "Deploy the WAR with deptools.py:"
echo
echo "    deptools.py --deploy-war ${WAR}"
echo
echo "Then view it at (context path is 'helloworld'):"
echo
echo "    http://localhost:8090/helloworld/          (default greeting)"
echo "    http://localhost:8090/helloworld/hello     (same endpoint)"
echo "    http://localhost:8090/helloworld/hello?name=Avium"
echo
echo "Or copy the WAR straight into the webapps directory:"
echo
echo "    cp ${WAR} ${CATALINA_BASE:-/opt/tomcat/instances/${INSTANCE_NAME}}/webapps/"
echo
