require 'formula'

class SigrokDownloadStrategy < GitDownloadStrategy
  def support_depth?
    false
  end
end

class Libsigrokdecode < Formula
  url 'http://sigrok.org/download/source/libsigrokdecode/libsigrokdecode-0.3.0.tar.gz'
  homepage 'http://sigrok.org/'
  head 'git://sigrok.org/libsigrokdecode', :using => SigrokDownloadStrategy
  sha1 'a75f2839cf62d965281bac22919e761c5210e32e'

  depends_on 'glib'
  depends_on 'libzip'
  depends_on 'python3'
  depends_on 'libftdi0' => :optional
  depends_on 'libusb' => :recommended
  depends_on 'pkg-config' => :build
  depends_on 'check' => :optional

  if build.head?
    depends_on 'libtool' => :build
    depends_on 'autoconf' => :build
    depends_on 'automake' => :build
  end

  option 'with-libserialport'
  option 'with-librevisa'

  resource 'librevisa' do
    if build.head?
      url 'http://www.librevisa.org/git/librevisa.git'
    else
      url 'http://www.librevisa.org/download/librevisa-0.0.20130412.tar.gz'
    end
    sha1 '1bb24a6721cc994494f294fd86c78594ba4f8b40'
  end if build.with? 'librevisa'

  resource 'libserialport' do
    if build.head?
      url 'git://sigrok.org/libserialport', :using => SigrokDownloadStrategy
    else
      url 'http://sigrok.org/download/source/libserialport/libserialport-0.1.0.tar.gz'
    end
    sha1 'f8677c9e63caf1f6e6cb6aa39a8ae3a256516d78'
  end if build.with? 'libserialport'

  resource 'libsigrok' do
    if build.head?
      url 'git://sigrok.org/libsigrok', :using => SigrokDownloadStrategy
    else
      url 'http://sigrok.org/download/source/libsigrok/libsigrok-0.3.0.tar.gz'
    end
    sha1 '140db550820f98042d95432a87a9d7e3078b1490'
  end

  def install
    common_args = %W[
      --disable-dependency-tracking
      --prefix=#{prefix}
    ]

    ENV.append_path('PKG_CONFIG_PATH', lib/'pkgconfig')

    resource('libserialport').stage do
      system './autogen.sh' if build.head?
      system './configure', *common_args
      system 'make', 'install'
    end if build.with? 'libserialport'

    resource('librevisa').stage do
      system "./autogen.sh" if build.head?
      system "./configure", *common_args
      system "make", "install"
    end

    # not strictly needed for libsigrokdecode but both sigrok-cli and pulseview
    # need it so we install it here as a resource to avoid collisions
    resource('libsigrok').stage do
      system "./autogen.sh" if build.head?
      system "./configure", *common_args
      system "make", "install"
      system "ln", "-s", "/usr/local/share/", share
    end

    qt = Formula['qt'].opt_prefix
    args = std_cmake_args + %W[
      -DPNG_INCLUDE_DIR=#{MacOS::X11.include}
      -DALTERNATIVE_QT_INCLUDE_DIR=#{qt}/include
      -DQT_SRC_DIR=#{qt}/src
    ]

    python_prefix = `python3-config --prefix`.strip
    args << '-DPYTHON_LIBRARY=#{python_prefix}/Python'
    args << '-DPYTHON_INCLUDE_DIR=#{python_prefix}/Headers'
    ENV['python3_CFLAGS'] = `python3-config --cflags`
    ENV['python3_LIBS'] = `python3-config --libs`.gsub('-lpython3.4', '')

    system './autogen.sh' if build.head?
    system './configure', *common_args
    system 'make', 'check' if build.with? 'check'
    system 'make', 'install'
  end
end
