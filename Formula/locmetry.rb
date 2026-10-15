class Locmetry < Formula
  desc "Measure code with embedded Tokei and reviewed classification rules"
  homepage "https://github.com/mbackschat/locmetry"
  version "0.1.1"
  license any_of: ["MIT", "Apache-2.0"]

  head do
    url "https://github.com/mbackschat/locmetry.git", branch: "main"
    depends_on "rust" => :build
  end

  # Prebuilt release archives spare users a Rust toolchain; releases exist for
  # macOS arm64 and Linux x86_64 and aarch64 only.
  on_macos do
    on_arm do
      url "https://github.com/mbackschat/locmetry/releases/download/v0.1.1/locmetry-v0.1.1-aarch64-apple-darwin.tar.gz"
      sha256 "54dfc2a13d492ff527d07cdc4c30aab630e30dda8fbbb5682a4e7af3db0f660b"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/mbackschat/locmetry/releases/download/v0.1.1/locmetry-v0.1.1-x86_64-unknown-linux-musl.tar.gz"
      sha256 "e1f55f4ab3bf4df922d9d224b2c0bd7dce45cfae9ddc51b9dc4f0fab3fc7e307"
    end
    on_arm do
      url "https://github.com/mbackschat/locmetry/releases/download/v0.1.1/locmetry-v0.1.1-aarch64-unknown-linux-musl.tar.gz"
      sha256 "4821298f49018b04124b23e059537adc1ce094174c363e0e511094a3a9d7f8d9"
    end
  end

  def install
    if build.head?
      system "cargo", "install", *std_cargo_args
    else
      bin.install "locmetry"
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
