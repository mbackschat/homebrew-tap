class AgentMonitor < Formula
  desc "Trace heavy CPU and memory usage to coding-agent sessions"
  homepage "https://github.com/mbackschat/agent-monitor"
  url "https://github.com/mbackschat/agent-monitor/releases/download/v0.4.0/agent-monitor-0.4.0-macos-arm64.tar.gz"
  sha256 "c85251f6ef2764d9064f14f6fc281ed57edba219da76ee242794ed8189bd1058"
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
