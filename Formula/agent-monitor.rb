class AgentMonitor < Formula
  desc "Trace heavy CPU and memory usage to coding-agent sessions"
  homepage "https://github.com/mbackschat/agent-monitor"
  url "https://github.com/mbackschat/agent-monitor/releases/download/v0.4.1/agent-monitor-0.4.1-macos-arm64.tar.gz"
  sha256 "832f5fb1a2b9cbd6ead467ee24c52de9c96fbff93dbebd2ace657ca364a9f9a3"
  license "MIT"

  depends_on arch: :arm64
  depends_on :macos

  on_macos do
    depends_on macos: :golden_gate
  end

  def install
    libexec.install "agent-monitor", "AgentMonitor_AgentMonitorPresentation.bundle"
    bin.write_exec_script libexec/"agent-monitor"
    (pkgshare/"licenses").install Dir["licenses/*"]
  end

  test do
    assert_equal version.to_s, shell_output("#{bin}/agent-monitor --version").strip
    schema = JSON.parse(shell_output("#{bin}/agent-monitor --json-schema"))
    assert_equal "https://json-schema.org/draft/2020-12/schema", schema.fetch("$schema")
  end
end
