#
# creates fftfault library from C and fortran code
#
OS = `arch`
INC = $(GMTHOME)/include $(NETCDFHOME)/include
CFLAGS = -I$(INC)  -O2 -m64
FFLAGS =  -O3 -m64
FC = gfortran
#
OBJECTS=	boussinesql.o	coefl.o		coulomb.o	fourt.o\
		readgrd.o       writegrd.o 	

liba:	$(OBJECTS)
	ar rv libfftfault.a $(OBJECTS)
	rm *.o
	mv libfftfault.a $(OS)
	chmod 644 $(OS)/libfftfault.a
	ranlib $(OS)/libfftfault.a
