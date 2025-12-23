## Preflight & platform build notes ✅

If you plan to build for iOS/macOS, run the provided preflight check which will
detect Windows-only transitive packages that could break packaging (for
example, `win32`).

Run:

```bash
./scripts/check_platform_deps.sh
```

If the script reports `win32` in the dependency graph, try:
- Run `flutter pub outdated` and upgrade the offending package(s)
- Or add a temporary `dependency_overrides` entry for `win32` to pin a
  compatible version and run `flutter clean` before re-building.

Also consider:
- Keep Flutter and plugins up-to-date (run `flutter upgrade` and `flutter pub upgrade`).
- Use this script before CI runs to fail fast and produce actionable guidance.
