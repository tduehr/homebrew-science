require 'formula'

class Trilinos < Formula
  homepage 'http://trilinos.sandia.gov'
  url 'http://trilinos.sandia.gov/download/files/trilinos-11.10.2-Source.tar.gz'
  sha1 'f7442cef35c4dea4f3535e0859deda88f68e72fc'

  option "with-boost",    "Enable Boost support"
  # We have build failures with scotch. Help us on this, if you can!
  # option "with-scotch",   "Enable Scotch partitioner"
  option "with-netcdf",   "Enable Netcdf support"
  option "with-teko",     "Enable 'Teko' secondary-stable package"
  option "with-shylu",    "Enable 'ShyLU' experimental package"
  option "with-zoltan",   "Enable 'Zoltan' library"
  option "without-tests", "Disable tests"
  option "remove-warnings","Removing warnings as errors for CLEANED packages"
  option "with-release",  "Compile in Release mode"

  depends_on :mpi => [:cc, :cxx]
  depends_on 'cmake' => :build
  depends_on 'boost' => :optional
  depends_on 'scotch' => :optional
  depends_on 'netcdf' => :optional
  depends_on :fortran => [:optional, '--with-fortran']

  def install

    args = [""]
    if build.with? 'release'
      args << "-DCMAKE_INSTALL_PREFIX=#{prefix}" << "-DCMAKE_BUILD_TYPE=Release"
    else
      args << std_cmake_args # -DCMAKE_INSTALL_PREFIX='/usr/local/Cellar/myapp/1.0.0' -DCMAKE_BUILD_TYPE=None -Wno-dev
    end
    args << "-DBUILD_SHARED_LIBS=ON"
    args << "-DTPL_ENABLE_MPI:BOOL=ON"
    args << "-DTPL_ENABLE_BLAS=ON"
    args << "-DTPL_ENABLE_LAPACK=ON"
    args << "-DTPL_ENABLE_Zlib:BOOL=ON"
    args << "-DTrilinos_ENABLE_ALL_PACKAGES=ON"
    args << "-DTrilinos_ENABLE_ALL_OPTIONAL_PACKAGES=ON"
    if build.with? 'fortran'
      args << "-DTrilinos_ENABLE_Fortran:BOOL=ON"
    else
      args << "-DTrilinos_ENABLE_Fortran:BOOL=OFF"
    end
    args << "-DTrilinos_ENABLE_EXAMPLES:BOOL=OFF"
    args << "-DTrilinos_VERBOSE_CONFIGURE:BOOL=OFF"
    args << "-DZoltan_ENABLE_ULLONG_IDS:Bool=ON" if build.with? 'zoltan'
    args << "-DTrilinos_ENABLE_TESTS:BOOL=OFF" if build.without? 'tests'
    args << "-DTrilinos_WARNINGS_AS_ERRORS_FLAGS:STRING=\"\"" if build.include? 'remove-warnings'

    # Extra non-default packages
    args << "-DTrilinos_ENABLE_ShyLU:BOOL=ON"  if build.with? 'shylu'
    args << "-DTrilinos_ENABLE_Teko:BOOL=ON"   if build.with? 'teko'

    # Third-party libraries
    args << "-DTPL_ENABLE_Boost:BOOL=ON"    if build.with? 'boost'
    args << "-DTPL_ENABLE_Scotch:BOOL=ON"   if build.with? 'scotch'
    args << "-DTPL_ENABLE_Netcdf:BOOL=ON"   if build.with? 'netcdf'

    mkdir 'build' do
      system "cmake", *args, "../"
      system "make"
      system "make install"
    end

  end

end
