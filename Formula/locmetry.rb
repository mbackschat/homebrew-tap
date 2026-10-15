class Locmetry < Formula
  desc "Measure source code by language, folder, and purpose"
  homepage "https://github.com/mbackschat/locmetry"
  version "0.1.5"
  license "MIT"

  head do
    url "https://github.com/mbackschat/locmetry.git", branch: "main"
    depends_on "rust" => :build
  end

  # Prebuilt release archives spare users a Rust toolchain; releases exist for
  # macOS arm64 and Linux x86_64 and aarch64 only.
  on_macos do
    on_arm do
      url "https://github.com/mbackschat/locmetry/releases/download/v0.1.5/locmetry-v0.1.5-aarch64-apple-darwin.tar.gz"
      sha256 "2ae1d416724b70d9becce6ee2a4c1786b6603aa0fcb8532ea71a0f7a784824a0"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/mbackschat/locmetry/releases/download/v0.1.5/locmetry-v0.1.5-x86_64-unknown-linux-musl.tar.gz"
      sha256 "83decf6c7dc0938ae76475ba44dac8de1a4878f8091723ad4cef14ab4a443d45"
    end
    on_arm do
      url "https://github.com/mbackschat/locmetry/releases/download/v0.1.5/locmetry-v0.1.5-aarch64-unknown-linux-musl.tar.gz"
      sha256 "6d3ac159887a1fd15305eed2615c02454dfdf570e2e9466fdf36e9f0f605c866"
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
