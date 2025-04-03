#! /bin/csh -f

  
#Usage: sl_stress topo.grd H tau L0 L1 time Zobs istr x.grd y.grd z.grd [E v]
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
#               - (3)-stress Txy,Txz,Tyz
#       x,y,z.grd - output files of disp. or stress 
#       [E]     - optional Youngs modulus (default 70GPa)
#       [v]     - optional Poissons ratio (default 0.25)
#  

  set binpath = ../../bin/i386
  
  set topo = topo_masked.grd
  set H = 30
  set Tau = 10
  set time = 20
  set Zobs = 0
  set istr = 0

  set L0 = -90
  set L1 = 13

  date
  $binpath/sl_stress $topo $H $Tau $L0 $L1 $time $Zobs $istr x.grd y.grd z.grd
  date

#
# plot these displacement outputs.
#
#
  gmtset PAPER_MEDIA = letter
  gmtset PAGE_ORIENTATION = portrait
  gmtset BASEMAP_TYPE = plain

  gmtset ANNOT_FONT_SIZE_PRIMARY    = 10p
  gmtset ANNOT_FONT_SIZE_SECONDARY  = 10p
  gmtset HEADER_FONT_SIZE           = 10p
  gmtset LABEL_FONT_SIZE            = 10p
  gmtset ANNOT_OFFSET_PRIMARY    = 0.08c
  gmtset ANNOT_OFFSET_SECONDARY  = 0.3c
  gmtset HEADER_OFFSET         = 0.3c
  gmtset LABEL_OFFSET          = 0.3c

  set R = -119/-113/31/35
  set Scale = 7
  set name = Cahuilla_test_figure
  set topo = topo.grd
    grdgradient $topo -Nt.6 -A300 -Gtempgrad.grd

#
# use the premade files for colorpalette
#  
  #makecpt -Crainbow -T-.25/.25/.05 -Z >  UV.cpt
  #makecpt -Crainbow -T-2/2/.05 -Z >  W.cpt


#
# 1) Normal Tc
#
  psbasemap -JM$Scale -R$R -Ba1f.5g0:"E-W displacement":WSen -K -X1.5 -Y21 > $name.ps
  grdimage x.grd -Itempgrad.grd -CUV.cpt -JM -R -O -K >> $name.ps
  pscoast -JM -R$R -Di -Na -W1.9/64/64/64 -O -K >> $name.ps
  psxy shoreline.xy -R$R -JM -W2 -m -O -K >> $name.ps
  psxy SoCal_flts_minusBSZ.xyz -R$R -JM -W1/64/64/64 -m'9999' -O -K >> $name.ps
  psscale -CUV.cpt -D8/3./6/0.3 -B.05:"E-W displacement (m)": -O -I -K >> $name.ps

#
# 2) Dextral Tc
#
  psbasemap -JM$Scale -R$R -Ba1f.5g0:"N-S displacement (V)":WSen -O -K -X0 -Y-8   >> $name.ps
  grdimage y.grd -Itempgrad.grd -CUV.cpt -JM -R -O -K >> $name.ps
  pscoast -JM -R$R -Df -Na -W2/64/64/64 -O -K >> $name.ps
  psxy shoreline.xy -R$R -JM -W2 -m -O -K >> $name.ps
  psxy SoCal_flts_minusBSZ.xyz -R$R -JM -W1/64/64/64 -m'9999' -O -K >> $name.ps
  psscale -CUV.cpt -D8/3./6/0.3 -B.05:"N-S displacement (m)": -O -I -K >> $name.ps

#
# 3) Normal Pp
#
  psbasemap -JM$Scale -R$R -Ba1f.5g0:"vertical displacement (W)":WSen -O -K -X0 -Y-8 >> $name.ps
  grdimage z.grd -Itempgrad.grd -CW.cpt -JM -R -O -K >> $name.ps
  pscoast -JM -R$R -Df -Na -W2/64/64/64 -O -K >> $name.ps
  psxy shoreline.xy -R$R -JM -W2 -m -O -K >> $name.ps
  psxy SoCal_flts_minusBSZ.xyz -R$R -JM -W1/64/64/64 -m'9999' -O -K >> $name.ps
  psscale -CW.cpt -D8/3./6/0.3 -B.4:"vertical displacement (m)": -O -I -K >> $name.ps

#
# clean up
#
  rm tempgrad.grd 

date
open $name.ps
