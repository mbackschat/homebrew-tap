class Locmetry < Formula
  desc "Measure source code by language, folder, and purpose"
  homepage "https://github.com/mbackschat/locmetry"
  version "0.7.0"
  license "MIT"

  head do
    url "https://github.com/mbackschat/locmetry.git", branch: "main"
    depends_on "rust" => :build
  end

  # Prebuilt release archives spare users a Rust toolchain; releases exist for
  # macOS arm64 and Linux x86_64 and aarch64 only.
  on_macos do
    on_arm do
      url "https://github.com/mbackschat/locmetry/releases/download/v0.7.0/locmetry-v0.7.0-aarch64-apple-darwin.tar.gz"
      sha256 "33b6406bb67286b759a0722f53143c7089d26a2937e2ed7066b6e3280e8d25d2"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/mbackschat/locmetry/releases/download/v0.7.0/locmetry-v0.7.0-x86_64-unknown-linux-musl.tar.gz"
      sha256 "ed64e935d224dfe6752df53d554c25648617f31fae8aa920ee86d790de9eec43"
    end
    on_arm do
      url "https://github.com/mbackschat/locmetry/releases/download/v0.7.0/locmetry-v0.7.0-aarch64-unknown-linux-musl.tar.gz"
      sha256 "c1b43bc5e5bc8c7b088610eeb3d1cc03a74722276c2426af3feb8c7f11e91780"
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
