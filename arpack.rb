require 'formula'

class Arpack < Formula
  homepage 'http://forge.scilab.org/index.php/p/arpack-ng'
  url 'http://forge.scilab.org/index.php/p/arpack-ng/downloads/get/arpack-ng_3.1.4.tar.gz'
  sha1 '1fb817346619b04d8fcdc958060cc0eab2c73c6f'
  head 'git://git.forge.scilab.org/arpack-ng.git'

  depends_on :fortran
  depends_on :mpi => [:optional, :f77]
  depends_on "openblas" => :optional
  depends_on "veclibfort" if build.without? "openblas"

  def install
    ENV.m64 if MacOS.prefer_64_bit?

    args = ["--disable-dependency-tracking", "--prefix=#{libexec}"]
    args << "--enable-mpi" if build.with? :mpi
    if build.with? "openblas"
      args << "--with-blas=-L#{Formula["openblas"].opt_lib} -lopenblas"
    else
      args << "--with-blas=-L#{Formula["veclibfort"].opt_lib} -lvecLibFort"
    end

    if build.with? :mpi
      ENV['CC']  = "#{HOMEBREW_PREFIX}/bin/mpicc"
      ENV['CXX'] = "#{HOMEBREW_PREFIX}/bin/mpic++"
      ENV['F77'] = "#{HOMEBREW_PREFIX}/bin/mpif77"
    end

    system "./configure", *args
    system "make"
    system "make", "install"
    lib.install_symlink Dir["#{libexec}/lib/*"].select { |f| File.file?(f) }
    (lib/'pkgconfig').install_symlink Dir["#{libexec}/lib/pkgconfig/*"]
    (libexec/"share").install "TESTS/testA.mtx"
  end

  test do
    cd libexec/"share" do
      ["dnsimp", "bug_1323"].each do |slv|
        system "#{libexec}/bin/#{slv}"              # Reads testA.mtx
      end
    end
  end
end
