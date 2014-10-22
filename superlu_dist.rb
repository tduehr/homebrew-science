require "formula"

class SuperluDist < Formula
  homepage "http://crd-legacy.lbl.gov/~xiaoye/SuperLU/"
  url "http://crd-legacy.lbl.gov/~xiaoye/SuperLU/superlu_dist_3.3.tar.gz"
  sha1 "1f44b6e8382b402a61ef107d962f8602e90498a4"

  depends_on :fortran
  depends_on 'parmetis'
  depends_on 'openblas' => :optional
  depends_on :mpi => [:cc, :f90]

  def install
    cp "MAKE_INC/make.i386_linux", "./make.inc"
    make_args = %W[
         PLAT=_mac_x
         CDEFS=-DAdd_
         DSuperLUroot=#{buildpath}
         DSUPERLULIB=$(DSuperLUroot)/lib/libsuperlu_dist.a
         METISLIB=-L#{Formula["metis"].opt_lib} -lmetis
         PARMETISLIB=-L#{Formula["parmetis"].opt_lib} -lparmetis
    ]

    make_args << ((build.with? "openblas") ? "BLASLIB=-L#{Formula["openblas"].opt_lib} -lopenblas" : "BLASLIB=-framework Accelerate")

    system "make", "lib", *make_args
    prefix.install "make.inc"
    File.open(prefix / "make_args.txt", "w") do |f|
      f.puts(make_args.join(" "))  # Record options passed to make.
    end
    lib.install Dir["lib/*"]
    (include / "superlu_dist").install Dir["SRC/*.h"]
    doc.install Dir["Doc/*"]
    (share / "superlu_dist").install "EXAMPLE"
  end
end
