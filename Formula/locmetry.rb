class Locmetry < Formula
  desc "Measure source code by language, folder, and purpose"
  homepage "https://github.com/mbackschat/locmetry"
  version "0.5.0"
  license "MIT"

  head do
    url "https://github.com/mbackschat/locmetry.git", branch: "main"
    depends_on "rust" => :build
  end

  # Prebuilt release archives spare users a Rust toolchain; releases exist for
  # macOS arm64 and Linux x86_64 and aarch64 only.
  on_macos do
    on_arm do
      url "https://github.com/mbackschat/locmetry/releases/download/v0.5.0/locmetry-v0.5.0-aarch64-apple-darwin.tar.gz"
      sha256 "dee877a755d486eb39798bfae1539770abafea668f0503c2b7068707ff0813fd"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/mbackschat/locmetry/releases/download/v0.5.0/locmetry-v0.5.0-x86_64-unknown-linux-musl.tar.gz"
      sha256 "3180f683148b1e99bc9cd1ad50de19228616643f92351b3d8f0df5785020827c"
    end
    on_arm do
      url "https://github.com/mbackschat/locmetry/releases/download/v0.5.0/locmetry-v0.5.0-aarch64-unknown-linux-musl.tar.gz"
      sha256 "5a3bcfb4665ddb672ddd52548f80f72ed0529457e1a085c50862a79e9e726bc9"
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
    refute purposes.key?("other")
  end
end
