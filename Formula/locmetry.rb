class Locmetry < Formula
  desc "Measure code with embedded Tokei and reviewed classification rules"
  homepage "https://github.com/mbackschat/locmetry"
  version "0.1.0"
  license any_of: ["MIT", "Apache-2.0"]

  head do
    url "https://github.com/mbackschat/locmetry.git", branch: "main"
    depends_on "rust" => :build
  end

  # Prebuilt release archives spare users a Rust toolchain; releases exist for
  # macOS arm64 and Linux x86_64 and aarch64 only.
  on_macos do
    on_arm do
      url "https://github.com/mbackschat/locmetry/releases/download/v0.1.0/locmetry-v0.1.0-aarch64-apple-darwin.tar.gz"
      sha256 "4fc776e0119f570307caf94760600beca42b5ad7eeca0ea358c0422fe29357b3"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/mbackschat/locmetry/releases/download/v0.1.0/locmetry-v0.1.0-x86_64-unknown-linux-musl.tar.gz"
      sha256 "6f96552423f830e8bf2a5157e3770bd4749f1d56808c1381076b73dc947310a9"
    end
    on_arm do
      url "https://github.com/mbackschat/locmetry/releases/download/v0.1.0/locmetry-v0.1.0-aarch64-unknown-linux-musl.tar.gz"
      sha256 "798cf889530239873403c635c1648620b92d5edb1462c25c33a2c5cddf13b2c5"
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
