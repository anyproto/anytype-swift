# Anytype
Official Anytype client for iOS.

## Building the source
Use XCode to build the project.

[`anytype-heart`](https://github.com/anyproto/anytype-heart) is required for a successful build.

### Use pre-built `anytype-heart`
`make setup-middle` — install the latest `anytype-heart` version.

`make update-middle` — update to the latest `anytype-heart` version

### Build `anytype-heart` locally

Clone [`anytype-heart`](https://github.com/anyproto/anytype-heart) repo.
Check folder structure for use `make` in next steps:
```
- Parent Directory
  | - anytype-heart
  | - anytype-swift
```

Configure go environment by following instructions in [`anytype-heart`](https://github.com/anyproto/anytype-heart) repo.

`make setup-middle-local` — build and setup `anytype-heart` from the local repo.

## Contribution
Thank you for your desire to develop Anytype together. 

Currently, we're not ready to accept PRs, but we will in the nearest future.

Follow us on [Github](https://github.com/anyproto) and join the [Contributors Community](https://github.com/orgs/anyproto/discussions).

---
Made by Any — a Swiss association 🇨🇭

Licensed under [Any Source Available License 1.0](./LICENSE.md).