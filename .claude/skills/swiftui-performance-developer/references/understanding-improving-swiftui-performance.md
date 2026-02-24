# Understanding and Improving SwiftUI Performance - Summary

Context: Apple guidance on diagnosing SwiftUI performance with Instruments.

## Core Concepts

- SwiftUI is declarative; view updates are driven by state, environment, and observable data dependencies
- View bodies must compute quickly to meet frame deadlines; slow or frequent updates lead to hitches
- Instruments is the primary tool to find long-running updates and excessive update frequency

## Instruments Workflow

1. Profile via Product > Profile
2. Choose the SwiftUI template and record
3. Exercise the target interaction
4. Stop recording and inspect the SwiftUI track + Time Profiler

## Diagnose Long View Body Updates

- Expand the SwiftUI track; inspect module-specific subtracks
- Set Inspection Range and correlate with Time Profiler
- Use call tree or flame graph to identify expensive frames
- Repeat the update to gather enough samples for analysis
- Filter to a specific update (Show Calls Made by `MySwiftUIView.body`)

## Diagnose Frequent Updates

- Use Update Groups to find long active groups without long updates
- Set inspection range on the group and analyze update counts
- Use Cause graph ("Show Causes") to see what triggers updates
- Compare causes with expected data flow; prioritize highest-frequency causes

## Remediation Patterns

| Issue | Solution |
|-------|----------|
| Expensive work in body | Move to cached/precomputed paths |
| Broad dependencies | Use `@Observable` macro to scope to properties actually read |
| Layout churn | Isolate state-dependent subtrees from layout readers |
| Closures capturing parent state | Precompute child views |
| Frequent geometry changes | Gate updates by thresholds |

## Verification

- Re-record after changes to confirm reduced update counts and fewer hitches

---

**Source**: Apple Developer Documentation
