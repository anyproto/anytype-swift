# Optimizing SwiftUI Performance with Instruments - Summary

Context: How to diagnose SwiftUI-specific bottlenecks using Instruments.

## Key Takeaways

- Profile SwiftUI issues with the SwiftUI template (SwiftUI instrument + Time Profiler + Hangs/Hitches)
- Long view body updates are a common bottleneck; use "Long View Body Updates" to identify slow bodies
- Set inspection range on a long update and correlate with Time Profiler to find expensive frames
- Keep work out of `body`: move formatting, sorting, image decoding to cached paths
- Use Cause & Effect Graph to diagnose *why* updates occur
- Avoid broad dependencies that trigger many updates
- Prefer granular view models and scoped state
- Environment values update checks still cost time; avoid fast-changing values in environment
- Profile early and often during feature development

## Suggested Workflow

1. **Record** a trace in Release mode using the SwiftUI template
2. **Inspect** "Long View Body Updates" and "Other Long Updates"
3. **Zoom** into a long update, then inspect Time Profiler for hot frames
4. **Fix** slow body work by moving heavy logic into precomputed/cache paths
5. **Use Cause & Effect Graph** to identify unintended update fan-out
6. **Re-record** and compare update counts and hitch frequency

## Example Patterns

- Caching formatted distance strings in a location manager instead of computing in `body`
- Replacing a dependency on a global favorites array with per-item view models to reduce update fan-out

## SwiftUI Timeline Lanes

| Lane | Purpose |
|------|---------|
| Update Groups | Overview of time SwiftUI spends calculating updates |
| Long View Body Updates | Orange >500us, Red >1000us |
| Long Platform View Updates | AppKit/UIKit hosting in SwiftUI |
| Other Long Updates | Geometry/text/layout and other SwiftUI work |
| Hitches | Frame misses where UI wasn't ready in time |

---

**Source**: Apple Developer Documentation
