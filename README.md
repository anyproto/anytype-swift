# Anytype
Official Anytype client for iOS.

## Building the source

### Install current middleware version

`make setup-middle`

### Update to the latest middleware version

`make update-middle`

### Build from the middleware repo

Clone [anytype-heart](https://github.com/anyproto/anytype-heart) repo.
Check folder structure for use `make` in next steps:
```
- Parent Directory
  | - anytype-heart
  | - anytype-swift
```

Configure go environment by following instructions in [anytype-heart](https://github.com/anyproto/anytype-heart) repo.

`make setup-middle-local` to build and setup middleware from the repo.

## Contribution
Thank you for your desire to develop Anytype together. 

Currently, we're not ready to accept PRs, but we will in the nearest future.

Follow us on [Github](https://github.com/anyproto) and join the [Contributors Community](https://github.com/orgs/anyproto/discussions).

---
Made by Any — a Swiss association 🇨🇭

Licensed under [Any Source Available License 1.0](./LICENSE.md).