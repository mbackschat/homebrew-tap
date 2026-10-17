class Locmetry < Formula
  desc "Measure source code by language, folder, and purpose"
  homepage "https://github.com/mbackschat/locmetry"
  version "0.4.1"
  license "MIT"

  head do
    url "https://github.com/mbackschat/locmetry.git", branch: "main"
    depends_on "rust" => :build
  end

  # Prebuilt release archives spare users a Rust toolchain; releases exist for
  # macOS arm64 and Linux x86_64 and aarch64 only.
  on_macos do
    on_arm do
      url "https://github.com/mbackschat/locmetry/releases/download/v0.4.1/locmetry-v0.4.1-aarch64-apple-darwin.tar.gz"
      sha256 "44c7ccd588d4d0f682cfec528c62b83a8bec833c52f6d598c0e285979bb7bbdf"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/mbackschat/locmetry/releases/download/v0.4.1/locmetry-v0.4.1-x86_64-unknown-linux-musl.tar.gz"
      sha256 "db9b33b54ffb53f2902f9cd5989d68f7fbbb9e5fcc85dacf8601762a2caab057"
    end
    on_arm do
      url "https://github.com/mbackschat/locmetry/releases/download/v0.4.1/locmetry-v0.4.1-aarch64-unknown-linux-musl.tar.gz"
      sha256 "7cafb34d2cdde7fe2c1711c5a12d898c3d17c2ddfa1a7c30ce80f23bdba18229"
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
