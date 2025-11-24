class Corepack < Formula
  desc "Package acting as bridge between Node projects and their package managers"
  homepage "https://github.com/nodejs/corepack"
  url "https://registry.npmjs.org/corepack/-/corepack-0.34.5.tgz"
  sha256 "b922e4676a74ecd9b5b82b45339a7514ca65e750b9ef2d5309f1454b7a5d326f"
  license "MIT"

  livecheck do
    url "https://registry.npmjs.org/corepack/latest"
    regex(/["']version["']:\s*?["']([^"']+)["']/i)
  end

  bottle do
    sha256 cellar: :any_skip_relocation, all: "ec9a6823119cd92ae4ff22044083b74f3829de26bade4f044c213f09a166b46e"
  end

  depends_on "node"

  conflicts_with "hadoop", because: "both install `yarn` binaries"
  conflicts_with "pnpm", because: "both install `pnpm` and `pnpx` binaries"
  conflicts_with "yarn", because: "both install `yarn` and `yarnpkg` binaries"

  def install
    system "npm", "install", *std_npm_args
    bin.install_symlink Dir["#{libexec}/bin/*"]
  end

  test do
    system bin/"corepack"

    (testpath/"package.json").write('{"name": "test"}')
    system bin/"yarn", "add", "jquery"
    system bin/"yarn", "add", "fsevents", "--build-from-source=true" if OS.mac?

    (testpath/"package.json").delete
    system bin/"pnpm", "init"
    assert_path_exists testpath/"package.json", "package.json must exist"
  end
end
