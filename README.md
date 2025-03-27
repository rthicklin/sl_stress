# sl_stress
sl_stress code to compute displacement and stress from a given water load.

Karen Luttrell
Dept. of Geology and Geophysics
Louisiana State University
E235 Howe-Russell-Kniffen
Baton Rouge, LA 70803
kluttrell@lsu.edu

Latest package with benchmarks on 12/17/2013.
Copyright, Karen M. Luttrell

# REFERENCE: 
The analytic solution to this problem is provided in Appendix A of the following references: Smith, B. and D. Sandwell (2004), A three-dimensional semianalytic viscoelastic model for time-dependent analysis of the earthquake cycle, J. Geophys. Res., 109, B12401, doi:10.1029/2004JB003185.

Surface load specific solution and benchmarks are provided in Appendix A of the following reference: Luttrell, K., and D. Sandwell (2010), Ocean loading effects on stress at near shore plate boundary fault systems, J. Geophys. Res., 115, B08411, doi:10.1029/2009JB006541.

# To install:
1) make sure GMT is installed (this code predates GMT5, but worked with GMT4 libraries)
2) set shell environmental variables GMTHOME and NETCDFHOME to point to gmt/ and netcdf/
   locations on your machine (e.g., /usr/local/netcdf, etc.)
3) build library by typing "make" in lib directory.
4) build binary by typing "make" in src/sl_stress directory.
5) run Cahuilla_test.com script in test/Cahuilla_example directory. (should make a sensibe plot)
6) run makefigA1.com script in test/stepload_crosssection_benchmark directory (should make a sensible plot)
7) If you like, explore the scripts in test/scripts.  These can be used as an example for how one can use the
   sl_stress code to generate stress history due to a time-varying water level.
