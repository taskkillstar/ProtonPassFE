#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
REPO_ROOT=$(cd "${SCRIPT_DIR}/.." && pwd)
PATCHES_DIR="${REPO_ROOT}/patches"

echo "=========================================================="
echo "  Proton Pass Custom Build: Applying Modifications"
echo "=========================================================="

# 1. Apply patches from patches/ directory if any exist
if [ -d "$PATCHES_DIR" ]; then
    shopt -s nullglob
    PATCH_FILES=("$PATCHES_DIR"/*.patch "$PATCHES_DIR"/*.diff)
    shopt -u nullglob

    if [ ${#PATCH_FILES[@]} -eq 0 ]; then
        echo "[INFO] No .patch or .diff files found in ${PATCHES_DIR}."
    else
        echo "[INFO] Found ${#PATCH_FILES[@]} patch file(s) in ${PATCHES_DIR}."
        for patch in "${PATCH_FILES[@]}"; do
            patch_name=$(basename "$patch")
            echo "--> Applying patch: ${patch_name}"
            
            # First dry-run check
            if git apply --check "$patch" 2>/dev/null; then
                git apply "$patch"
                echo "    ✓ Successfully applied: ${patch_name}"
            else
                echo "    Standard apply failed. Attempting 3-way merge for ${patch_name}..."
                if git apply --3way "$patch"; then
                    echo "    ✓ Successfully applied with 3-way merge: ${patch_name}"
                else
                    echo "[ERROR] Failed to apply patch: ${patch_name}"
                    echo "[ERROR] Upstream code may have changed significantly around modified lines."
                    exit 1
                fi
            fi
        done
    fi
fi

# 2. Run custom hook script if provided (for programmatic edits)
CUSTOM_HOOK="${SCRIPT_DIR}/custom-hooks.sh"
if [ -f "$CUSTOM_HOOK" ]; then
    echo "--> Running custom hook script: ${CUSTOM_HOOK}"
    bash "$CUSTOM_HOOK"
    echo "    ✓ Custom hooks completed successfully"
fi

echo "=========================================================="
echo "  All modifications applied successfully!"
echo "=========================================================="
