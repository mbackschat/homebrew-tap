# Martin Backschat's Homebrew tap

## Agent Monitor

[Agent Monitor](https://github.com/mbackschat/agent-monitor) traces heavy CPU and memory usage to Codex CLI and Claude Code sessions on macOS.

Requires Apple Silicon and macOS 27 or later. Install the prebuilt release without Xcode:

```sh
brew install mbackschat/tap/agent-monitor
agent-monitor --tui --group session
```

Update with:

```sh
brew update
brew upgrade agent-monitor
```

The formula verifies the release archive's SHA-256 checksum and installs the executable with its schema resource bundle. Releases are ad-hoc signed, not notarized. See the [installation guide](https://github.com/mbackschat/agent-monitor/blob/main/docs/installation.md) for alternatives.

## locmetry

[locmetry](https://github.com/mbackschat/locmetry) measures lines of code with embedded Tokei and classifies every file as production, test, or other by reviewable project rules.

Requires macOS on Apple Silicon or Linux on x86_64 or aarch64. Install the prebuilt release without a Rust toolchain:

```sh
brew install mbackschat/tap/locmetry
locmetry --format markdown
```

Update with:

```sh
brew update
brew upgrade locmetry
```

The formula verifies the release archive's SHA-256 checksum. `brew install --HEAD mbackschat/tap/locmetry` builds the main branch from source with Rust as a build-only dependency.

## Maintaining the formula

For a new release, update the versioned archive URL and SHA-256 in [the formula](Formula/agent-monitor.rb). Run `brew audit --strict mbackschat/tap/agent-monitor`, install or upgrade the formula, and run `brew test mbackschat/tap/agent-monitor` before pushing. The tests check the installed version and schema discovery through the public command.

For a new locmetry release, render [its formula](Formula/locmetry.rb) with `packaging/homebrew/render-formula.sh VERSION` from the locmetry repository, which fills the URLs and checksums from the release's `SHA256SUMS`. Run `brew style`, install or upgrade, and run `brew test mbackschat/tap/locmetry` before pushing; the test measures a synthetic project with an empty `PATH`.

## License

[MIT](LICENSE).
