cask "agent-monitor-app" do
  version "0.4.0"
  sha256 "ab1f66756125430632c78e76040d0dadbd2413a81fe584aed490cfa897370dec"

  url "https://github.com/mbackschat/agent-monitor/releases/download/v#{version}/agent-monitor-app-#{version}-macos-arm64.zip"
  name "Agent Monitor"
  desc "Trace CPU and memory use to coding-agent sessions from the menu bar"
  homepage "https://github.com/mbackschat/agent-monitor"

  depends_on arch: :arm64
  depends_on macos: :golden_gate

  app "Agent Monitor.app"
end
