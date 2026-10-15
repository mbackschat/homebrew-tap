class Locmetry < Formula
  desc "Measure source code by language, folder, and purpose"
  homepage "https://github.com/mbackschat/locmetry"
  version "0.1.2"
  license "MIT"

  head do
    url "https://github.com/mbackschat/locmetry.git", branch: "main"
    depends_on "rust" => :build
  end

  # Prebuilt release archives spare users a Rust toolchain; releases exist for
  # macOS arm64 and Linux x86_64 and aarch64 only.
  on_macos do
    on_arm do
      url "https://github.com/mbackschat/locmetry/releases/download/v0.1.2/locmetry-v0.1.2-aarch64-apple-darwin.tar.gz"
      sha256 "ff3b584ee8395204703f27d67a05b7480d8d12ea87ff19b9f33a92008f7b030b"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/mbackschat/locmetry/releases/download/v0.1.2/locmetry-v0.1.2-x86_64-unknown-linux-musl.tar.gz"
      sha256 "b23e3973ca61ba9acf231316dd45d6838c1e6e7dc0a7246059104138598f998a"
    end
    on_arm do
      url "https://github.com/mbackschat/locmetry/releases/download/v0.1.2/locmetry-v0.1.2-aarch64-unknown-linux-musl.tar.gz"
      sha256 "10229f7c051517e371a5a6be8498fc98649d20b63bb8ae0541cb4ead1daf9c9a"
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
