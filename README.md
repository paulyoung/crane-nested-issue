# Crane Wasm issue

Demonstrates the issue described in https://github.com/ipetkov/crane/issues/209#issuecomment-1372960937

The issue is that files in the root directory can't be accessed by tests when using Nix.

## Usage

### Cargo

`cd nested` and `cargo test -- --nocapture` within the dev shell.

### Nix

`nix build` or `nix build .#foo` from the root.
