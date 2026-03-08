# ------------------------------------------------------------------------------
#             NOTE: THIS FILE IS GENERATED VIA "generate_dockerfiles.py"
#
#                       PLEASE DO NOT EDIT IT DIRECTLY.
# ------------------------------------------------------------------------------
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ------------------------------------------------------------------------------

FROM redhat/ubi9-minimal

LABEL maintainer="Acunet <mansurudien@gmail.com>"

ENV JAVA_HOME=/opt/java/openjdk
ENV PATH=$JAVA_HOME/bin:$PATH
ENV TZ=Asia/Jakarta

# Default to UTF-8 file.encoding
ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'

RUN set -eux; \
    microdnf install -y \
        gzip \
        tar \
        xz \
        # Required for jlink
        binutils \
        tzdata \
        wget \
        # utilities for keeping UBI and OpenJDK CA certificates in sync
        # https://github.com/adoptium/containers/issues/293
        ca-certificates \
        # Needed to extract CN and generate aliases for certificates
        openssl \
        # java.lang.UnsatisfiedLinkError: libfontmanager.so: libfreetype.so.6: cannot open shared object file: No such file or directory
        # java.lang.NoClassDefFoundError: Could not initialize class sun.awt.X11FontManager
        # https://github.com/docker-library/openjdk/pull/235#issuecomment-424466077
        fontconfig \
        glibc-langpack-en \
        # Required for gpg in multi-arch-install
        gnupg2 \
        # Additional utilities
        which \
        hostname \
        # For msfonts installation
        libfontenc \
        pkg-config \
    ; \
    microdnf clean all

ENV JAVA_VERSION=jdk8u482-b08

RUN set -eux; \
    ARCH="$(rpm --query --queryformat='%{ARCH}' rpm)"; \
    case "${ARCH}" in \
       aarch64) \
         ESUM='ada72fbf191fb287b4c1e54be372b64c40c27c2ffbfa01f880c92af11f4e7c94'; \
         BINARY_URL='https://github.com/adoptium/temurin8-binaries/releases/download/jdk8u482-b08/OpenJDK8U-jdk_aarch64_linux_hotspot_8u482b08.tar.gz'; \
         ;; \
       ppc64le) \
         ESUM='e77ba337c3ebb37fbef4961299f13fc4db87996ffd5470bdfb460cfc2ddb6053'; \
         BINARY_URL='https://github.com/adoptium/temurin8-binaries/releases/download/jdk8u482-b08/OpenJDK8U-jdk_ppc64le_linux_hotspot_8u482b08.tar.gz'; \
         ;; \
       x86_64) \
         ESUM='e74becad56b4cc01f1556a671e578d3788789f5257f9499f6fbed84e63a55ecf'; \
         BINARY_URL='https://github.com/adoptium/temurin8-binaries/releases/download/jdk8u482-b08/OpenJDK8U-jdk_x64_linux_hotspot_8u482b08.tar.gz'; \
         ;; \
       *) \
         echo "Unsupported arch: ${ARCH}"; \
         exit 1; \
         ;; \
    esac; \
    wget --progress=dot:giga -O /tmp/openjdk.tar.gz ${BINARY_URL}; \
    wget --progress=dot:giga -O /tmp/openjdk.tar.gz.sig ${BINARY_URL}.sig; \
    export GNUPGHOME="$(mktemp -d)"; \
    # gpg: key 843C48A565F8F04B: "Adoptium GPG Key (DEB/RPM Signing Key) <temurin-dev@eclipse.org>" imported
    gpg --batch --keyserver keyserver.ubuntu.com --recv-keys 3B04D753C9050D9A5D343F39843C48A565F8F04B; \
    gpg --batch --verify /tmp/openjdk.tar.gz.sig /tmp/openjdk.tar.gz; \
    rm -rf "${GNUPGHOME}" /tmp/openjdk.tar.gz.sig; \
    echo "${ESUM} */tmp/openjdk.tar.gz" | sha256sum -c -; \
    mkdir -p "$JAVA_HOME"; \
    tar --extract \
        --file /tmp/openjdk.tar.gz \
        --directory "$JAVA_HOME" \
        --strip-components 1 \
        --no-same-owner \
    ; \
    rm -f /tmp/openjdk.tar.gz ${JAVA_HOME}/src.zip;

## Add Additional function to gather all memory to use##
COPY --chmod=755 src /opt/src/
COPY --chmod=755 ca /certificates/

RUN set -eux && \
    # Download APM agent
    latest_version=$(curl -s https://repo1.maven.org/maven2/co/elastic/apm/elastic-apm-agent/maven-metadata.xml \
        | sed -n 's:.*<latest>\(.*\)</latest>.*:\1:p') && \
    jar_url="https://repo1.maven.org/maven2/co/elastic/apm/elastic-apm-agent/${latest_version}/elastic-apm-agent-${latest_version}.jar" && \
    curl -sSL -o /opt/elastic-apm-agent.jar "$jar_url" && \
    chmod +x /opt/src/setup-env.d/*.bash && \
    # Cleanup: use rpm -e --nodeps to remove packages without checking dependencies
    rpm -e --nodeps cabextract xorg-x11-font-utils && \
    microdnf remove -y tar wget xz libfontenc pkg-config && \
    rm -rf /tmp/hsperfdata_root && \
    [ ! -d /var/cache/yum ] || rm -rf /var/cache/yum

RUN set -eux; \
    echo "Verifying install ..."; \
    echo "javac -version"; javac -version; \
    echo "java -version"; java -version; \
    echo "Complete."

COPY --chmod=755 entrypoint.sh /__entrypoint.sh
ENTRYPOINT ["/__entrypoint.sh"]
CMD ["java","-jar", "/app.jar"]