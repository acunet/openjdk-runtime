#!/bin/bash

# ------------------------------------------------------------------------------
# CONFIGURATION
# ------------------------------------------------------------------------------
# Define the target image bases (Registry + Project/Namespace + Image Name)
# Docker Hub repository - replace 'yourusername' with your actual Docker Hub username
TARGET_IMAGES=(
    "docker.io/acunet/openjdk-runtime"
)
# ------------------------------------------------------------------------------

# Ensure we stop on errors
set -e

# Parse command line arguments
BUILD_ONLY=false
HELP=false
VERSIONS=()

while [[ $# -gt 0 ]]; do
    case $1 in
        --build-only|-b)
            BUILD_ONLY=true
            shift
            ;;
        --version|-v)
            IFS=',' read -ra VERSIONS <<< "$2"
            shift 2
            ;;
        --help|-h)
            HELP=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            HELP=true
            shift
            ;;
    esac
done

# Show help if requested
if [ "$HELP" = true ]; then
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Build and optionally push OpenJDK Docker images to Docker Hub."
    echo ""
    echo "Options:"
    echo "  --build-only, -b          Build images only without pushing to registries"
    echo "  --version, -v VERSION     Build specific version(s) only (comma-separated)"
    echo "                            Examples: -v 17  or  -v 8,11,17"
    echo "  --help, -h                Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                        # Build and push all versions"
    echo "  $0 --build-only           # Build all versions, skip push"
    echo "  $0 -v 17                  # Build and push only Java 17"
    echo "  $0 -v 8,11,17 -b          # Build only Java 8, 11, and 17 (no push)"
    echo ""
    echo "Available versions: 8, 11, 17, 21, 25"
    echo ""
    exit 0
fi

if [ "$BUILD_ONLY" = true ]; then
    echo "Starting build process (BUILD ONLY mode - skipping push)..."
else
    echo "Starting build and push process..."
fi

if [ ${#VERSIONS[@]} -gt 0 ]; then
    echo "Building only versions: ${VERSIONS[*]}"
fi

# Find all Dockerfiles in the current directory structure
# Expected structure: ./<version>/<type>/<os_family>/<distro>/Dockerfile
find . -name Dockerfile | sort | while read dockerfile; do
    
    # Get the directory containing the Dockerfile
    dir=$(dirname "$dockerfile")
    
    # Extract metadata from the path
    # Example path: ./8/jdk/ubi/ubi9-minimal/Dockerfile
    version=$(echo "$dir" | cut -d'/' -f2)
    type=$(echo "$dir" | cut -d'/' -f3)
    distro=$(basename "$dir")
    
    # Skip if version filter is specified and this version is not in the list
    if [ ${#VERSIONS[@]} -gt 0 ]; then
        skip=true
        for v in "${VERSIONS[@]}"; do
            if [ "$version" = "$v" ]; then
                skip=false
                break
            fi
        done
        if [ "$skip" = true ]; then
            echo "Skipping version $version (not in filter)"
            continue
        fi
    fi
    
    # Construct the tag
    # Example: 8-jdk-ubi9-minimal
    tag="${version}-${type}-${distro}"
    
    echo "----------------------------------------------------------------"
    echo "Processing Context: $dir"
    echo "Tag: $tag"
    echo "----------------------------------------------------------------"
    
    # Build for each target
    for image_base in "${TARGET_IMAGES[@]}"; do
        full_image_name="${image_base}:${tag}"
        
        echo "Building: $full_image_name"
        # We use "$dir" as the build context so it can find the 'src' and 'ca' folders you copied there
        docker build -t "$full_image_name" "$dir"
        
        if [ "$BUILD_ONLY" = false ]; then
            echo "Pushing to Docker Hub..."
            docker push "$full_image_name"
        else
            echo "Skipping push (build-only mode)"
        fi
        
        echo "Done: $full_image_name"
    done
    echo ""
done

if [ "$BUILD_ONLY" = true ]; then
    echo "All builds completed (images not pushed)."
else
    echo "All builds and pushes completed."
fi