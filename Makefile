LINKFLAGS_FOR = -pedantic -O3 -march=native 
COMP_FOR = gfortran
GNUPLOT_SCRIPT = png.gp
check:
	GFORTRANVERSION = $(shell gfortran -dumpversion)
	GFORTRANVERSIONGTEQ4 := $(shell expr `gfortran -dumpversion` \== 4.9.2)
	ifeq "$(GFORTRANVERSIONGTEQ4)" "1"
		$(error Version de gfortran no valida: use 4.9.2 o superior )
	endif
install:
	${COMP_FOR} ${LINKFLAGS_FOR} CRM.f90 -o CRM
all:
	make install
	make execute
	make clean
execute:
	time ./CRM < input
clean:;         @rm -f *.o *.mod CRM
