class Locmetry < Formula
  desc "Measure source code by language, folder, and purpose"
  homepage "https://github.com/mbackschat/locmetry"
  version "0.7.5"
  license "MIT"

  head do
    url "https://github.com/mbackschat/locmetry.git", branch: "main"
    depends_on "rust" => :build
  end

  # Prebuilt release archives spare users a Rust toolchain; releases exist for
  # macOS arm64 and Linux x86_64 and aarch64 only.
  on_macos do
    on_arm do
      url "https://github.com/mbackschat/locmetry/releases/download/v0.7.5/locmetry-v0.7.5-aarch64-apple-darwin.tar.gz"
      sha256 "8aae5e72433c9db67b6f165ebe365304d38f438f5c95c8410c0fb2c801743bf7"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/mbackschat/locmetry/releases/download/v0.7.5/locmetry-v0.7.5-x86_64-unknown-linux-musl.tar.gz"
      sha256 "bf3916194a75c3577d6823a4da545b701db1435174b7aafb60ac6a90dbc4aefd"
    end
    on_arm do
      url "https://github.com/mbackschat/locmetry/releases/download/v0.7.5/locmetry-v0.7.5-aarch64-unknown-linux-musl.tar.gz"
      sha256 "5e6c3afd02b1aea4fd70b9ae4761418cfa37262bb24b66b9758e4104a8499755"
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
