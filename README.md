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

## Maintaining the formula

For a new release, update the versioned archive URL and SHA-256 in [the formula](Formula/agent-monitor.rb). Run `brew audit --strict mbackschat/tap/agent-monitor`, install or upgrade the formula, and run `brew test mbackschat/tap/agent-monitor` before pushing. The tests check the installed version and schema discovery through the public command.

## License

[MIT](LICENSE).
