# Martin Backschat's Homebrew tap

## Agent Monitor

[Agent Monitor](https://github.com/mbackschat/agent-monitor) shows which coding agents, sessions and processes consume CPU and memory, with their working directories. Requires Apple Silicon and macOS 27 or later; release downloads need no Xcode.

| Interface | Install | Start |
| --- | --- | --- |
| CLI and terminal dashboard | `brew install mbackschat/tap/agent-monitor` | `agent-monitor --tui` |
| Mac menu bar app | `brew install --cask mbackschat/tap/agent-monitor-app` | Open **Agent Monitor** from Applications. |

Install either or both. The formula installs the CLI and its schema bundle; the cask installs only the Developer ID-signed, notarized app. Both verify release checksums. The CLI archive remains ad-hoc signed.

Update installed packages with `brew update`, then `brew upgrade agent-monitor` and/or `brew upgrade --cask agent-monitor-app`. Quit the Mac app before upgrading it. See the [installation guide](https://github.com/mbackschat/agent-monitor/blob/main/docs/installation.md) for downloads and source builds.

## dmtool

[dmtool](https://github.com/mbackschat/a12-dmtool-releases) inspects, validates, and edits A12 DocumentModels. Requires Apple Silicon with **macOS 27 or later**, or Linux x64/ARM64 with the release binary's runtime requirements.

```sh
brew install mbackschat/tap/dmtool
dmtool --version
```

Update with `brew update` and `brew upgrade dmtool`. No JVM is required. The formula verifies the binary and notice archive checksums and installs the EUPL-1.2 bundle notices under `$(brew --prefix dmtool)/share/dmtool`.

Maintainers generate [the formula](Formula/dmtool.rb) with `scripts/run-typescript.sh "dmtool packages" scripts/typescript/dmtool-packages.ts VERSION build/packages` in the dmtool source repository after publication. Run `brew audit --strict mbackschat/tap/dmtool`, install/reinstall, and `brew test mbackschat/tap/dmtool` before publishing an update.

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

For an Agent Monitor release, run `python3 scripts/update-homebrew.py VERSION` from its source repository after publishing the GitHub release. The helper updates [the CLI formula](Formula/agent-monitor.rb) and [the Mac cask](Casks/agent-monitor-app.rb), audits both recipes, tests the installed CLI, and verifies the cask download’s version, signature, notarization ticket and Gatekeeper acceptance before pushing. Follow the [release guide](https://github.com/mbackschat/agent-monitor/blob/main/docs/releasing.md) for preparation and recovery.

For a new locmetry release, render [its formula](Formula/locmetry.rb) with `packaging/homebrew/render-formula.sh VERSION` from the locmetry repository, which fills the URLs and checksums from the release's `SHA256SUMS`. Run `brew style`, install or upgrade, and run `brew test mbackschat/tap/locmetry` before pushing; the test measures a synthetic project with an empty `PATH`.

## License

[MIT](LICENSE).
