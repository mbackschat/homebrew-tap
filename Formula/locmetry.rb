class Locmetry < Formula
  desc "Measure source code by language, folder, and purpose"
  homepage "https://github.com/mbackschat/locmetry"
  version "0.8.0"
  license "MIT"

  head do
    url "https://github.com/mbackschat/locmetry.git", branch: "main"
    depends_on "rust" => :build
  end

  # Prebuilt release archives spare users a Rust toolchain; releases exist for
  # macOS arm64 and Linux x86_64 and aarch64 only.
  on_macos do
    on_arm do
      url "https://github.com/mbackschat/locmetry/releases/download/v0.8.0/locmetry-v0.8.0-aarch64-apple-darwin.tar.gz"
      sha256 "2f7e20f38a2042af476a8f2b551004dc2f0596034f000d5abaa25fb7ed675458"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/mbackschat/locmetry/releases/download/v0.8.0/locmetry-v0.8.0-x86_64-unknown-linux-musl.tar.gz"
      sha256 "73e57e08c331669525b515991f0d0999b6be53691ab1373f78ad83c1a2d7cd70"
    end
    on_arm do
      url "https://github.com/mbackschat/locmetry/releases/download/v0.8.0/locmetry-v0.8.0-aarch64-unknown-linux-musl.tar.gz"
      sha256 "7a06261c5f7f30eee33ec4bf05f936356bdbfcebdedd128d04e6ea0a3193d62e"
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
    assert_match "Usage: compare-locmetry-files.sh", shell_output("#{bin}/compare-locmetry-files.sh --help")
    error = with_env(PATH: "") do
      shell_output("/bin/bash #{bin}/compare-locmetry-files.sh before.json after.json 2>&1", 1)
    end
    assert_match "brew install jq", error
  end
end
