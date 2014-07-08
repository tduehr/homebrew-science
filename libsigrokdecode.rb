require 'formula'

class SigrokDownloadStrategy < GitDownloadStrategy
  def support_depth?
    false
  end
end

class Libsigrokdecode < Formula
  url 'http://sigrok.org/download/source/libsigrokdecode/libsigrokdecode-0.3.0.tar.gz'
  homepage 'http://sigrok.org/'
  head 'git://sigrok.org/libsigrokdecode',:using => SigrokDownloadStrategy
  sha1 'a75f2839cf62d965281bac22919e761c5210e32e'

  depends_on 'libsigrok'
  depends_on 'glib'
  depends_on 'pkg-config' => :build
  depends_on 'python3' => :build
  depends_on "autoconf" => :build
  depends_on "automake" => :build

  def install
    ENV.append_path "PKG_CONFIG_PATH", HOMEBREW_PREFIX/"Frameworks/Python.framework/Versions/3.4/lib/pkgconfig"
    if build.head?
      system "./autogen.sh"
    end
    system "./configure", "--disable-dependency-tracking", "--prefix=#{prefix}"
    system "make", "install"
  end
end
