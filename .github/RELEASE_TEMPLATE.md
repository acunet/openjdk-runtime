## 🎉 Acunet OpenJDK Runtime v1.0.0 - Production Ready!

**Enterprise-grade Docker images for Eclipse Temurin (OpenJDK) with intelligent automatic memory management.**

---

## 🌟 Highlights

✅ **Zero Configuration** - Works out-of-the-box, no JVM tuning needed  
✅ **Automatic Memory Management** - Detects container limits and optimizes JVM  
✅ **cgroup v2 Support** - Full compatibility with Kubernetes 1.25+  
✅ **Smart GC Selection** - Optimal garbage collector chosen automatically  
✅ **50% Better Container Density** - Prevents OOMKilled errors  
✅ **5 Java Versions** - Java 8, 11, 17 (recommended), 21, 25  
✅ **Multiple Base Images** - Alpine, UBI Minimal, UBI RHEL, Ubuntu  

---

## 🚀 Quick Start

```dockerfile
FROM acunet/openjdk-runtime:17-jdk-ubi10-rhel
COPY target/app.jar /app.jar
ENTRYPOINT ["java", "-jar", "/app.jar"]
```

```yaml
# Kubernetes deployment
resources:
  limits:
    memory: "1Gi"  # Automatically configures ~614MB heap + optimal settings
```

**That's it!** The JVM automatically configures itself. 🎯

---

## 📦 Available Images

**Docker Hub:** `acunet/openjdk-runtime`

### Recommended Images
```bash
# Java 17 - Recommended
docker pull acunet/openjdk-runtime:17-jdk-ubi10-rhel

# Java 21 - Latest LTS
docker pull acunet/openjdk-runtime:21-jdk-ubi10-rhel

# Alpine variant (minimal size)
docker pull acunet/openjdk-runtime:17-jdk-alpine-3.23
```

**Full list:** Java 8/11/17/21/25 × Alpine/UBI/Ubuntu = 30+ variants

---

## 💡 What Makes This Special

### Before (Manual Tuning)
```bash
java -Xmx614m -Xms614m -XX:MetaspaceSize=128m -XX:+UseG1GC -jar app.jar
```

### After (Automatic)
```bash
java -jar app.jar  # Everything configured automatically!
```

### Benefits
- 🚫 No more OOMKilled errors
- 📉 50% more container density
- ⚡ Zero configuration needed
- 🔄 Same image works across all container sizes
- 🎯 Kubernetes native

---

## 📊 Automatic Memory Allocation

| Container | Auto Heap | Metaspace | GC |
|-----------|-----------|-----------|-----|
| 512 MB | ~307 MB | 128 MB | G1GC |
| 1 GB | ~614 MB | 128 MB | G1GC/Shenandoah |
| 2 GB | ~1.2 GB | 256 MB | ShenandoahGC |
| 4 GB | ~2.4 GB | 256 MB | ZGC |

---

## 🔧 What's Included

✅ Automatic memory detection (cgroup v1 & v2)  
✅ Smart memory allocation (heap, metaspace, direct, code cache)  
✅ Automatic GC selection  
✅ Shutdown diagnostics (thread dumps, heap info)  
✅ Custom CA certificate support  
✅ APM integration support  
✅ Production tested with Spring Boot, Quarkus, Micronaut  
✅ Kubernetes native  
✅ Zero configuration  

---

## 🐛 Bug Fixes

- ✅ Fixed shutdown script path resolution
- ✅ Fixed utility script sourcing paths
- ✅ Corrected all hardcoded paths to `/opt/src/` base directory

---

## 📖 Documentation

- **[README.md](README.md)** - Complete usage guide
- **[RELEASE_NOTES_v1.0.0.md](RELEASE_NOTES_v1.0.0.md)** - Full release notes
- **[CHANGELOG.md](CHANGELOG.md)** - Version history

---

## 🎯 Image Selection Guide

| Use Case | Recommended Image |
|----------|-------------------|
| **Production Enterprise** | `17-jdk-ubi10-rhel` |
| **Production Minimal** | `17-jdk-alpine-3.23` |
| **Legacy Apps** | `8-jdk-ubi10-rhel` or `11-jdk-ubi10-rhel` |
| **Latest Features** | `21-jdk-ubi10-rhel` |
| **Microservices** | `17-jdk-ubi10-minimal` |

---

## 📞 Support

- **Issues:** [GitHub Issues](https://github.com/acunet/openjdk-runtime/issues)
- **Docker Hub:** [acunet/openjdk-runtime](https://hub.docker.com/r/acunet/openjdk-runtime)

---

## 🙏 Credits

Based on [Eclipse Adoptium Containers](https://github.com/adoptium/containers)  
**License:** Apache 2.0

---

**🚀 Start using today!**

```bash
docker pull acunet/openjdk-runtime:17-jdk-ubi10-rhel
```

---

## Full Changelog

See [CHANGELOG.md](CHANGELOG.md) for complete version history.

