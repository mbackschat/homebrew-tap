class Locmetry < Formula
  desc "Measure source code by language, folder, and purpose"
  homepage "https://github.com/mbackschat/locmetry"
  version "0.2.0"
  license "MIT"

  head do
    url "https://github.com/mbackschat/locmetry.git", branch: "main"
    depends_on "rust" => :build
  end

  # Prebuilt release archives spare users a Rust toolchain; releases exist for
  # macOS arm64 and Linux x86_64 and aarch64 only.
  on_macos do
    on_arm do
      url "https://github.com/mbackschat/locmetry/releases/download/v0.2.0/locmetry-v0.2.0-aarch64-apple-darwin.tar.gz"
      sha256 "ba3049946d545859d06683e9532e846e32d3dd39de1f62ede9d1ae6bf3e08a9b"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/mbackschat/locmetry/releases/download/v0.2.0/locmetry-v0.2.0-x86_64-unknown-linux-musl.tar.gz"
      sha256 "3dc12098ccaa9fd643b0ccab35b18dad4d1dc5bd16faa255e58a5db08499d34f"
    end
    on_arm do
      url "https://github.com/mbackschat/locmetry/releases/download/v0.2.0/locmetry-v0.2.0-aarch64-unknown-linux-musl.tar.gz"
      sha256 "c8a89d89d2c52da6e5ec78d2f8cedfb26df62793192cb83e713f3480b27c2779"
    end
  end

  def install
    if build.head?
      system "cargo", "install", *std_cargo_args
    else
      bin.install "locmetry"
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
    refute purposes.key?("unclassified")
  end
end
