class Libu2fServer < Formula
  desc "Server-side of the Universal 2nd Factor (U2F) protocol"
  homepage "https://developers.yubico.com/libu2f-server/"
  url "https://developers.yubico.com/libu2f-server/Releases/libu2f-server-1.1.0.tar.xz"
  sha256 "8dcd3caeacebef6e36a42462039fd035e45fa85653dcb2013f45e15aad49a277"
  license "BSD-2-Clause"
  revision 3

  bottle do
    rebuild 2
    sha256 cellar: :any,                 arm64_tahoe:   "1f6dc85655a657696739653856a19b9c40aa78568e7e5a2ea94d5f0c68a3d0da"
    sha256 cellar: :any,                 arm64_sequoia: "34a43fb5381fdea58efb651c79798f64cb3ea99761781948c6bb5aa7399a5316"
    sha256 cellar: :any,                 arm64_sonoma:  "0c1d9d77250e1ae7bddaa71d0317d26c051ac7b0a5c7522981936ed284f23aa2"
    sha256 cellar: :any,                 sonoma:        "d6574a1ff40f123bd2061d0736d628db3049742b74941d6cd2beee5634734111"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "7ace9964e1c7e0bb6bcd6b2da985351b3b27c5fa8a40a58af8a5bfbbbbd60cce"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "dc10a9b905ef6379affe6dafd1cd8226f716bf55b8429d04ae93a7287668988c"
  end

  # https://www.yubico.com/support/terms-conditions/yubico-end-of-life-policy/eol-products/
  deprecate! date: "2025-11-22", because: :unmaintained, replacement_formula: "libfido2"
  disable! date: "2026-11-22", because: :unmaintained, replacement_formula: "libfido2"

  depends_on "check" => :build
  depends_on "gengetopt" => :build
  depends_on "help2man" => :build
  depends_on "pkgconf" => :build
  depends_on "json-c"
  depends_on "openssl@3"

  # Compatibility with json-c 0.14. Remove with the next release.
  patch do
    url "https://github.com/Yubico/libu2f-server/commit/f7c4983b31909299c47bf9b2627c84b6bfe225de.patch?full_index=1"
    sha256 "012d1d759604ea80f6075b74dc9c7d8a864e4e5889fb82a222db93a6bd72cd1b"
  end

  def install
    ENV["LIBSSL_LIBS"] = "-lssl -lcrypto -lz"
    ENV["LIBCRYPTO_LIBS"] = "-lcrypto -lz"
    ENV["PKG_CONFIG"] = "#{Formula["pkgconf"].opt_bin}/pkg-config"

    system "./configure", "--disable-silent-rules", *std_configure_args
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<~C
      #include <u2f-server/u2f-server.h>
      int main()
      {
        if (u2fs_global_init(U2FS_DEBUG) != U2FS_OK)
        {
          return 1;
        }

        u2fs_ctx_t *ctx;
        if (u2fs_init(&ctx) != U2FS_OK)
        {
          return 1;
        }

        u2fs_done(ctx);
        u2fs_global_done();
        return 0;
      }
    C
    system ENV.cc, "test.c", "-o", "test", "-I#{include}", "-L#{lib}", "-lu2f-server"
    system "./test"
  end
end
