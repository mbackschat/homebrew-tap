class Dmtool < Formula
  desc "Inspect, validate, and edit A12 DocumentModels"
  homepage "https://github.com/mbackschat/a12-dmtool-releases"
  license "EUPL-1.2"

  on_macos do
    depends_on arch: :arm64
    depends_on macos: :golden_gate

    on_arm do
      url "https://github.com/mbackschat/a12-dmtool-releases/releases/download/v0.14.0/dmtool-macos-arm64", using: :nounzip
      sha256 "ad22374a44e8ba8a9191e04eb17b3f814c0123af628710a7878b0c32846e38b6"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/mbackschat/a12-dmtool-releases/releases/download/v0.14.0/dmtool-linux-x64", using: :nounzip
      sha256 "f89972bffafdd7ca7b1a0adf855a0126ddc9bb6f8c07eefdd82d0efd7c76c265"
    end
    on_arm do
      url "https://github.com/mbackschat/a12-dmtool-releases/releases/download/v0.14.0/dmtool-linux-arm64", using: :nounzip
      sha256 "431c8b0f01c57c338c04fe209816addff1135b9339e4f440d1130420770b839e"
    end
  end

  resource "notices" do
    url "https://github.com/mbackschat/a12-dmtool-releases/archive/585c33f0eccbe2c5c7b0500cf7bfc4b87ad77f7e.tar.gz"
    sha256 "550a21a17fe4b5efeb47844a6e2b1cedd04448d27504dca654b60f5c8a0602ed"
  end

  def install
    binary = Dir["dmtool-*"]
    odie "Expected exactly one release binary" if binary.length != 1
    bin.install binary.first => "dmtool"
    chmod 0755, bin/"dmtool"
    resource("notices").stage do
      pkgshare.install "LICENSE", "KERNEL-LICENSE", "NOTICE", "THIRD_PARTY_NOTICES", "licenses"
    end
  end

  test do
    output = with_env(PATH: "", JAVA_HOME: "/nonexistent") { shell_output("#{bin}/dmtool --version") }
    assert_equal "a12-dmkits #{version}", output.lines.first.strip
    manifest = JSON.parse(shell_output("#{bin}/dmtool manifest"))
    assert_equal version.to_s, manifest.fetch("version").fetch("rulekit")
    resource("notices").stage do
      notices = %w[LICENSE KERNEL-LICENSE NOTICE THIRD_PARTY_NOTICES]
      notices += Dir["licenses/**/*"].select { |f| File.file?(f) }
      assert_includes notices, "licenses/EUPL-1.2.txt"
      notices.each do |notice|
        assert_equal File.binread(notice), (pkgshare/notice).binread
      end
    end
  end
end
