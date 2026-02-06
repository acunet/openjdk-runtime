# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-01-20

### 🎉 First Production Release - Acunet OpenJDK Runtime

This is the first production release of the customized OpenJDK runtime images with comprehensive automatic memory detection, memory management, and cgroup v2 support for enterprise-grade containerized environments.

### ✨ Added

#### Automatic Memory Management
- **cgroup v2 Support**: Full support for modern Kubernetes clusters (1.25+) with cgroup v2
- **Intelligent Memory Detection**: Auto-detects container memory limits from both cgroup v1 and v2
- **Smart Path Resolution**: Automatically finds container's actual cgroup path instead of root
- **Soft Limit Support**: Respects `memory.high` (soft limit) in addition to `memory.max` (hard limit)
- **Memory Calculation Functions**: 
  - `GetAvailableMemory()`: Detects memory from cgroup v1, v2, or environment variables
  - `calculate_metaspace()`: Industry-recommended fixed-size metaspace based on container size
  - `calculate_compressed_class_space()`: Optimal compressed class space sizing

#### JVM Configuration Options
- **Configurable Memory Ratios**:
  - `HEAP_SIZE_RATIO`: Heap percentage (default: 60%)
  - `DIRECT_MEMORY_RATIO`: Direct memory for NIO (default: 7%)
  - `CODE_CACHE_RATIO`: JIT code cache (default: 3%)
  - `THREAD_STACK_SIZE`: Thread stack size in KB (default: 512)
- **Automatic GC Selection**: 
  - SerialGC for containers < 512MB
  - G1GC for 512MB - 1GB
  - ShenandoahGC for 1-4GB  
  - ZGC for containers > 4GB
- **APM Integration**: Conditional APM agent support with full configuration options
- **Diagnostics Support**: Optional GC logging and memory configuration printing

#### Environment Variables
- `HEAP_SIZE_MB`: Override automatic heap calculation
- `METASPACE_SIZE_MB`: Override automatic metaspace calculation
- `COMPRESSED_CLASS_SPACE_MB`: Compressed class space size
- `USE_MEMORY_HIGH`: Enable/disable memory.high detection for cgroup v2 (default: 1)
- `JAVA_PRINT_CONFIG`: Print memory configuration on startup
- `JAVA_DIAGNOSTICS`: Enable detailed GC logging
- `ENABLE_APM`: Enable/disable APM agent
- `APM_SERVICE_NAME`: APM service identifier
- `APM_ENVIRONMENT`: Deployment environment name
- `APM_SERVER_URL`: APM server endpoint

#### Documentation
- **Comprehensive README**: 
  - Complete automatic memory management documentation
  - cgroup v1 vs v2 comparison tables
  - Memory allocation strategy tables
  - GC selection guide
  - Environment variable tuning guide
  - Production configuration examples
  - Troubleshooting section with debug commands
  - Verification commands for memory detection
  - Kubernetes and Docker deployment examples

### 🔄 Changed

#### Memory Detection Logic
- **Priority Order**:
  1. `KUBERNETES_MEMORY_LIMIT` environment variable
  2. cgroup v2 detection (with container path resolution)
  3. cgroup v1 detection
  4. Fallback to system memory - 400MB
- **cgroup v2 Implementation**: Reads actual container path from `/proc/self/cgroup` instead of hardcoded root path
- **Soft Limit Handling**: Takes minimum of `memory.max` and `memory.high` when enabled
- **Error Handling**: Proper handling of "max" (unlimited) and very large values

#### Memory Allocation Strategy
- **Heap Ratio**: Set to 60% for optimal application performance
- **Metaspace**: Fixed sizes based on industry recommendations (128-256MB)
- **Compressed Class Space**: Added 20% of metaspace allocation
- **Total Overhead**: ~30% reserved for native memory, threads, and JVM overhead

#### JVM Options Assembly
- **Consistent Formatting**: Fixed memory unit consistency
- **Modular Configuration**: Separate variables for heap, metaspace, GC, native memory
- **Conditional APM**: Only loads APM agent if configured and available
- **Enhanced Diagnostics**: Optional heap dump and GC logging

### 🚀 Improved

#### Container Compatibility
- **Kubernetes 1.25+**: Full cgroup v2 support for modern clusters
- **Memory Units**: Works with both binary (Gi, Mi) and decimal (G, M) units
- **Path Normalization**: Handles various cgroup mount paths automatically
- **Unlimited Detection**: Properly handles unlimited memory scenarios
- **Cross-Platform**: Compatible with Docker, Kubernetes, OpenShift, and Rancher

#### Memory Safety
- **OOM Prevention**: Better allocation to prevent container OOMKilled
- **Overhead Reservation**: Explicit reservation for native memory
- **Thread Stack Optimization**: Optimized per-thread stack sizes
- **Metaspace Capping**: Fixed maximum sizes prevent excessive allocation

#### Performance
- **GC Tuning**: Container-size-aware GC algorithm selection
- **Heap Pre-touch**: Optional heap pre-touching for predictable performance
- **GC Optimization**: Prevents unnecessary full GCs
- **G1 Region Sizing**: Optimized for small to large containers

### 🐛 Fixed

#### Critical Fixes
- **cgroup v2 Detection**: Fixed memory detection that only returned "max" value
- **String Arithmetic**: Fixed improper division before value validation
- **Memory Unit Handling**: Fixed inconsistent memory unit formatting
- **Path Resolution**: Added proper container path detection via `/proc/self/cgroup`

#### Memory Calculation
- **Unlimited Values**: Properly detects and handles unlimited cgroup values
- **Fallback Logic**: Fixed empty memory variable handling
- **Error Handling**: Added proper null checks and error management

### 📦 Files Modified

#### Core Configuration
- `config/src/setup-env.d/30-java-env.bash`: Enhanced with cgroup v2 support and improved memory detection
- `config/src/setup-env.d/checkmemory.bash`: Reference implementation for memory detection
- `README.md`: Added comprehensive automatic memory management documentation

### 📊 Memory Allocation Table

| Container | Heap (60%) | Metaspace | CompClass | Direct (7%) | CodeCache (3%) | Overhead |
|-----------|------------|-----------|-----------|-------------|----------------|----------|
| 512 MB    | 307 MB     | 128 MB    | 26 MB     | 36 MB       | 15 MB          | 82 MB    |
| 1 GB      | 614 MB     | 128 MB    | 26 MB     | 71 MB       | 30 MB          | 309 MB   |
| 2 GB      | 1228 MB    | 256 MB    | 51 MB     | 143 MB      | 61 MB          | 541 MB   |
| 4 GB      | 2457 MB    | 256 MB    | 51 MB     | 286 MB      | 123 MB         | 1082 MB  |

### 🎯 Use Cases

This release optimizes for:
- **Kubernetes Deployments**: Automatic detection from resource limits
- **Modern Clusters**: Full cgroup v2 support (Kubernetes 1.25+)
- **Mixed Environments**: Works with both cgroup v1 and v2
- **Microservices**: Optimized for containers 256MB - 4GB
- **Enterprise Applications**: Support for large containers up to 16GB+
- **Spring Boot**: Ready-to-use with Spring Boot applications
- **Cloud Native**: Docker, Kubernetes, OpenShift, and Rancher compatible
- **APM Monitoring**: Integrated application performance monitoring support

### 🔗 Integration

#### Container Orchestration
- Works seamlessly with Kubernetes resource limits
- Environment variables configurable via deployment specs
- Automatic memory detection from cgroup information
- No manual configuration required for standard deployments

#### Supported Platforms
- **Kubernetes**: 1.19+ (cgroup v1), 1.25+ (cgroup v2) - Recommended 1.25+
- **Docker**: 19.03+ (cgroup v1), 20.10+ (cgroup v2)
- **OpenShift**: 4.10+
- **Rancher**: 2.6+
- **Podman**: 3.0+

#### Base Images
- **Alpine Linux**: Lightweight, security-focused (3.22, 3.23)
- **Red Hat UBI Minimal**: RHEL-compatible, minimal footprint (ubi9, ubi10)
- **Red Hat UBI Standard**: RHEL-compatible, full features (ubi9, ubi10)

### 🔍 Verification

Check memory detection in your container:
```bash
# View cgroup version
cat /proc/self/cgroup

# Check detected memory (cgroup v2)
cat /sys/fs/cgroup/$(awk -F: '$1=="0"{print $3}' /proc/self/cgroup)/memory.max

# View JVM configuration
echo $JAVA_OPTS

# Check memory limits (cgroup v2)
cat /sys/fs/cgroup/$(awk -F: '$1=="0"{print $3}' /proc/self/cgroup)/memory.high
```

### ⚠️ Breaking Changes

None - First production release

### 🙏 Credits

**Project**: Acunet OpenJDK Runtime  
**Repository**: [acunet/openjdk-runtime](https://github.com/acunet/openjdk-runtime)  
**Based on**: [Eclipse Adoptium Containers](https://github.com/adoptium/containers)  
**License**: Apache 2.0  
**Support**: Use [GitHub Issues](https://github.com/acunet/openjdk-runtime/issues) for support and feature requests

---

## [Unreleased]

### Added
- Initial development setup for automatic memory management with cgroup v2 support
- Core Java environment configuration scripts
- Memory detection and calculation utilities
- Support for Alpine Linux and Red Hat UBI base images
- Comprehensive documentation and examples

### Changed
- Enhanced memory detection to support both cgroup v1 and cgroup v2
- Improved JVM configuration assembly for better container compatibility
- Updated base image handling for enterprise deployments

### Removed
- Removed platform-specific limitations in favor of universal container support
