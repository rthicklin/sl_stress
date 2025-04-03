#
#       Makefile for 64-bit intel mac 
#
OS = `arch`
GMT     = $(GMTHOME)/lib/libgmt.a
CDF     = $(NETCDFHOME)/lib/libnetcdf.a
FFT     = ../../lib/$(OS)/libfftfault.a
GCC     = /usr/lib/libgcc.a
# uncomment the following three lines for 32-bit
#FFLAGS = -O2 -Bstatic
#FC = g77
# uncomment the following three lines for 64-bit
FFLAGS =  -O2 -m64 -Bstatic
FC = gfortran

sl_stress:		sl_stress.o	
	$(FC)  $(FFLAGS) sl_stress.o\
		$(FFT) $(GMT) $(CDF) -o ../../bin/$(OS)/sl_stress
	rm *.o

