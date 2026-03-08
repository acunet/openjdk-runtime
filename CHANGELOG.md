# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-03-08

### 🎉 Initial Production Release

First stable production release of Acunet OpenJDK Runtime with intelligent automatic memory management.

### Added

#### Core Features
- Automatic container memory detection with cgroup v1 and v2 support
- Intelligent JVM tuning based on detected container memory limits
- Automatic garbage collector selection based on container size
  - SerialGC for containers < 512 MB
  - G1GC for containers 512 MB - 1 GB
  - ShenandoahGC for containers 1 GB - 4 GB
  - ZGC for containers > 4 GB
- Support for Kubernetes resource limit auto-detection
- Smart memory allocation across heap, metaspace, direct memory, and code cache

#### Java Versions
- Java 8 (LTS) - All base image variants
- Java 11 (LTS) - All base image variants
- Java 17 (LTS) - All base image variants (Recommended)
- Java 21 (LTS) - All base image variants
- Java 25 (Non-LTS) - Limited base image variants

#### Base Image Variants
- Alpine Linux 3.22, 3.23
- Red Hat UBI 9 Minimal
- Red Hat UBI 10 Minimal
- Red Hat UBI 10 Standard (RHEL)
- Ubuntu 22.04 (Jammy Jellyfish)
- Ubuntu 24.04 (Noble Numbat)

#### Environment Variables
- `HEAP_SIZE_RATIO` - Configure heap percentage (default: 60%)
- `HEAP_SIZE_MB` - Explicit heap size override
- `METASPACE_SIZE_MB` - Metaspace size override
- `DIRECT_MEMORY_RATIO` - Direct memory percentage (default: 7%)
- `CODE_CACHE_RATIO` - Code cache percentage (default: 3%)
- `COMPRESSED_CLASS_SPACE_MB` - Compressed class space size
- `USE_MEMORY_HIGH` - Enable cgroup v2 soft limit (default: 1)
- `JAVA_GC_OPTS` - Override automatic GC selection
- `JAVA_USER_OPTS` - Additional custom JVM options
- `JAVA_PRINT_CONFIG` - Print memory configuration at startup
- `JAVA_DIAGNOSTICS` - Enable detailed GC logging
- `KUBERNETES_MEMORY_LIMIT` - Manual memory limit override

#### Shutdown Diagnostics
- `SHUTDOWN_LOGGING_THREAD_DUMP` - Capture thread dumps on shutdown
- `SHUTDOWN_LOGGING_HEAP_INFO` - Capture heap info on shutdown
- `SHUTDOWN_LOGGING_SAMPLE_THRESHOLD` - Percentage of shutdowns to log
- `THREAD_DUMP_FILE` - Thread dump output location
- `HEAP_INFO_FILE` - Heap info output location
- `HEAP_SHOW_LINES_COUNT` - Lines of heap info to display

#### Security Features
- Custom CA certificate support via `USE_SYSTEM_CA_CERTS`
- Non-root user execution (where supported)
- Minimal attack surface
- Regular security updates from base images

#### Developer Experience
- Automated Dockerfile generation from templates
- Build and push automation scripts
- Comprehensive documentation and examples
- Troubleshooting guides

### Fixed

- Fixed shutdown script path resolution to use `/opt/src/shutdown/shutdown-env.bash`
- Fixed shutdown wrapper path resolution to use `/opt/src/shutdown/shutdown-wrapper.bash`
- Fixed utility script sourcing to use `/opt/src/setup-env.d/05-utils.bash`
- Corrected all hardcoded paths in shutdown-env.bash and shutdown-wrapper.bash

### Changed

- N/A (initial release)

### Deprecated

- N/A (initial release)

### Removed

- N/A (initial release)

### Security

- All images built with latest security patches from upstream base images
- Regular rebuild process established for ongoing security updates
- FIPS compliance ready for UBI-based images

---

## [Unreleased]

Future enhancements planned:
- JRE (runtime-only) variants for smaller image sizes
- ARM64/Apple Silicon architecture support
- Enhanced APM integrations (Datadog, New Relic, Dynatrace)
- GraalVM Native Image support
- Automatic JVM flag recommendations based on workload patterns
- Multi-architecture builds (amd64, arm64)

---

## Release Comparison

### v1.0.0 vs Upstream Adoptium Containers

| Feature | Adoptium Containers | Acunet v1.0.0 |
|---------|---------------------|---------------|
| Automatic Memory Detection | ❌ | ✅ |
| cgroup v2 Support | Partial | ✅ Full |
| Auto GC Selection | ❌ | ✅ |
| Container Size Optimization | ❌ | ✅ |
| Shutdown Diagnostics | ❌ | ✅ |
| Custom CA Certificates | Basic | ✅ Enhanced |
| Zero Configuration | ❌ | ✅ |
| Production Memory Safety | Manual | ✅ Automatic |

---

## Download

**Docker Hub:** https://hub.docker.com/r/acunet/openjdk-runtime

```bash
# Pull recommended image
docker pull acunet/openjdk-runtime:17-jdk-ubi10-rhel

# Or choose your preferred variant
docker pull acunet/openjdk-runtime:17-jdk-alpine-3.23
docker pull acunet/openjdk-runtime:17-jdk-ubi10-minimal
docker pull acunet/openjdk-runtime:17-jdk-ubuntu-noble
```

---

## Support

- **Repository:** https://github.com/acunet/openjdk-runtime
- **Issues:** https://github.com/acunet/openjdk-runtime/issues
- **Discussions:** https://github.com/acunet/openjdk-runtime/discussions

---

## Credits

Built on the excellent work of:
- Eclipse Adoptium Team
- Adoptium Containers Project
- Red Hat (UBI Images)
- Alpine Linux Community
- Ubuntu/Canonical

**License:** Apache 2.0

---

**📖 Full Release Notes:** [RELEASE_NOTES_v1.0.0.md](RELEASE_NOTES_v1.0.0.md)

[1.0.0]: https://github.com/acunet/openjdk-runtime/releases/tag/v1.0.0
[Unreleased]: https://github.com/acunet/openjdk-runtime/compare/v1.0.0...HEAD

