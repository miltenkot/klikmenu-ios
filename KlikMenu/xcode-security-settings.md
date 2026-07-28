# Xcode Security Settings — Decision Document

Project: KlikMenu  
Date: 2026-07-28  
Auditor: Auto (Xcode security settings skill)

## Applied Settings

### Enhanced Security (project level)

| Setting | Value | Targets | Rationale |
|---|---|---|---|
| `ENABLE_ENHANCED_SECURITY` | `YES` | Project Debug + Release (inherits to KlikMenu, KlikMenuClip) | One-switch platform defaults: pointer authentication, stack canaries, fortify source, and related hardening |

Verified via `xcodebuild -showBuildSettings`:
- `ENABLE_ENHANCED_SECURITY = YES`
- `ENABLE_POINTER_AUTHENTICATION = YES` (inherited from Enhanced Security)

### Hardened Process Entitlements (default set only)

Applied to the full app target. Removed from the App Clip after device invocation regressions
(App Clip launch / web-activity delivery is sensitive to extra process entitlements).

| Entitlement | Value | Targets | Rationale |
|---|---|---|---|
| `com.apple.security.hardened-process` | `true` | KlikMenu | Root Enhanced Security process flag |
| `com.apple.security.hardened-process.enhanced-security-version-string` | `"2"` | KlikMenu | Selects v2 runtime protections |
| `com.apple.security.hardened-process.hardened-heap` | `true` | KlikMenu | Heap type-isolation buckets |
| `com.apple.security.hardened-process.dyld-ro` | `true` | KlikMenu | Read-only dyld / reduce runtime mutation |
| `com.apple.security.hardened-process.platform-restrictions-string` | `"2"` | KlikMenu | Dyld + Mach messaging restrictions |

Files:
- `KlikMenu/KlikMenu.entitlements` (full app)
- `KlikMenuClip/KlikMenuClip.entitlements` (parent-application identifier only)

### Not applied (by design)

| Item | Reason |
|---|---|
| `com.apple.security.hardened-process.checked-allocations` / MTE | Extra opt-in; can change allocator behavior and is not required for this pure-Swift menu App Clip |
| Clang warning / analyzer / UBSan build settings (Step 2) | Project is pure Swift; those flags mainly affect C/ObjC/C++ compilation |
| Framework / unit-test targets | Skill scope: app targets only |

## Rejected / Deferred Settings

None from the security catalog were proposed and rejected. Optional MTE / checked-allocations deferred unless product needs stronger memory tagging later.

## Disabled Security Catalog Settings

No security-catalog settings were found explicitly set to `NO` in a way that weakens Enhanced Security.

Non-security `= NO` flags present (left as-is):
- Localization: `STRING_CATALOG_GENERATE_SYMBOLS`, `SWIFT_EMIT_LOC_STRINGS` on SPM package targets
- Packaging: `BUILD_LIBRARY_FOR_DISTRIBUTION` on KlikMenuCore
- Standard Xcode defaults such as `ALWAYS_SEARCH_USER_PATHS = NO` (secure)

## Validation

- `xcodebuild -scheme KlikMenuClip … build` → **BUILD SUCCEEDED**
- Entitlements paths resolve for both app targets
- Enhanced Security / pointer authentication visible in build settings for both schemes

## Optional Follow-ups (not applied)

1. Additional Security Diagnostics (`CLANG_ANALYZER_*`, etc.) — low value for pure Swift; revisit if ObjC/C++ is added.
2. C bounds-safety / `-fbounds-safety` — N/A for pure Swift.
3. Revisit `checked-allocations` / MTE if threat model expands (e.g. processing untrusted binary payloads).
