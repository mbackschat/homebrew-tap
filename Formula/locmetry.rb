class Locmetry < Formula
  desc "Measure source code by language, folder, and purpose"
  homepage "https://github.com/mbackschat/locmetry"
  version "0.7.6"
  license "MIT"

  head do
    url "https://github.com/mbackschat/locmetry.git", branch: "main"
    depends_on "rust" => :build
  end

  # Prebuilt release archives spare users a Rust toolchain; releases exist for
  # macOS arm64 and Linux x86_64 and aarch64 only.
  on_macos do
    on_arm do
      url "https://github.com/mbackschat/locmetry/releases/download/v0.7.6/locmetry-v0.7.6-aarch64-apple-darwin.tar.gz"
      sha256 "0a55f3d9eae778923fec0ba11a685e091975ef167f4ed8517ee49b1d38ab3aa9"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/mbackschat/locmetry/releases/download/v0.7.6/locmetry-v0.7.6-x86_64-unknown-linux-musl.tar.gz"
      sha256 "e90b8bdbe8cd7669b4552fd528c6758c284248cff45984f43966bf08a62665bb"
    end
    on_arm do
      url "https://github.com/mbackschat/locmetry/releases/download/v0.7.6/locmetry-v0.7.6-aarch64-unknown-linux-musl.tar.gz"
      sha256 "ade0a19e355bf5ad44dd32d02c266428f0a4f7394cb40cd9ae32202348887cc1"
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
