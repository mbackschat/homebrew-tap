class Locmetry < Formula
  desc "Measure source code by language, folder, and purpose"
  homepage "https://github.com/mbackschat/locmetry"
  version "0.11.1"
  license "MIT"

  head do
    url "https://github.com/mbackschat/locmetry.git", branch: "main"
    depends_on "rust" => :build
  end

  # Prebuilt release archives spare users a Rust toolchain; releases exist for
  # macOS arm64 and Linux x86_64 and aarch64 only.
  on_macos do
    on_arm do
      url "https://github.com/mbackschat/locmetry/releases/download/v0.11.1/locmetry-v0.11.1-aarch64-apple-darwin.tar.gz"
      sha256 "ea0166721467f5da53f9d75802dcd704eef575fc7ff4e7d227c66e6818b120f8"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/mbackschat/locmetry/releases/download/v0.11.1/locmetry-v0.11.1-x86_64-unknown-linux-musl.tar.gz"
      sha256 "00e0c1cfb83c1c7f63e22b0f7abdc48d211bbdf14b6e1aad4bb3942b0b58ee5b"
    end
    on_arm do
      url "https://github.com/mbackschat/locmetry/releases/download/v0.11.1/locmetry-v0.11.1-aarch64-unknown-linux-musl.tar.gz"
      sha256 "2748586b788e6e77ca201ce557d5f463abb0139e88849ab8d0f0cc9bc543a644"
    end
  end

  def install
    if build.head?
      system "cargo", "install", *std_cargo_args
      bin.install "scripts/compare-locmetry-files.sh"
    else
      bin.install "locmetry", "compare-locmetry-files.sh"
      prefix.install "THIRD-PARTY-NOTICES.md"
    end
    # From the installed binary, so they match its version; PowerShell is left
    # out because the helper would ask for a complete-pwsh kind.
    generate_completions_from_executable(bin/"locmetry", "--generate",
                                         shells: [:bash, :zsh, :fish], shell_parameter_format: "complete-")
    (man1/"locmetry.1").write Utils.safe_popen_read(bin/"locmetry", "--generate", "man")
  end

  test do
    (testpath/"project/src/lib.rs").write "pub fn answer() -> u32 {\n    42\n}\n"
    (testpath/"project/tests/answer.rs").write "#[test]\nfn answer() {\n    assert_eq!(2 + 2, 4);\n}\n"
    (testpath/"project/.locmetryrc").write <<~TOML
      version = 1

      [[rules]]
      id = "library"
      match = ["src/**"]
      purpose = "production"
    TOML

    # An empty PATH guards against a runtime dependency on any other executable.
    output = with_env(PATH: "") { shell_output("#{bin}/locmetry --root #{testpath}/project") }
    purposes = JSON.parse(output)["summary"]["source_purpose"]
    assert_equal 3, purposes["production"]["code"]
    assert_equal 4, purposes["test"]["code"]
    refute purposes.key?("other")
    assert_match "locmetry", (man1/"locmetry.1").read
    assert_match "--show-folders", (bash_completion/"locmetry").read
    assert_match "Usage: compare-locmetry-files.sh", shell_output("#{bin}/compare-locmetry-files.sh --help")
    error = with_env(PATH: "") do
      shell_output("/bin/bash #{bin}/compare-locmetry-files.sh before.json after.json 2>&1", 1)
    end
    assert_match "brew install jq", error
  end
end
