# OpenJDK Runtime Containers

An enterprise-grade, production-ready Docker image for Eclipse Temurin (OpenJDK) with intelligent automatic memory management, cgroup v2 support, and optimizations for cloud-native deployments.

**Repository:** [acunet/openjdk-runtime](https://github.com/acunet/openjdk-runtime)  
**Docker Hub:** [acunet/openjdk-runtime](https://hub.docker.com/r/acunet/openjdk-runtime)  
**License:** Apache 2.0  
**Status:** Production Ready (v1.0.0+)

This repository is a fork of the official [Adoptium Containers](https://github.com/adoptium/containers) repository. It contains the Dockerfiles for building custom Eclipse Temurin (OpenJDK) images tailored for enterprise-grade containerized environments.

---

## 🌟 Key Highlights

### What Makes This Special

✅ **Automatic Memory Management** - No more manual JVM tuning. Our images intelligently detect container memory limits and automatically configure optimal JVM settings.

✅ **Modern Kubernetes Ready** - Full support for cgroup v2 (Kubernetes 1.25+), the industry standard for modern container platforms.

✅ **Zero Configuration** - Works out-of-the-box. Place your JAR in the image and it automatically adapts to any container size.

✅ **Enterprise Grade** - Production-tested with support for legacy (Java 8) through cutting-edge (Java 25) versions.

✅ **Multiple Base Images** - Choose from Alpine (minimal), UBI Minimal (RHEL-compatible), or UBI Standard (full-featured).

✅ **Security Focused** - Regular security updates, non-root execution, and minimal attack surface.

---

## 📊 Performance & Features

### Intelligent Automatic Memory Management

Our container images include the most advanced memory detection and JVM configuration system available:

**Memory Detection Priority:**
1. `KUBERNETES_MEMORY_LIMIT` environment variable (manual override)
2. **cgroup v2** memory limits - Modern Kubernetes clusters
3. **cgroup v1** memory limits - Older systems
4. System memory fallback - Container-aware fallback

**Example:** Deploy a Java application with a 1GB container limit:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
spec:
  template:
    spec:
      containers:
      - name: app
        image: acunet/openjdk-runtime:17-jdk-ubi10-rhel
        resources:
          limits:
            memory: "1024Mi"  # Container limit
          requests:
            memory: "512Mi"
```

**Automatic Result:**
- ✅ Heap Memory: ~614 MB (60% of limit)
- ✅ Metaspace: 128 MB (class metadata)
- ✅ Direct Memory: ~71 MB (NIO buffers)
- ✅ Code Cache: ~30 MB (JIT compilation)
- ✅ Overhead: ~309 MB (reserved)
- ✅ **No OOMKilled errors** - Properly balanced allocation

### cgroup v2 Support (Kubernetes 1.25+)

Modern Kubernetes clusters use cgroup v2 for better resource accounting and isolation:

| Feature | cgroup v1 | cgroup v2 |
|---------|-----------|-----------|
| **Memory Accuracy** | Good | Excellent - Includes all memory types |
| **Soft Limits** | No | Yes - `memory.high` throttles before OOM |
| **Performance** | Baseline | Better - More efficient accounting |
| **Modern K8s** | < 1.25 | 1.25+ (Recommended) |
| **Our Support** | ✅ Full | ✅ Full |

### Automatic Garbage Collector Selection

Our images choose the optimal GC algorithm based on container memory:

| Memory | GC Algorithm | Best For | Latency | Throughput |
|--------|--------------|----------|---------|-----------|
| < 512 MB | SerialGC | Tiny containers, minimal overhead | Medium | High |
| 512 MB - 1 GB | G1GC | Small apps, balanced performance | Low | High |
| 1 GB - 4 GB | ShenandoahGC | Medium apps, low latency | Very Low | Good |
| > 4 GB | ZGC | Large apps, extreme low latency | Ultra-Low | Good |

No configuration needed - happens automatically!

### Memory Allocation Strategy

For a **2GB** container, here's what gets allocated automatically:

| Component | Allocation | Purpose |
|-----------|-----------|---------|
| **Heap** | ~1.2 GB (60%) | Java object storage |
| **Metaspace** | 256 MB | Class metadata |
| **Direct Memory** | ~143 MB (7%) | NIO buffers |
| **Code Cache** | ~61 MB (3%) | JIT compiled code |
| **Overhead** | ~541 MB | Native threads, GC, stacks |

---

## 🚀 Why Choose Acunet OpenJDK Runtime

### Problem Solved: Manual JVM Tuning

**Before (Traditional Approach):**
```bash
# You need to manually calculate and set these for EACH container size
java -Xmx614m -Xms614m -XX:MetaspaceSize=128m -XX:MaxMetaspaceSize=128m \
  -XX:+UseG1GC -XX:MaxGCPauseMillis=200 -jar app.jar
```

**After (Acunet OpenJDK Runtime):**
```bash
# Just deploy - it auto-configures!
docker run -m 1024m acunet/openjdk-runtime:17-jdk-ubi10-rhel
# 👆 Automatically gets all the JVM tuning above!
```

### Real-World Benefits

#### 1. **Prevents OOMKilled Errors**
Traditional JVM configurations often allocate heap too large, causing Kubernetes to kill the container. Our images reserve appropriate memory for the JVM overhead, preventing crashes.

#### 2. **Works Across All Container Sizes**
Same image works optimally whether you allocate 256MB or 8GB. No image rebuilding needed for different deployments.

#### 3. **Kubernetes Native**
Automatically detects resource limits from your Kubernetes deployment specs. No environment variable configuration required for standard setups.

#### 4. **Development to Production Parity**
Same image works in Docker on your laptop, dev cluster, staging, and production - with optimal settings at each stage.

#### 5. **Reduces DevOps Overhead**
No need for JVM tuning expertise. Modern teams can deploy without memory configuration knowledge.

---

## 📦 Supported Images

We currently support and maintain images for the following Operating Systems:

*   **Alpine Linux** - Minimal footprint (~150-200 MB)
*   **Red Hat Universal Base Image (UBI)** - Enterprise RHEL compatible
*   **Ubuntu** - Standard Linux distribution

### Available Docker Image URLs

Based on the current build configuration, the following images are published to public registries.

### Docker Hub (acunet/openjdk-runtime)

#### JDK 8 (LTS, End of Support: Dec 2030)
*   `acunet/openjdk-runtime:8-jdk-3.22`
*   `acunet/openjdk-runtime:8-jdk-3.23`
*   `acunet/openjdk-runtime:8-jdk-ubi9-minimal`
*   `acunet/openjdk-runtime:8-jdk-ubi10-minimal` **(Latest)**

#### JDK 11 (LTS, End of Support: Sep 2026)
*   `acunet/openjdk-runtime:11-jdk-3.22`
*   `acunet/openjdk-runtime:11-jdk-3.23`
*   `acunet/openjdk-runtime:11-jdk-ubi9-minimal`
*   `acunet/openjdk-runtime:11-jdk-ubi10-minimal` **(Latest)**

#### JDK 17 (LTS, End of Support: Sep 2029) - **Recommended**
*   `acunet/openjdk-runtime:17-jdk-3.22`
*   `acunet/openjdk-runtime:17-jdk-3.23`
*   `acunet/openjdk-runtime:17-jdk-ubi9-minimal`
*   `acunet/openjdk-runtime:17-jdk-ubi10-minimal` **(Latest)**

#### JDK 21 (LTS, End of Support: Sep 2031)
*   `acunet/openjdk-runtime:21-jdk-3.22`
*   `acunet/openjdk-runtime:21-jdk-3.23`
*   `acunet/openjdk-runtime:21-jdk-ubi9-minimal`
*   `acunet/openjdk-runtime:21-jdk-ubi10-minimal` **(Latest)**

#### JDK 25 (Non-LTS, End of Support: Sep 2026)
*   `acunet/openjdk-runtime:25-jdk-3.22`
*   `acunet/openjdk-runtime:25-jdk-3.23`
*   `acunet/openjdk-runtime:25-jdk-ubi10-minimal` **(Latest)**

## Maintenance

This repository is maintained by the Acunet community for the open-source ecosystem.

**Maintainer:** Acunet (open-source project) — please use repository [Issues](https://github.com/acunet/openjdk-runtime/issues) for support and questions.

---

## 🎯 Image Variants

This repository provides several variants of OpenJDK images to suit different use cases:

### Alpine Linux Based Images
- **Tag Format:** `{version}-jdk-{alpine-version}`
- **Examples:** `8-jdk-3.22`, `11-jdk-3.23`, `17-jdk-3.23`
- **Base:** Alpine Linux (lightweight distribution)
- **Size:** Small footprint (~150-200 MB)
- **Use Case:** Production deployments where image size is critical, microservices
- **Package Manager:** apk
- **When to Use:** Cloud cost optimization, high-scale deployments, container registries with size limits

### Red Hat Universal Base Image (UBI) - Minimal
- **Tag Format:** `{version}-jdk-ubi{9|10}-minimal`
- **Examples:** `8-jdk-ubi9-minimal`, `11-jdk-ubi10-minimal`
- **Base:** Red Hat UBI Minimal (enterprise standard)
- **Size:** Minimal footprint (~120-180 MB)
- **Use Case:** Enterprise deployments requiring Red Hat compatibility with minimal size
- **Package Manager:** microdnf
- **Support:** Red Hat Universal Base Image (suitable for air-gapped environments)
- **When to Use:** Enterprise RHEL compliance required, security scanning with Red Hat CVE database, small container size preferred

### Red Hat Universal Base Image (UBI) - Standard
- **Tag Format:** `{version}-jdk-ubi{9|10}-rhel`
- **Examples:** `8-jdk-ubi10-rhel`, `11-jdk-ubi10-rhel`
- **Base:** Red Hat UBI Standard (full-featured enterprise)
- **Size:** Full-featured (~300-400 MB)
- **Use Case:** Enterprise deployments requiring full Red Hat compatibility and complete toolset
- **Package Manager:** dnf/yum
- **Support:** Red Hat Universal Base Image with full package ecosystem
- **Benefits:**
  - Enterprise-grade security updates from Red Hat
  - Full Red Hat package compatibility
  - Compliance with enterprise security policies
  - Better for debugging with complete toolset
  - Recommended for production workloads requiring RHEL compliance
  - Additional tools available for troubleshooting
- **When to Use:** Enterprise production deployments, security compliance required, debugging tools needed, maximum compatibility with RHEL ecosystem

## Version Selection Guide

### Java Version Selection

| Java Version | LTS Status | End of Support | Recommended For | Risk Level |
|--------------|------------|----------------|-----------------|------------|
| Java 8 | LTS | Dec 2030 | Legacy applications, stability-critical systems | Low - Very stable |
| Java 11 | LTS | Sep 2026 | Enterprise applications, balanced features/stability | Low - Mature |
| Java 17 | LTS | Sep 2029 | Modern applications, new projects **(RECOMMENDED)** | Low - Current standard |
| Java 21 | LTS | Sep 2031 | Latest LTS, cutting-edge features | Low - Latest LTS |
| Java 25 | Non-LTS | Sep 2026 | Early adopters, testing new features | Medium - Experimental |

### Base Image Selection

| Base Image | Use When | Avoid When | Size | Compliance |
|------------|----------|------------|------|-----------|
| Alpine | Image size is critical, standard deployment, cost-sensitive | Need RHEL compliance, require debugging tools | ~150-200 MB | Community supported |
| UBI Minimal | Need RHEL compatibility, smaller image preferred, enterprise required | Maximum toolset needed | ~120-180 MB | Red Hat enterprise support |
| UBI RHEL **(Recommended)** | Enterprise compliance required, full toolset needed, production workloads | Image size is primary concern, minimal footprint required | ~300-400 MB | Red Hat enterprise support + tools |

---

## 💡 Usage Examples

These images include enterprise-grade optimizations such as:
*   Automatic container memory detection and JVM tuning
*   Pre-configured environment settings (e.g., Timezone, Resource Management)
*   Support for cgroup v1 and v2
*   Security-focused base images
*   Garbage collector auto-tuning
*   Thread pool optimization

### Quick Start Examples

#### Using with Docker

```dockerfile
# Alpine-based image (smaller size)
FROM acunet/openjdk-runtime:17-jdk-3.23

# UBI Minimal (RHEL compatible, minimal)
FROM acunet/openjdk-runtime:17-jdk-ubi10-minimal

# UBI RHEL (RHEL compatible, full-featured) - Recommended for Enterprise
FROM acunet/openjdk-runtime:8-jdk-ubi10-rhel
```

#### Example Dockerfile for Spring Boot Application

```dockerfile
# Build stage
FROM acunet/openjdk-runtime:17-jdk-ubi10-rhel as builder
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN ./mvnw clean package -DskipTests

# Runtime stage
FROM acunet/openjdk-runtime:17-jdk-ubi10-minimal
WORKDIR /app
COPY --from=builder /app/target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
```

#### Using with Kubernetes

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
    spec:
      containers:
      - name: app
        image: acunet/openjdk-runtime:17-jdk-ubi10-rhel
        ports:
        - containerPort: 8080
        resources:
          limits:
            memory: "1Gi"
            cpu: "1000m"
          requests:
            memory: "512Mi"
            cpu: "500m"
        livenessProbe:
          httpGet:
            path: /health
            port: 8080
          initialDelaySeconds: 30
          periodSeconds: 10
```

---

## ✨ Advanced Features & Customizations

All images include the following optimizations:

### Pre-installed Components
- **Timezone:** Pre-configured to UTC (configurable via `TZ` environment variable)
- **Performance Tuning:** Optimized for containerized environments
- **Memory Management:** Automatic cgroup detection and JVM configuration
- **Security:** Non-root user execution (where supported by base image)

### Automatic Memory Management (The Core Innovation)

All images include intelligent automatic memory detection and JVM tuning that works with both **cgroup v1** and **cgroup v2** (required for modern Kubernetes clusters).

#### How It Works

The images automatically detect container memory limits from Kubernetes/Docker and calculate optimal JVM settings:

```yaml
# Kubernetes resource definition example
resources:
  requests:
    cpu: "10m"
    memory: "586Mi"
  limits:
    cpu: "1"
    memory: "1024Mi"
```

**Automatic Memory Detection Priority:**
1. `KUBERNETES_MEMORY_LIMIT` environment variable (if set)
2. **cgroup v2** memory limits (`/sys/fs/cgroup/memory.max` and `memory.high`)
3. **cgroup v1** memory limits (`/sys/fs/cgroup/memory/memory.limit_in_bytes`)
4. System memory fallback (MemTotal - 400MB buffer)

#### Memory Allocation Strategy

For a **1024Mi** container limit, the JVM automatically allocates:

| Component | Default Ratio | Calculated Size | Purpose |
|-----------|--------------|-----------------|---------|
| **Heap Memory** | 60% | ~614 MB | Java object storage (-Xmx/-Xms) |
| **Metaspace** | Fixed | 128 MB | Class metadata (scaled based on total memory) |
| **Direct Memory** | 7% | ~71 MB | NIO buffers, native memory |
| **Code Cache** | 3% | ~30 MB | JIT compiled code |
| **Overhead** | ~30% | ~309 MB | Native memory, thread stacks, GC overhead |

#### Metaspace Sizing

Metaspace uses fixed sizes based on container memory (not percentage-based):

| Container Memory | Metaspace Size |
|------------------|----------------|
| ≤ 512 MB | 128 MB |
| ≤ 1024 MB | 128 MB |
| ≤ 2048 MB | 256 MB |
| ≤ 4096 MB | 256 MB |
| > 4096 MB | 256 MB (capped) |

#### cgroup v2 Support (Kubernetes 1.25+)

Modern Kubernetes clusters use cgroup v2 by default. Our images fully support both versions:

**cgroup v1 (legacy):**
- File: `/sys/fs/cgroup/memory/memory.limit_in_bytes`
- Used by: Kubernetes < 1.25, older Docker versions
- Memory accounting: Basic

**cgroup v2 (modern):**
- Hard limit: `/sys/fs/cgroup/memory.max`
- Soft limit: `/sys/fs/cgroup/memory.high` (triggers throttling before OOM)
- Used by: Kubernetes ≥ 1.25, modern Docker/containerd
- Memory accounting: More accurate, includes all memory types
- **Benefit:** More accurate memory accounting and better container isolation
- **Recommended:** Use cgroup v2 for all new Kubernetes deployments

#### Environment Variables for Tuning

Override defaults by setting these environment variables:

```yaml
# Kubernetes deployment example
env:
- name: HEAP_SIZE_RATIO
  value: "70"  # Increase heap to 70% (default: 60%)
- name: METASPACE_SIZE_MB
  value: "256" # Override automatic metaspace calculation
- name: DIRECT_MEMORY_RATIO
  value: "10"  # Increase direct memory to 10% (default: 7%)
- name: CODE_CACHE_RATIO
  value: "5"   # Increase code cache to 5% (default: 3%)
- name: USE_MEMORY_HIGH
  value: "1"   # Enable soft limit detection for cgroup v2 (default: 1)
- name: JAVA_USER_OPTS
  value: "-XX:+UseG1GC -XX:MaxGCPauseMillis=200"  # Add custom JVM options
```

#### Garbage Collector Selection

GC is automatically selected based on container memory:

| Memory Size | GC Algorithm | Reason | Latency | Throughput |
|------------|--------------|---------|---------|-----------|
| < 512 MB | SerialGC | Low overhead for small heaps | Medium | High |
| 512 MB - 1 GB | G1GC | Balanced for medium containers | Low | High |
| 1 GB - 4 GB | ShenandoahGC | Low-latency, concurrent GC | Very Low | Good |
| > 4 GB | ZGC | Ultra-low latency for large heaps | Ultra-Low | Good |

Override with:
```yaml
env:
- name: JAVA_GC_OPTS
  value: "-XX:+UseG1GC -XX:MaxGCPauseMillis=100"
```

#### Verification

Check memory detection inside your container:

```bash
# View cgroup path (cgroup v2)
cat /proc/self/cgroup

# Check memory limits (cgroup v2)
cat /sys/fs/cgroup/$(awk -F: '$1=="0"{print $3}' /proc/self/cgroup)/memory.max
cat /sys/fs/cgroup/$(awk -F: '$1=="0"{print $3}' /proc/self/cgroup)/memory.high

# View calculated JVM options
echo $JAVA_OPTS

# View JVM settings at startup (included by default)
# Look for container logs showing:
# - VM settings
# - Detected memory
# - Applied JVM options
```

#### Example: Custom Memory Configuration

```dockerfile
FROM acunet/openjdk-runtime:17-jdk-ubi10-rhel

# Application with custom memory settings
ENV HEAP_SIZE_RATIO=75
ENV METASPACE_SIZE_MB=192
ENV JAVA_USER_OPTS="-XX:+UseStringDeduplication -XX:+ParallelRefProcEnabled"

COPY target/app.jar /app/app.jar
WORKDIR /app
ENTRYPOINT ["java", "-jar", "app.jar"]
```

```yaml
# Kubernetes deployment with 2GB limit
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
spec:
  template:
    spec:
      containers:
      - name: app
        image: acunet/openjdk-runtime:17-jdk-ubi10-minimal
        resources:
          limits:
            memory: "2048Mi"
          requests:
            memory: "1024Mi"
        env:
        - name: HEAP_SIZE_RATIO
          value: "70"  # 70% of 2048Mi = ~1433MB heap
```

## APM

This runtime bundles the Elastic APM Java agent at `/opt/elastic-apm-agent.jar`, but it is disabled by default. To enable it, set `ENABLE_APM=true` at runtime.

### Environment Variables
- `JAVA_OPTS`: JVM options can be passed via this environment variable
- `TZ`: Timezone (default: UTC)
- `MALLOC_ARENA_MAX`: Memory optimization for containerized environments
- `HEAP_SIZE_RATIO`: Percentage of container memory for heap (default: 60)
- `HEAP_SIZE_MB`: Override automatic heap calculation (explicit size in MB)
- `METASPACE_SIZE_MB`: Override automatic metaspace calculation
- `COMPRESSED_CLASS_SPACE_MB`: Compressed class space size
- `DIRECT_MEMORY_RATIO`: Percentage for direct memory (default: 7)
- `CODE_CACHE_RATIO`: Percentage for code cache (default: 3)
- `USE_MEMORY_HIGH`: Enable cgroup v2 soft limit (default: 1)
- `JAVA_USER_OPTS`: Additional custom JVM options
- `JAVA_GC_OPTS`: Override automatic GC selection
- `KUBERNETES_MEMORY_LIMIT`: Manual memory limit override (bytes)
- `JAVA_PRINT_CONFIG`: Print memory configuration on startup
- `JAVA_DIAGNOSTICS`: Enable detailed GC logging

### Security Features
- Regular security updates from base image providers
- Non-root user execution (where applicable)
- Minimal attack surface (especially in minimal variants)
- No embedded secrets or credentials
- Compliance-ready (FIPS, air-gapped deployments supported)

---

## 🔧 Building Custom Images

If you need to build custom images based on these:

```dockerfile
FROM acunet/openjdk-runtime:17-jdk-ubi10-rhel

# Install additional packages (UBI RHEL example)
USER root
RUN dnf install -y <package-name> && dnf clean all

# Add your customizations
COPY custom-scripts/ /opt/scripts/
RUN chmod +x /opt/scripts/*.sh

# Switch back to non-root user
USER 1001
```

---

## 🐛 Troubleshooting

### Common Issues

**Issue: Memory detection not working / "max" returned**
```bash
# Debug cgroup detection
kubectl exec -it <pod-name> -- bash

# Check cgroup version
if [ -f /sys/fs/cgroup/cgroup.controllers ]; then 
  echo "cgroup v2"
else 
  echo "cgroup v1"
fi

# For cgroup v2, check actual container path
cat /proc/self/cgroup
# Should show: 0::/kubepods/burstable/pod.../container...

# Check memory limit at container's cgroup path
CG_PATH=$(awk -F: '$1=="0"{print $3}' /proc/self/cgroup)
cat /sys/fs/cgroup${CG_PATH}/memory.max
cat /sys/fs/cgroup${CG_PATH}/memory.high  # soft limit

# Verify environment detection
env | grep -E 'KUBERNETES_MEMORY_LIMIT|HEAP_SIZE_MB|METASPACE_SIZE_MB'
```

**Issue: Container OOMKilled despite proper limits**
```yaml
# Ensure JVM respects container limits
resources:
  limits:
    memory: "2048Mi"
  requests:
    memory: "1024Mi"
env:
- name: HEAP_SIZE_RATIO
  value: "60"  # Lower if still getting OOM (try 50-55)
- name: METASPACE_SIZE_MB
  value: "128" # Ensure metaspace is not too large
```

```bash
# Monitor actual memory usage
kubectl top pod <pod-name>

# Check container memory metrics
kubectl exec -it <pod-name> -- cat /sys/fs/cgroup/$(awk -F: '$1=="0"{print $3}' /proc/self/cgroup)/memory.current
```

**Issue: JVM heap too small or too large**
```yaml
# Adjust heap ratio
env:
- name: HEAP_SIZE_RATIO
  value: "70"  # Increase from default 60%

# Or set explicit heap size (bypasses automatic calculation)
env:
- name: HEAP_SIZE_MB
  value: "1536"  # Explicit 1.5GB heap
```

**Issue: Permission denied when running application**
```bash
# Ensure proper file permissions
RUN chmod -R 755 /app
```

**Issue: Out of Memory errors**
```bash
# Set appropriate JVM memory settings
ENV JAVA_OPTS="-Xmx512m -Xms256m"
```

**Issue: Missing packages in minimal images**
```dockerfile
# For UBI minimal, use microdnf
USER root
RUN microdnf install -y <package> && microdnf clean all
USER 1001
```

**Issue: Need to debug JVM settings at runtime**
```yaml
# Enable JVM diagnostics
env:
- name: JAVA_USER_OPTS
  value: "-XX:+PrintFlagsFinal -XX:+PrintCommandLineFlags"
  
# Check logs for output like:
# VM settings:
#   Max. Heap Size: 614MB
#   Metaspace Size: 128MB
```

---

## 📈 Image Updates & Versioning

- **Alpine versions** (3.22, 3.23): Track Alpine Linux release cycle
- **UBI versions** (ubi9, ubi10): Track Red Hat UBI major versions
- **Latest tags:** Images marked as **(Latest)** are recommended for new deployments
- **Security updates:** Images are rebuilt regularly to include latest security patches
- **Release cycle:** New versions aligned with Adoptium/OpenJDK releases

---

## 🏗️ Building Images

This repository includes a build script (`build_and_push.sh`) to automate building and pushing OpenJDK images to public registries.

### Prerequisites

- Docker installed and running
- Authenticated to target registries (Docker Hub):
  - `docker login`

### Build Script Usage

The `build_and_push.sh` script supports flexible building options:

#### Basic Commands

```bash
# Build and push all versions to Docker Hub
./build_and_push.sh

# Build all versions locally (no push)
./build_and_push.sh --build-only
# or
./build_and_push.sh -b

# Show help
./build_and_push.sh --help
```

#### Build Specific Versions

```bash
# Build only Java 17
./build_and_push.sh --version 17
# or
./build_and_push.sh -v 17

# Build multiple versions (Java 8, 11, and 17)
./build_and_push.sh -v 8,11,17

# Build Java 21 and 25
./build_and_push.sh -v 21,25
```

#### Combined Options

```bash
# Build Java 17 only, no push (for testing)
./build_and_push.sh -v 17 --build-only
# or
./build_and_push.sh -v 17 -b

# Build LTS versions only (8, 11, 17, 21), no push
./build_and_push.sh -v 8,11,17,21 -b

# Build and push Java 17 to Docker Hub
./build_and_push.sh -v 17
```

### Build Script Options

| Option | Short | Description | Example |
|--------|-------|-------------|---------|
| `--build-only` | `-b` | Build images without pushing | `./build_and_push.sh -b` |
| `--version` | `-v` | Build specific version(s) only | `./build_and_push.sh -v 17` |
| `--help` | `-h` | Show usage information | `./build_and_push.sh -h` |

### Available Versions

- **Java 8** (LTS) - Legacy support
- **Java 11** (LTS) - Enterprise standard
- **Java 17** (LTS) - **Recommended** - Current industry standard
- **Java 21** (LTS) - Latest LTS
- **Java 25** (Non-LTS) - Experimental features

### Build Output

The script builds all variants for each selected version:

**For Alpine:**
- `8-jdk-3.22`, `8-jdk-3.23`
- `11-jdk-3.22`, `11-jdk-3.23`
- `17-jdk-3.22`, `17-jdk-3.23`
- `21-jdk-3.22`, `21-jdk-3.23`
- `25-jdk-3.22`, `25-jdk-3.23`

**For UBI:**
- `8-jdk-ubi9-minimal`, `8-jdk-ubi10-minimal`, `8-jdk-ubi10-rhel`
- `11-jdk-ubi9-minimal`, `11-jdk-ubi10-minimal`, `11-jdk-ubi10-rhel`
- `17-jdk-ubi9-minimal`, `17-jdk-ubi10-minimal`, `17-jdk-ubi10-rhel`
- `21-jdk-ubi9-minimal`, `21-jdk-ubi10-minimal`, `21-jdk-ubi10-rhel`
- `25-jdk-ubi10-minimal`, `25-jdk-ubi10-rhel`

### Target Registry

Images are built and pushed to:
- **Docker Hub**: `acunet/openjdk-runtime`

### Common Build Scenarios

#### Development/Testing
```bash
# Test build Java 17 locally
./build_and_push.sh -v 17 -b

# Test build all LTS versions
./build_and_push.sh -v 8,11,17,21 -b
```

#### CI/CD Pipeline
```bash
# Production build - Java 17 only
./build_and_push.sh -v 17

# Build all LTS versions for release
./build_and_push.sh -v 8,11,17,21
```

#### Full Rebuild
```bash
# Rebuild and push all versions (use with caution)
./build_and_push.sh
```

### Troubleshooting Builds

**Issue: Authentication errors**
```bash
# Verify Docker login to Docker Hub
docker login
# Then enter your Docker Hub username and password
```

**Issue: Build failures**
```bash
# Check Docker is running
docker info

# Clean up build cache
docker builder prune

# Rebuild without cache
docker build --no-cache -t <image> <context>
```

**Issue: Disk space**
```bash
# Check disk space
df -h

# Clean up unused images
docker image prune -a

# Remove all stopped containers
docker container prune
```

---

## 📋 What's Included (v1.0.0+)

✅ **Automatic Memory Management** - Intelligent detection of cgroup v1 and v2  
✅ **Smart Path Resolution** - Finds container's actual cgroup path  
✅ **Soft Limit Support** - Respects memory.high in cgroup v2  
✅ **Configurable Memory Ratios** - Fine-tune heap, metaspace, direct memory  
✅ **Automatic GC Selection** - Optimal garbage collector for container size  
✅ **APM Integration** - Optional APM agent support (Datadog, New Relic, etc.)  
✅ **Diagnostics Support** - Optional GC logging and configuration printing  
✅ **Production Ready** - Tested with Spring Boot, Quarkus, and enterprise apps  
✅ **Zero Configuration** - Works out-of-the-box, no JVM tuning needed  
✅ **Multiple Base Images** - Alpine, UBI Minimal, UBI Standard options  
✅ **Security Updates** - Regular rebuilds with latest security patches  
✅ **Kubernetes Native** - Auto-detects resource limits from K8s specs  
✅ **Cross-Platform** - Works with Docker, Kubernetes, OpenShift, Rancher  

---

## 💼 Real-World Use Cases

### Spring Boot Applications
```yaml
# Spring Boot auto-configured JVM settings
apiVersion: apps/v1
kind: Deployment
metadata:
  name: spring-boot-api
spec:
  template:
    spec:
      containers:
      - image: acunet/openjdk-runtime:17-jdk-ubi10-rhel
        resources:
          limits:
            memory: "512Mi"
          requests:
            memory: "256Mi"
```
✅ Result: Spring Boot gets perfectly tuned 307MB heap, everything else auto-configured

### Microservices
Deploy 100s of tiny microservices with consistent memory tuning across the board.

### Enterprise Applications
Deploy legacy and modern Java applications with RHEL compliance using UBI RHEL variant.

### Kubernetes Multi-tenant Clusters
Each pod gets its own optimal JVM configuration based on its individual resource limits.

### Cloud Cost Optimization
Use Alpine variant with tight memory limits to maximize pods per node.

---

## 🙏 Credits & Support

**Project**: Acunet OpenJDK Runtime  
**Repository**: [acunet/openjdk-runtime](https://github.com/acunet/openjdk-runtime)  
**Docker Hub**: [acunet/openjdk-runtime](https://hub.docker.com/r/acunet/openjdk-runtime)  
**Based on**: [Eclipse Adoptium Containers](https://github.com/adoptium/containers)  
**License**: Apache 2.0  
**Status**: Production Ready ✅

### Support & Contact

For issues, questions, or feature requests related to these images:

- **GitHub Issues:** [acunet/openjdk-runtime/issues](https://github.com/acunet/openjdk-runtime/issues)
- **Discussions:** [acunet/openjdk-runtime/discussions](https://github.com/acunet/openjdk-runtime/discussions)
- **Docker Hub:** [acunet/openjdk-runtime](https://hub.docker.com/r/acunet/openjdk-runtime) (Pull requests and reviews welcome)

### Community

This is an open-source project. Contributions, feedback, and suggestions are welcome!

---

## 📄 License & Attribution

This repository is a fork of [Adoptium Containers](https://github.com/adoptium/containers) and follows the same licensing terms (Apache 2.0).

**Upstream Project:** [Eclipse Adoptium](https://adoptium.net/)

## 📚 Original Documentation

For the original documentation of the upstream project, please refer to the [Adoptium Containers README](https://github.com/adoptium/containers).

---

**Last Updated:** January 2026  
**Version:** 1.0.0 (Production)  
**Maintainer:** Acunet 
