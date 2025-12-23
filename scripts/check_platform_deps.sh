#!/usr/bin/env bash
set -euo pipefail

# Simple preflight check to catch Windows-only transitive packages (e.g. win32)
# which can break iOS/macOS builds when present in the dependency graph.

echo "Running platform dependency preflight check..."

if ! command -v flutter >/dev/null 2>&1; then
  echo "flutter is not on PATH; install Flutter and re-run this script." >&2
  exit 0
fi

DEPS_OUTPUT=$(flutter pub deps --style=compact 2>/dev/null || true)

if echo "$DEPS_OUTPUT" | grep -q " win32 "; then
  cat <<'WARN'
WARNING: Detected 'win32' in the dependency graph. This package is Windows-only and
can cause iOS/macOS packaging failures (Xcode errors) when it is brought in
transitively.

Suggested actions:
  - Run 'flutter pub outdated' and upgrade packages that pull in 'win32'.
  - If a specific package is the cause, consider filing an issue or pinning a
    compatible version (use 'dependency_overrides' temporarily).
  - As a temporary workaround, pin 'win32' to a compatible version with:
      dependency_overrides:
        win32: ^3.0.1

After fixing dependencies, run 'flutter clean' and rebuild.
WARN
  exit 1
else
  echo "No windows-only packages detected. Good to build for macOS/iOS.";
fi

echo "Preflight check completed."
