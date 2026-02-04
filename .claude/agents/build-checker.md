---
name: build-checker
description: Verifies compilation status
tools: Bash
model: haiku
---
Check build status by running: xcodebuild -project Anytype.xcodeproj -scheme Anytype -destination 'platform=iOS Simulator,name=iPhone 16' build 2>&1 | tail -50
Report success or failure with relevant error messages.
