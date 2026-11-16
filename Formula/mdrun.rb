class Mdrun < Formula
  desc "Create, run, and verify executable Markdown documents"
  homepage "https://github.com/mbackschat/mdrun"
  license "MIT"

  head do
    url "https://github.com/mbackschat/mdrun.git", branch: "main"
    depends_on "rust" => :build
  end

  on_macos do
    on_arm do
      url "https://github.com/mbackschat/mdrun/releases/download/v0.1.0/mdrun-v0.1.0-aarch64-apple-darwin.tar.gz"
      sha256 "e3228ae4e74462bfc8df7a86b690b8a96c9347595f989de033073a0394ea6637"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/mbackschat/mdrun/releases/download/v0.1.0/mdrun-v0.1.0-x86_64-unknown-linux-musl.tar.gz"
      sha256 "be99271f4f97ddbea3623b1ea456cf0a00f198e34d1c2fae0e11f2fa4b8e0974"
    end
    on_arm do
      url "https://github.com/mbackschat/mdrun/releases/download/v0.1.0/mdrun-v0.1.0-aarch64-unknown-linux-musl.tar.gz"
      sha256 "299645cdc44cb2f08362e530d302823328b14032a310a0ca84359705b00ffb48"
    end
  end

  def install
    if build.head?
      system "cargo", "install", *std_cargo_args
      man1.install Dir["docs/man/*.1"]
    else
      prefix.install "TOOLCHAIN_NOTICES.txt"
      bin.install "mdrun"
      man1.install Dir["share/man/man1/*.1"]
    end
    prefix.install "LICENSE", "THIRD_PARTY_NOTICES.txt"
  end

  test do
    output = with_env(PATH: "") { shell_output("#{bin}/mdrun --version") }
    assert_match(/^mdrun \d+\.\d+\.\d+\n$/, output)
    assert_match "executable Markdown", shell_output("#{bin}/mdrun --help")
    (testpath/"input.txt").write "package smoke\n"
    with_env(PATH: "") do
      system bin/"mdrun", "init", "demo.md", "Package qualification"
      system bin/"mdrun", "note", "demo.md", "Recorded by the installed executable."
      system bin/"mdrun", "exec", "demo.md", "/bin/sh", "/bin/cat input.txt"
      recorded = (testpath/"demo.md").read
      assert_match "Recorded by the installed executable.", recorded
      assert_match "\npackage smoke\n", recorded
      system bin/"mdrun", "verify", "demo.md"
      File.write(testpath/"input.txt", "changed input\n")
      assert_match "changed input", shell_output("#{bin}/mdrun verify demo.md", 1)
      assert_equal recorded, (testpath/"demo.md").read
    end
  end
end
