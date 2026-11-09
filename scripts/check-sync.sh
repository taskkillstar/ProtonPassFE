#!/usr/bin/env bash
# Helper script to compare upstream release tags with local releases
set -euo pipefail

echo "Fetching upstream tags..."
git fetch upstream --tags --quiet 2>/dev/null || true

LATEST_UPSTREAM_TAG=$(git tag --list --sort=-version:refname | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' | head -n 1)
echo "Latest upstream release tag: ${LATEST_UPSTREAM_TAG}"

if command -v gh &>/dev/null; then
    echo "Checking GitHub Releases in current repository..."
    if gh release view "v${LATEST_UPSTREAM_TAG}" >/dev/null 2>&1; then
        echo "Status: [UP TO DATE] Release v${LATEST_UPSTREAM_TAG} already exists."
    else
        echo "Status: [NEW RELEASE AVAILABLE] v${LATEST_UPSTREAM_TAG} is not released yet!"
    fi
else
    echo "Note: gh CLI not found, cannot query GitHub Releases."
fi
