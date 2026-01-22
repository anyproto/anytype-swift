# Approachable Concurrency (Swift 6.2) - Quick Guide

Use this reference when the project has opted into Swift 6.2 approachable concurrency settings.

## Detect the Mode

Check Xcode build settings under "Swift Compiler - Concurrency":
- Swift language version (must be 6.2+)
- Default actor isolation / Main Actor by default
- Strict concurrency checking level (Complete/Targeted/Minimal)

For SwiftPM, inspect Package.swift swiftSettings for the same flags.

## Behavior Changes to Expect

- Async functions stay on the caller's actor by default; they don't hop to a global concurrent executor unless the implementation chooses to
- Main-actor-by-default reduces data race errors for UI-bound code and global state
- Protocol conformances can be isolated (e.g., `extension Foo: @MainActor Bar`)

## How to Apply Fixes in This Mode

- Prefer minimal annotations; let main-actor-by-default do the work when code is UI-bound
- Use isolated conformances instead of forcing `nonisolated` workarounds
- Keep global or shared mutable state on the main actor unless there is a clear performance need to offload it

## When to Opt Out or Offload Work

- Use `@concurrent` on async functions that must run on the concurrent pool
- Make types or members `nonisolated` only when they are truly thread-safe and used off the main actor
- Continue to respect Sendable boundaries when values cross actors or tasks

## Common Pitfalls

- `Task.detached` ignores inherited actor context; avoid it unless you truly need to break isolation
- Main-actor-by-default can hide performance issues if CPU-heavy work stays on the main actor; move that work into `@concurrent` async functions

## Keywords Quick Reference

| Keyword | What it does |
|---------|--------------|
| `async` | Function can pause |
| `await` | Pause here until done |
| `Task { }` | Start async work, inherits context |
| `Task.detached { }` | Start async work, no inherited context |
| `@MainActor` | Runs on main thread |
| `actor` | Type with isolated mutable state |
| `nonisolated` | Opts out of actor isolation |
| `Sendable` | Safe to pass between isolation domains |
| `@concurrent` | Always run on background (Swift 6.2+) |
| `async let` | Start parallel work |
| `TaskGroup` | Dynamic parallel work |

---

**Source**: [Fucking Approachable Swift Concurrency](https://fuckingapproachableswiftconcurrency.com)
