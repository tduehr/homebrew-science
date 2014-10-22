require 'formula'

class Slepc < Formula
  homepage 'http://www.grycap.upv.es/slepc'
  url 'http://www.grycap.upv.es/slepc/download/download.php?filename=slepc-3.5.2.tar.gz'
  sha1 '23675bee5c010d20f4a08f80f22120119ddb940a'

  depends_on 'petsc' => :build
  depends_on :mpi => [:cc, :f90]
  depends_on :fortran
  depends_on :x11  => MacOS::X11.installed? ? :recommended : :optional
  depends_on 'arpack' => :optional

  tmp = "#{Formula["petsc"].prefix}"
  tmp = tmp.rpartition("-");
  if tmp[2].length > 0
    version ("3.5.2-" + tmp[2])
  end

  # Trick SLEPc into thinking we don't have a prefix install of PETSc.
  patch :DATA

  def install
    ENV.deparallelize
    petsc_arch = 'arch-darwin-c-opt'
    ENV['SLEPC_DIR'] = Dir.getwd
    ENV['PETSC_DIR'] = Formula["petsc"].opt_prefix
    ENV['PETSC_ARCH'] = petsc_arch
    args = %W[
      --prefix=#{prefix}/#{petsc_arch}
    ]
    args << "--with-arpack-dir=#{Formula["arpack"].opt_prefix}/lib" << "--with-arpack-flags=-lparpack,-larpack" if build.with? "arpack"
    system "./configure", *args
    system "make PETSC_ARCH=#{petsc_arch}"
    system "make PETSC_ARCH=#{petsc_arch} install"
    #ENV['PETSC_ARCH'] = ''  # If this line is un-commented, tests do not compile
    system "make SLEPC_DIR=#{prefix}/#{petsc_arch} test"
    ohai 'Test results are in ~/Library/Logs/Homebrew/slepc. Please check.'

    # Link what we need.
    include.install_symlink Dir["#{prefix}/#{petsc_arch}/include/*.h"], "#{prefix}/#{petsc_arch}/finclude", "#{prefix}/#{petsc_arch}/slepc-private"
    lib.install_symlink Dir["#{prefix}/#{petsc_arch}/lib/*.a"], Dir["#{prefix}/#{petsc_arch}/lib/*.dylib"]
    prefix.install_symlink "#{prefix}/#{petsc_arch}/conf"
    doc.install 'docs/slepc.pdf', Dir["docs/*.htm"], 'docs/manualpages'  # They're not really man pages.
    share.install 'share/slepc/datafiles'
  end

  def caveats; <<-EOS.undent
    Set your SLEPC_DIR to #{prefix}/arch-darwin-c-opt.
    Fortran modules are in #{prefix}/arch-darwin-c-opt/include.
    EOS
  end
end

__END__
diff --git a/config/configure.py b/config/configure.py
index 7d2fd64..22351c3 100755
--- a/config/configure.py
+++ b/config/configure.py
@@ -215,8 +215,6 @@ if petscversion.VERSION < slepcversion.VERSION:
 petscconf.Load(petscdir)
 if not petscconf.PRECISION in ['double','single','__float128']:
   sys.exit('ERROR: This SLEPc version does not work with '+petscconf.PRECISION+' precision')
-if prefixinstall and not petscconf.ISINSTALL:
-  sys.exit('ERROR: SLEPc cannot be configured for non-source installation if PETSc is not configured in the same way.')

 # Check whether this is a working copy of the repository
 isrepo = 0

