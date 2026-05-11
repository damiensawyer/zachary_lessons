#!/bin/bash
# =============================================================================
# Rust Course Build Script
# Compiles and tests all lessons in the Rust course
# =============================================================================

set -e  # Exit on any error

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "🦀 Building Rust Course at: $SCRIPT_DIR"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Counters
SUCCESS=0
FAILED=0
TOTAL=0

# Function to print status
print_status() {
    local lesson="$1"
    local status="$2"
    
    if [ "$status" == "success" ]; then
        echo -e "${GREEN}✓${NC} $lesson"
        ((SUCCESS++))
    else
        echo -e "${RED}✗${NC} $lesson FAILED"
        ((FAILED++))
    fi
    ((TOTAL++))
}

# Function to check if Rust is installed
check_rust() {
    if ! command -v cargo &> /dev/null; then
        echo ""
        echo -e "${RED}ERROR: Cargo (Rust) is not installed!${NC}"
        echo "Please install Rust first:"
        echo "  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"
        exit 1
    fi
    
    echo "✓ Rust toolchain found:"
    rustc --version
    cargo --version
    echo ""
}

# Function to check for Cargo.toml in a lesson directory
check_cargo_toml() {
    local dir="$1"
    
    if [ ! -f "$dir/Cargo.toml" ]; then
        # Try to create it if missing
        mkdir -p "$dir/src"
        
        cat > "$dir/Cargo.toml" << 'EOF'
[package]
name = "lesson_placeholder"
version = "0.1.0"
edition = "2021"

[dependencies]
EOF
        
        echo "  Created Cargo.toml for $dir"
    fi
}

# Function to compile a single lesson
compile_lesson() {
    local lesson_dir="$1"
    local lesson_name=$(basename "$lesson_dir")
    
    # Clean previous build artifacts
    rm -rf "$lesson_dir/target" 2>/dev/null || true
    
    echo "  Building $lesson_name..."
    
    if cargo build --manifest-path "$lesson_dir/Cargo.toml" 2>&1; then
        print_status "$lesson_name" "success"
        return 0
    else
        print_status "$lesson_name" "failed"
        return 1
    fi
}

# Function to run tests for a lesson (if main.rs exists)
test_lesson() {
    local lesson_dir="$1"
    
    if [ -f "$lesson_dir/src/main.rs" ]; then
        echo "  Running tests for $lesson_name..."
        
        if cargo test --manifest-path "$lesson_dir/Cargo.toml" --quiet 2>&1; then
            print_status "${lesson_name} (tests)" "success"
            return 0
        else
            print_status "${lesson_name} (tests)" "failed"
            return 1
        fi
    fi
    
    return 0  # No tests to run
}

# Function to format lesson name for display
format_lesson_name() {
    echo "$1 | $(basename $2)"
}

echo "=========================================="
echo "       RUST COURSE BUILD SCRIPT"
echo "=========================================="
echo ""

# Check Rust installation
check_rust
echo ""

# Get all lesson directories with src folder
LESSON_DIRS=()
for dir in "$SCRIPT_DIR"/lesson[0-9]*; do
    if [ -d "$dir/src" ]; then
        LESSON_DIRS+=("$dir")
    fi
done

if [ ${#LESSON_DIRS[@]} -eq 0 ]; then
    echo -e "${RED}ERROR: No lesson directories found!${NC}"
    exit 1
fi

echo "Found ${#LESSON_DIRS[@]} lessons to build"
echo ""

# Build all lessons
echo "=========================================="
echo "         BUILDING ALL LESSONS"
echo "=========================================="
echo ""

for dir in "${LESSON_DIRS[@]}"; do
    lesson_name=$(basename "$dir")
    
    # Check for Cargo.toml and create if missing
    check_cargo_toml "$dir"
    
    # Compile the lesson
    compile_lesson "$dir" || true
    
    echo ""
done

# Run summary
echo "=========================================="
echo "           BUILD SUMMARY"
echo "=========================================="
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}✓ All ${TOTAL} lessons compiled successfully!${NC}"
else
    echo -e "${YELLOW}⚠ ${SUCCESS}/${TOTAL} lessons compiled. ${FAILED} failed.${NC}"
fi

echo ""
echo "=========================================="
echo "         BUILD COMPLETE"
echo "=========================================="
echo ""

# Exit with appropriate code
if [ $FAILED -gt 0 ]; then
    exit 1
else
    exit 0
fi
