require "formula"

class SigrokDownloadStrategy < GitDownloadStrategy
  def support_depth?
    false
  end
end

class SigrokCli < Formula
  url "http://sigrok.org/download/source/sigrok-cli/sigrok-cli-0.5.0.tar.gz"
  homepage "http://sigrok.org/"
  head "git://sigrok.org/sigrok-cli",:using => SigrokDownloadStrategy
  sha1 "6fb5d6ff75f6492bca8d3da66ba446a6438438de"

  if build.head?
    depends_on "glib"
    depends_on "libtool" => :build
    depends_on "autoconf" => :build
    depends_on "automake" => :build
  end

  depends_on "pkg-config" => :build
  depends_on "cmake" => :build

  depends_on "libsigrokdecode"

  def install
    lsgd = Formula["libsigrokdecode"].opt_prefix

    system "./autogen.sh" if build.head?
    system "./configure", "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    system "#{bin}/sigrok-cli", "--version"
  end
end
