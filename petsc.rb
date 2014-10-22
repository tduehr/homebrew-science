require 'formula'

class Petsc < Formula
  homepage 'http://www.mcs.anl.gov/petsc/index.html'
  url 'http://ftp.mcs.anl.gov/pub/petsc/release-snapshots/petsc-3.5.2.tar.gz'
  sha1 'aa56e0a0e3ad001cd436ea10e4f1c885cea3b9bb'
  head 'https://bitbucket.org/petsc/petsc', :using => :git

  option 'without-check', 'Skip build-time tests (not recommended)'
  option 'complex', 'Build complex-valued version of PETSc'

  if build.include? "complex"
    version "3.5.2-complex"
  else
    version "3.5.2-real"
  end

  depends_on :mpi => :cc
  depends_on :fortran
  depends_on :x11 => :optional
  depends_on 'cmake' => :build

  option 'with-downloaded', 'Download and compile superlu_dist, metis, parmetis, scalapack, mumps, hypre provided by PETSc and ignore optional dependencies.'
  # use --with-foo to invoke those:
  depends_on "superlu_dist" => :optional
  depends_on "metis"        => :optional
  depends_on "parmetis"     => :optional
  depends_on "scalapack"    => :optional
  depends_on "mumps"        => :optional

  def install
    ENV.deparallelize # PETSc compiles are automatically parallel

    petsc_arch = 'arch-darwin-c-opt'
    args = %W[
      --with-debugging=0
      --with-shared-libraries=1
      --prefix=#{prefix}/#{petsc_arch}
    ]

    if build.with? 'downloaded'
      args << "--download-superlu_dist"<<"--download-metis"<<"--download-parmetis"<<"--download-scalapack"<<"--download-mumps"
    else
      args << "--with-superlu_dist-include=#{HOMEBREW_PREFIX}/include/superlu_dist" << "--with-superlu_dist-lib=#{HOMEBREW_PREFIX}/lib/libsuperlu_dist.a" if build.with? "superlu_dist"

      args << "--with-metis-dir=#{Formula["metis"].prefix}" if build.with? "metis"

      args << "--with-parmetis-dir=#{Formula["parmetis"].prefix}" if build.with? "parmetis"

      args << "--with-scalapack-dir=#{Formula["scalapack"].prefix}" if build.with? "scalapack"

      args << "--with-mumps-dir=#{Formula["mumps"].prefix}" if build.with? "mumps"
    end

    if build.include? 'complex'
      args << '--with-scalar-type=complex'
    else
      args << '--with-scalar-type=real'
      args << '--download-hypre' if build.with? 'downloaded'
    end

    args << "--with-x=0" if build.without? 'x11'
    ENV['PETSC_DIR'] = Dir.getwd  # configure fails if those vars are set differently.
    ENV['PETSC_ARCH'] = petsc_arch
    system "./configure", *args
    system "make all"
    system "make test" if build.with? "check"
    system "make install"

    # Link only what we want.
    include.install_symlink Dir["#{prefix}/#{petsc_arch}/include/*h"], "#{prefix}/#{petsc_arch}/include/finclude", "#{prefix}/#{petsc_arch}/include/petsc-private"
    prefix.install_symlink "#{prefix}/#{petsc_arch}/conf"
    lib.install_symlink Dir["#{prefix}/#{petsc_arch}/lib/*.a"], Dir["#{prefix}/#{petsc_arch}/lib/*.dylib"]
    share.install_symlink Dir["#{prefix}/#{petsc_arch}/share/*"]
  end

  def caveats; <<-EOS
    Set PETSC_DIR to #{prefix}
    and PETSC_ARCH to arch-darwin-c-opt.
    Fortran module files are in #{prefix}/arch-darwin-c-opt/include.
    EOS
  end
end
