class Locmetry < Formula
  desc "Measure source code by language, folder, and purpose"
  homepage "https://github.com/mbackschat/locmetry"
  version "0.12.0"
  license "MIT"

  head do
    url "https://github.com/mbackschat/locmetry.git", branch: "main"
    depends_on "rust" => :build
  end

  # Prebuilt release archives spare users a Rust toolchain; releases exist for
  # macOS arm64 and Linux x86_64 and aarch64 only.
  on_macos do
    on_arm do
      url "https://github.com/mbackschat/locmetry/releases/download/v0.12.0/locmetry-v0.12.0-aarch64-apple-darwin.tar.gz"
      sha256 "161f18472f3a520277a2b4f1933eda14727dcc8557a91dcff0ec85832aa0d4f3"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/mbackschat/locmetry/releases/download/v0.12.0/locmetry-v0.12.0-x86_64-unknown-linux-musl.tar.gz"
      sha256 "57b93e6d5aef7626fc33a4615e792282b2d782d4a43e2423a85a802a100cca59"
    end
    on_arm do
      url "https://github.com/mbackschat/locmetry/releases/download/v0.12.0/locmetry-v0.12.0-aarch64-unknown-linux-musl.tar.gz"
      sha256 "4d5cbeaf472062a3ba14f2e04f0e9ad13285be56ce04a8e79a145d5ce7869911"
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
