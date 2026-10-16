class Locmetry < Formula
  desc "Measure source code by language, folder, and purpose"
  homepage "https://github.com/mbackschat/locmetry"
  version "0.3.0"
  license "MIT"

  head do
    url "https://github.com/mbackschat/locmetry.git", branch: "main"
    depends_on "rust" => :build
  end

  # Prebuilt release archives spare users a Rust toolchain; releases exist for
  # macOS arm64 and Linux x86_64 and aarch64 only.
  on_macos do
    on_arm do
      url "https://github.com/mbackschat/locmetry/releases/download/v0.3.0/locmetry-v0.3.0-aarch64-apple-darwin.tar.gz"
      sha256 "b557cb2fedccd17e2a68774958b3cd2791b2026a38c660141ddd6fef3c93f6cd"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/mbackschat/locmetry/releases/download/v0.3.0/locmetry-v0.3.0-x86_64-unknown-linux-musl.tar.gz"
      sha256 "2b603bc0612fcb0d66fd8ae22dbb13f4f2b30585f63b6acf6258be208bd6faa3"
    end
    on_arm do
      url "https://github.com/mbackschat/locmetry/releases/download/v0.3.0/locmetry-v0.3.0-aarch64-unknown-linux-musl.tar.gz"
      sha256 "633996782bbafd966d6ec943e80878c90227e33b377add17585573d9d59ff559"
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
