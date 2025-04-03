#! /bin/csh -f

#Usage: sl_stress topo.grd H tau L0 L1 time Zobs istr x.grd y.grd z.grd
#
#       topo.grd- topographic grid 
#       H       - depth to bottom of elastic layer (km)
#       tau     - relaxation time (yr) 
#       L0      - sealevel before loading relative to today (m) 
#       L1      - sealevel after loading relative to today (m) 
#       time    - time since loading (yr)
#       Zobs    - observation plane <= 0 (km)
#       istr    - (0)-disp. U,V,W 
#               - (1)-stress Txx,Tyy,Tzz
#               - (2)-stress Tnormal,Tshear,Tcoulomb
#       x,y,z.grd - output files of disp. or stress 

set topo = grds/topo_masked.grd
set L0 = $1
set L1 = $2
set time = $3

#set H = 35
#set Tau = 30
#set Zobs = -7
set H = $4
set Tau = $5
set Zobs = $6

#date
sl_stress $topo $H $Tau $L0 $L1 $time $Zobs 1 grds/tempTxx.grd grds/tempTyy.grd grds/tempTzz.grd
sl_stress $topo $H $Tau $L0 $L1 $time $Zobs 3 grds/tempTxy.grd grds/tempTxz.grd grds/tempTyz.grd
#date

