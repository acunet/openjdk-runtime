#!/bin/bash

GetAvailableMemory () {
  local default_memory="$(awk '/MemTotal/{ print int($2/1024-400) }' /proc/meminfo)"
  local memory=""

  # Search for a memory limit set by Kubernetes
  if [ -n "$KUBERNETES_MEMORY_LIMIT" ]; then
    memory=$((KUBERNETES_MEMORY_LIMIT / (1024 * 1024)))
    echo $memory
    return 0
  fi

  # Helper function to get cgroup path for v2
  get_cgroup_path() {
    # cgroup v2: line format is 0::/path
    awk -F: '$1=="0"{print $3}' /proc/self/cgroup 2>/dev/null || echo ""
  }

  # Function to get memory limit from cgroup v1
  get_cgroup_v1_memory() {
    local cgroup_mem_file="/sys/fs/cgroup/memory/memory.limit_in_bytes"
    if [ -r "$cgroup_mem_file" ]; then
      local cgroup_memory="$(cat ${cgroup_mem_file} 2>/dev/null || true)"
      # v1 unlimited is often very large (~ LONG_MAX), treat as unlimited if > 2^60
      if [ -n "$cgroup_memory" ] && [ "$cgroup_memory" -gt 1152921504606846976 ] 2>/dev/null; then
        return 1
      fi
      if [ -n "$cgroup_memory" ]; then
        cgroup_memory=$((cgroup_memory / (1024 * 1024)))
        if [ ${cgroup_memory} -gt 0 ] && [ ${cgroup_memory} -lt ${default_memory} ]; then
          echo $cgroup_memory
          return 0
        fi
      fi
    fi
    return 1
  }

  # Function to get memory limit from cgroup v2
  get_cgroup_v2_memory() {
    local cg_path base max_file high_file max_val high_val eff_bytes=""
    local USE_MEMORY_HIGH="${USE_MEMORY_HIGH:-1}"
    
    cg_path="$(get_cgroup_path)"
    base="/sys/fs/cgroup${cg_path}"
    [ -d "$base" ] || base="/sys/fs/cgroup"

    max_file="$base/memory.max"
    high_file="$base/memory.high"

    # Read memory.max (hard limit)
    if [ -r "$max_file" ]; then
      max_val="$(cat "$max_file" 2>/dev/null || true)"
      if [ "$max_val" != "max" ] && [ -n "$max_val" ]; then
        eff_bytes="$max_val"
      fi
    else
      return 1
    fi

    # Read memory.high (soft limit) if enabled
    if [ "$USE_MEMORY_HIGH" = "1" ] && [ -r "$high_file" ]; then
      high_val="$(cat "$high_file" 2>/dev/null || true)"
      if [ "$high_val" != "max" ] && [ -n "$high_val" ]; then
        # Use minimum of memory.max and memory.high
        if [ -n "$eff_bytes" ]; then
          if [ "$high_val" -lt "$eff_bytes" ] 2>/dev/null; then
            eff_bytes="$high_val"
          fi
        else
          eff_bytes="$high_val"
        fi
      fi
    fi

    # Convert bytes to MiB
    if [ -n "$eff_bytes" ]; then
      local cgroup_memory=$((eff_bytes / (1024 * 1024)))
      if [ ${cgroup_memory} -gt 0 ] && [ ${cgroup_memory} -lt ${default_memory} ]; then
        echo $cgroup_memory
        return 0
      fi
    fi
    return 1
  }

  # Check if the system is using cgroup v1 or v2
  if [ -f "/sys/fs/cgroup/cgroup.controllers" ]; then
    # cgroup v2
    memory=$(get_cgroup_v2_memory || echo "")
  elif [ -d "/sys/fs/cgroup/memory" ]; then
    # cgroup v1
    memory=$(get_cgroup_v1_memory || echo "")
  fi

  # Fallback to default memory limit
  if [ -z "$memory" ]; then
    memory=$default_memory
  fi

  echo $memory
}

# Improved metaspace calculation
calculate_metaspace() {
  local total_mem=$1
  if [ ${total_mem} -le 256 ]; then
    echo 64
  elif [ ${total_mem} -le 512 ]; then
    echo 96
  elif [ ${total_mem} -le 1024 ]; then
    echo 128
  elif [ ${total_mem} -le 2048 ]; then
    echo 192
  elif [ ${total_mem} -le 4096 ]; then
    echo 256
  else
    echo 384
  fi
}

# Calculate CompressedClassSpaceSize (usually 10-20% of Metaspace)
calculate_compressed_class_space() {
  local metaspace=$1
  echo $((metaspace / 5))  # 20% of metaspace
}

# Setup default Java Options
export TZ="Asia/Jakarta"
export JAVA_TMP_OPTS=${JAVA_TMP_OPTS:-$( if [[ -z ${TMPDIR} ]]; then echo ""; else echo "-Djava.io.tmpdir=$TMPDIR"; fi)}
export GAE_MEMORY_MB=${GAE_MEMORY_MB:-$(GetAvailableMemory)}

# Memory allocation - adjusted to leave ~20% for native/overhead
export HEAP_SIZE_RATIO=${HEAP_SIZE_RATIO:-"55"}  # Reduced from 60% to 55%
export HEAP_SIZE_MB=${HEAP_SIZE_MB:-$(expr ${GAE_MEMORY_MB} \* ${HEAP_SIZE_RATIO} / 100)}

# Metaspace configuration
export METASPACE_SIZE_MB=${METASPACE_SIZE_MB:-$(calculate_metaspace ${GAE_MEMORY_MB})}
export COMPRESSED_CLASS_SPACE_MB=${COMPRESSED_CLASS_SPACE_MB:-$(calculate_compressed_class_space ${METASPACE_SIZE_MB})}

# Native memory limits - adjusted ratios
export DIRECT_MEMORY_RATIO=${DIRECT_MEMORY_RATIO:-"8"}  # Increased for NIO operations
export CODE_CACHE_RATIO=${CODE_CACHE_RATIO:-"3"}
export DIRECT_MEMORY_MB=$(expr ${GAE_MEMORY_MB} \* ${DIRECT_MEMORY_RATIO} / 100)
export CODE_CACHE_MB=$(expr ${GAE_MEMORY_MB} \* ${CODE_CACHE_RATIO} / 100)

# Thread stack size (important for containers)
export THREAD_STACK_SIZE=${THREAD_STACK_SIZE:-"512"}  # KB per thread

# JVM Heap Options - FIXED: consistent case (lowercase 'm')
export JAVA_HEAP_OPTS=${JAVA_HEAP_OPTS:-"-Xms${HEAP_SIZE_MB}m -Xmx${HEAP_SIZE_MB}m"}

# Metaspace Options - with CompressedClassSpaceSize
export JAVA_METASPACE_OPTS=${JAVA_METASPACE_OPTS:-"-XX:MetaspaceSize=${METASPACE_SIZE_MB}m -XX:MaxMetaspaceSize=${METASPACE_SIZE_MB}m -XX:CompressedClassSpaceSize=${COMPRESSED_CLASS_SPACE_MB}m"}

# Native Memory Options
export JAVA_NATIVE_OPTS=${JAVA_NATIVE_OPTS:-"-XX:MaxDirectMemorySize=${DIRECT_MEMORY_MB}m -XX:ReservedCodeCacheSize=${CODE_CACHE_MB}m -Xss${THREAD_STACK_SIZE}k"}

# GC Selection with optimized settings
if [ -z "${JAVA_GC_OPTS}" ]; then
  if [ "${GAE_MEMORY_MB}" -lt 512 ]; then
    # Very small containers: Serial GC
    export JAVA_GC_OPTS="-XX:+UseSerialGC -XX:+AlwaysPreTouch -XX:+DisableExplicitGC"
  elif [ "${GAE_MEMORY_MB}" -lt 1024 ]; then
    # Small containers: G1GC with small regions
    export JAVA_GC_OPTS="-XX:+UseG1GC -XX:MaxGCPauseMillis=200 -XX:+AlwaysPreTouch -XX:+DisableExplicitGC -XX:G1HeapRegionSize=1m"
  elif [ "${GAE_MEMORY_MB}" -lt 4096 ]; then
    # Medium containers: Shenandoah or G1GC
    if java -XX:+UseShenandoahGC -version >/dev/null 2>&1; then
      export JAVA_GC_OPTS="-XX:+UseShenandoahGC -XX:+AlwaysPreTouch -XX:+DisableExplicitGC"
    else
      export JAVA_GC_OPTS="-XX:+UseG1GC -XX:MaxGCPauseMillis=200 -XX:+AlwaysPreTouch -XX:+DisableExplicitGC"
    fi
  else
    # Large containers: ZGC or Shenandoah
    if java -XX:+UseZGC -version >/dev/null 2>&1; then
      export JAVA_GC_OPTS="-XX:+UseZGC -XX:+AlwaysPreTouch -XX:+DisableExplicitGC"
    else
      export JAVA_GC_OPTS="-XX:+UseShenandoahGC -XX:+AlwaysPreTouch -XX:+DisableExplicitGC"
    fi
  fi
fi

# APM Agent - made optional, supports cloud secret token
if [ -f "/opt/elastic-apm-agent.jar" ] && [ "${ENABLE_APM:-false}" = "true" ]; then
  # Extract workload name from HOSTNAME by removing ReplicaSet hash and pod suffix
  # Example: argo-events-controller-manager-558d6bc899-kfscb -> argo-events-controller-manager
  # Works for Deployments, ReplicaSets, StatefulSets
  if [ -z "${APM_SERVICE_NAME:-}" ]; then
    # Remove last two hyphen-separated segments (hash + pod-suffix)
    APM_SERVICE_NAME_DEFAULT=$(echo "${HOSTNAME}" | sed 's/-[^-]*-[^-]*$//')
    # Fallback to full hostname if sed fails or result is empty
    [ -z "${APM_SERVICE_NAME_DEFAULT}" ] && APM_SERVICE_NAME_DEFAULT="${HOSTNAME}"
  else
    APM_SERVICE_NAME_DEFAULT="${APM_SERVICE_NAME}"
  fi

  # Base APM options
  APM_OPTS="-Delastic.apm.server_url=${APM_SERVER_URL:-http://apm-server.elastic.svc:8200} -Delastic.apm.service_name=${APM_SERVICE_NAME_DEFAULT} -Delastic.apm.environment=${APM_ENVIRONMENT:-production}"

  # Optional secret token for Elastic Cloud
  if [ -n "${APM_SECRET_TOKEN:-}" ]; then
    APM_OPTS="${APM_OPTS} -Delastic.apm.secret_token=${APM_SECRET_TOKEN}"
  fi

  export JAVA_APM="-javaagent:/opt/elastic-apm-agent.jar ${APM_OPTS}"
else
  export JAVA_APM=""
fi

# General JVM Options - improved
export JAVA_GENERAL_OPTS=${JAVA_GENERAL_OPTS:-"-showversion -XshowSettings:vm -XX:+UseContainerSupport -XX:+UnlockExperimentalVMOptions -Duser.timezone=Asia/Jakarta -Djava.security.egd=file:/dev/./urandom -XX:+ExitOnOutOfMemoryError -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/tmp/heapdump.hprof"}

# Diagnostic options (disable in production for performance)
if [ "${JAVA_DIAGNOSTICS:-false}" = "true" ]; then
  export JAVA_DIAG_OPTS="-XX:+PrintFlagsFinal -XX:+PrintGCDetails -XX:+PrintGCDateStamps -Xlog:gc*:file=/tmp/gc.log:time,uptime,level,tags"
else
  export JAVA_DIAG_OPTS=""
fi

# Final JAVA_OPTS assembly
export JAVA_OPTS=${JAVA_OPTS:-${JAVA_APM} ${JAVA_GENERAL_OPTS} ${JAVA_TMP_OPTS} ${DBG_AGENT} ${PROFILER_AGENT} ${JAVA_HEAP_OPTS} ${JAVA_METASPACE_OPTS} ${JAVA_GC_OPTS} ${JAVA_NATIVE_OPTS} ${JAVA_DIAG_OPTS} ${JAVA_USER_OPTS}}

# Print configuration for debugging
if [ "${JAVA_PRINT_CONFIG:-false}" = "true" ]; then
  echo "========================================="
  echo "Java Memory Configuration"
  echo "========================================="
  echo "Total Container Memory: ${GAE_MEMORY_MB} MB"
  echo "Heap Memory (-Xmx/-Xms): ${HEAP_SIZE_MB} MB (${HEAP_SIZE_RATIO}%)"
  echo "Metaspace: ${METASPACE_SIZE_MB} MB"
  echo "CompressedClassSpace: ${COMPRESSED_CLASS_SPACE_MB} MB"
  echo "Direct Memory: ${DIRECT_MEMORY_MB} MB (${DIRECT_MEMORY_RATIO}%)"
  echo "Code Cache: ${CODE_CACHE_MB} MB (${CODE_CACHE_RATIO}%)"
  echo "Thread Stack Size: ${THREAD_STACK_SIZE} KB"
  echo "========================================="
  echo "Total Allocated: $((HEAP_SIZE_MB + METASPACE_SIZE_MB + COMPRESSED_CLASS_SPACE_MB + DIRECT_MEMORY_MB + CODE_CACHE_MB)) MB"
  echo "Reserved for Native/Overhead: $((GAE_MEMORY_MB - HEAP_SIZE_MB - METASPACE_SIZE_MB - COMPRESSED_CLASS_SPACE_MB - DIRECT_MEMORY_MB - CODE_CACHE_MB)) MB"
  echo "========================================="
  echo "JAVA_OPTS=${JAVA_OPTS}"
  echo "========================================="
fi