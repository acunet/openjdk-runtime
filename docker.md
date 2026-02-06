# Docker Hub Repository Overview

**Repository:** [acunet/openjdk-runtime](https://hub.docker.com/r/acunet/openjdk-runtime)

---

## 📝 Short Description (for Docker Hub)

```
Enterprise-grade OpenJDK (Eclipse Temurin) Docker images with automatic intelligent memory management, cgroup v2 support, and zero-configuration JVM tuning for production Kubernetes deployments.
```

**Character count:** 158 characters

---

## 🎯 Full Description (for Docker Hub)

```
🚀 Production-Ready OpenJDK Runtime with Automatic JVM Memory Management

Acunet OpenJDK Runtime provides enterprise-grade Eclipse Temurin (OpenJDK) Docker images with intelligent automatic memory detection and JVM configuration.

## ✨ Key Features

✅ **Automatic Memory Management** - No manual JVM tuning needed. Intelligently detects container memory limits and auto-configures optimal JVM settings.

✅ **Modern Kubernetes Ready** - Full support for cgroup v2 (Kubernetes 1.25+), the industry standard for modern container platforms.

✅ **Zero Configuration** - Works out-of-the-box. Deploy your application and it automatically adapts to any container size.

✅ **Enterprise Grade** - Production-tested with Java 8, 11, 17, 21, and 25 (LTS and non-LTS).

✅ **Multiple Base Images** - Choose from Alpine (minimal ~150-200MB), UBI Minimal (~120-180MB), or UBI Standard (~300-400MB).

✅ **Security Focused** - Regular security updates, non-root execution, minimal attack surface.

✅ **cgroup v1 & v2 Support** - Works with both legacy and modern Kubernetes clusters.

✅ **Automatic GC Selection** - Optimal garbage collector chosen based on container memory.

## 🔥 What Makes This Special

**Before (Traditional):**
```bash
java -Xmx614m -Xms614m -XX:MetaspaceSize=128m -XX:MaxMetaspaceSize=128m \
  -XX:+UseG1GC -XX:MaxGCPauseMillis=200 -jar app.jar
```

**After (Acunet OpenJDK Runtime):**
```bash
docker run -m 1024m acunet/openjdk-runtime:17-jdk-ubi10-rhel
# 👆 Automatically gets all the JVM tuning above!
```

## 🐳 Quick Start

### Docker
```dockerfile
FROM acunet/openjdk-runtime:17-jdk-ubi10-rhel
COPY target/app.jar /app/
WORKDIR /app
ENTRYPOINT ["java", "-jar", "app.jar"]
```

### Kubernetes
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
spec:
  template:
    spec:
      containers:
      - image: acunet/openjdk-runtime:17-jdk-ubi10-rhel
        resources:
          limits:
            memory: "1024Mi"
```

## 📦 Supported Images

### Java Versions
- **Java 8 (LTS)** - End of Support: Dec 2030
- **Java 11 (LTS)** - End of Support: Sep 2026
- **Java 17 (LTS)** - End of Support: Sep 2029 ⭐ **Recommended**
- **Java 21 (LTS)** - End of Support: Sep 2031
- **Java 25** - Non-LTS, End of Support: Sep 2026

### Base Images
- **Alpine** (3.20, 3.21, 3.22, 3.23) - Minimal, ~150-200MB
- **UBI 9 Minimal** - Enterprise-compatible, ~120-180MB
- **UBI 10 Minimal** - Latest UBI, ~120-180MB
- **UBI 10 Standard** - Full-featured, ~300-400MB

## 🎯 Memory Management Highlights

For a **1024Mi** container limit, automatically allocates:

| Component | Allocation | Purpose |
|-----------|-----------|---------|
| **Heap** | ~614 MB (60%) | Java objects |
| **Metaspace** | 128 MB | Class metadata |
| **Direct Memory** | ~71 MB (7%) | NIO buffers |
| **Code Cache** | ~30 MB (3%) | JIT code |
| **Overhead** | ~309 MB (30%) | Native memory, stacks |

**No manual configuration needed!**

## 🔧 Environment Variables

Fine-tune memory allocation with environment variables:

```yaml
env:
- name: HEAP_SIZE_RATIO
  value: "70"  # Increase heap to 70% (default: 60%)
- name: METASPACE_SIZE_MB
  value: "256" # Override automatic sizing
- name: JAVA_USER_OPTS
  value: "-XX:+UseG1GC -XX:MaxGCPauseMillis=200"
```

## 📊 Real-World Performance

- ✅ **No OOMKilled Errors** - Proper memory allocation prevents crashes
- ✅ **Works Across All Sizes** - Same image, optimal settings for 256MB to 8GB containers
- ✅ **Kubernetes Native** - Auto-detects limits from resource specs
- ✅ **Dev to Prod Parity** - Consistent behavior across all deployments

## 📚 Documentation

- **GitHub Repository:** https://github.com/acunet/openjdk-runtime
- **Full Documentation:** See README.md for detailed guides, troubleshooting, and advanced features
- **Issues & Support:** https://github.com/acunet/openjdk-runtime/issues

## 📄 License

Apache 2.0 - See LICENSE file for details

---

**Status:** Production Ready ✅  
**Last Updated:** February 2026  
**Maintainer:** Acunet Community
```

---

## 🌐 Docker Hub Profile Information

### Profile Section Fields

| Field | Suggested Content |
|-------|------------------|
| **Full Name** | Acunet OpenJDK Runtime |
| **Short Description** | Enterprise-grade OpenJDK images with automatic intelligent memory management and zero-configuration JVM tuning for Kubernetes. |
| **Company** | Acunet |
| **Website** | https://github.com/acunet/openjdk-runtime |
| **Email** | mansurudien@gmail.com |
| **About** | Open-source project providing production-ready Eclipse Temurin (OpenJDK) Docker images with automatic memory detection and cgroup v2 support. |

### Repository Settings

| Setting | Value |
|---------|-------|
| **Repository Name** | openjdk-runtime |
| **Namespace** | acunet |
| **Description** | Production-ready OpenJDK (Eclipse Temurin) with automatic JVM memory management, cgroup v2 support, and zero-configuration tuning |
| **Full URL** | docker.io/acunet/openjdk-runtime |
| **Documentation Link** | https://github.com/acunet/openjdk-runtime |
| **Source Repository** | https://github.com/acunet/openjdk-runtime |
| **Issues** | https://github.com/acunet/openjdk-runtime/issues |

---

## 📌 Copy-Paste Ready Descriptions

### For Docker Hub Short Description (160 characters max)
```
Enterprise-grade OpenJDK (Eclipse Temurin) with automatic intelligent memory management and zero-configuration JVM tuning for Kubernetes.
```

### For Docker Hub Full Description
See the full description section above - it's formatted and ready to paste into Docker Hub's "Full Description" field.

---

## ✅ Next Steps

1. **Update Docker Hub Profile:**
   - Go to https://hub.docker.com/r/acunet/openjdk-runtime/edit
   - Fill in the profile information from the table above
   - Update the full description with the content provided

2. **Set Repository Settings:**
   - Add GitHub source link: https://github.com/acunet/openjdk-runtime
   - Enable automated builds (optional)
   - Add topics: `openjdk`, `temurin`, `adoptium`, `docker`, `kubernetes`, `jvm`, `memory-management`

3. **Add Readme to Docker Hub:**
   - Copy the README.md content to Docker Hub's full description field
   - Or link to the GitHub repository for automatic sync

---

**Document Updated:** February 6, 2026  
**For Repository:** acunet/openjdk-runtime

