require 'formula'

class SigrokDownloadStrategy < GitDownloadStrategy
  def support_depth?
    false
  end
end

class Libserialport < Formula
  homepage 'http://sigrok.org/'
  url 'http://sigrok.org/download/source/libserialport/libserialport-0.1.0.tar.gz'
  head 'git://sigrok.org/libserialport',:using => SigrokDownloadStrategy
  sha1 'f8677c9e63caf1f6e6cb6aa39a8ae3a256516d78'

  depends_on 'glib'
  depends_on 'libtool' => :build
  depends_on "autoconf" => :build
  depends_on "automake" => :build

  def install
    if build.head?
      system "./autogen.sh"
    end
    system "./configure", "--prefix=#{prefix}"
    system "make", "install"
  end
end
