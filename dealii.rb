require 'formula'

class Dealii < Formula

  homepage "http://www.dealii.org"
  url "https://github.com/dealii/dealii.git", :branch => "dealii-8.1"
  version "8.1"
  head do
    url "https://github.com/dealii/dealii.git", :branch => "master"
    version "8.2"
  end

  # modify devel to use
  # local repository
  # (must exist)
  devel do
    url "/Users/davydden/libs-sources/deal.ii/davydden", :using => :git
    version "8.2-devel"
  end
  # alternatively, install deal.II manually
  # to /usr/local/Cellar/dealii/devel
  # and run "brew link dealii"

  depends_on "cmake"    => :build
  depends_on :mpi       => [:cc, :cxx, :f90, :recommended]
  # @todo: switch to :recommended ?
  depends_on "boost"    => :optional
  depends_on "hdf5"     => :optional
  depends_on "mumps"    => :optional
  depends_on "metis"    => :optional
  depends_on "p4est"    => :optional
  depends_on "petsc"    => :optional
  depends_on "arpack"   => :optional
  depends_on "slepc"    => :optional
  depends_on "trilinos" => :optional

  def install
    args = %W[
      -DCMAKE_INSTALL_PREFIX=#{prefix}
      -DDEAL_II_COMPONENT_COMPAT_FILES=OFF
    ]

    if build.with? 'mpi'
      args << "-DCMAKE_C_COMPILER=#{HOMEBREW_PREFIX}/bin/mpicc"
      args << "-DCMAKE_CXX_COMPILER=#{HOMEBREW_PREFIX}/bin/mpicxx"
      args << "-DCMAKE_Fortran_COMPILER=#{HOMEBREW_PREFIX}/bin/mpif90"
    end

    mkdir 'build' do
      loc = "../"
      if build.stable? then
        loc = "../deal.II"
      end
      system "cmake", *args, loc
      system "make"
      system "make install"
    end

  end
end
