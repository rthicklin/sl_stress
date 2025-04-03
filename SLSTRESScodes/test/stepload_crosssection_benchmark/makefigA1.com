#!/bin/csh
#
# Script to run step load benchmark test of sl_stress program.
# Generates plot similar to figure A1 of Luttrell and Sandwell 2010.
#
date


#
# Run the model for a step water load.
# Create stress component files for each depth.
# Use grdtrack to get profile across each component at each depth.
#

  set H = 50
  set L0 = -120
  set L1 = 0

  set binpath = ../../bin/i386

  #foreach z (0 5 10 15 20 25 30 35 40 45 49.99)
  foreach z (0 2 4 6 8 10 12 14 16 18 20 22 24 26 28 30 32 34 36 38 40 42 44 46 48 49.99)

  ## sl_stress topo.grd H tau L0 L1 time Zobs istr x.grd y.grd z.grd
  $binpath/sl_stress topo.step.1024.grd $H 20 $L0 $L1 9999 -$z 1 grds/temp.Txx.grd grds/temp.Tyy.grd grds/temp.Tzz.grd
  $binpath/sl_stress topo.step.1024.grd $H 20 $L0 $L1 9999 -$z 3 grds/temp.Txy.grd grds/temp.Txz.grd grds/temp.Tyz.grd

  grdtrack xy.dat -Ggrds/temp.Txx.grd -Z >> temp.1
  grdtrack xy.dat -Ggrds/temp.Tyy.grd -Z >> temp.2
  grdtrack xy.dat -Ggrds/temp.Tzz.grd -Z >> temp.3
  grdtrack xy.dat -Ggrds/temp.Txy.grd -Z >> temp.4
  grdtrack xy.dat -Ggrds/temp.Txz.grd -Z >> temp.5
  grdtrack xy.dat -Ggrds/temp.Tyz.grd -Z >> temp.6

  echo "z = $z km"
  end

#
# Divide profiles by 1e6 to get MPa (instead of Pa).
# Reshape profiles into grd cross section, with x and y (depth) in units of km.
#

  #gmtmath temp.1 1e6 DIV = | xyz2grd -Ggrds/Txx.crosssection.grd -I3.7033/5 -R-1896.1/1896.1/-52.5/2.5 -F -ZTLa
  #gmtmath temp.2 1e6 DIV = | xyz2grd -Ggrds/Tyy.crosssection.grd -I3.7033/5 -R-1896.1/1896.1/-52.5/2.5 -F -ZTLa
  #gmtmath temp.3 1e6 DIV = | xyz2grd -Ggrds/Tzz.crosssection.grd -I3.7033/5 -R-1896.1/1896.1/-52.5/2.5 -F -ZTLa
  #gmtmath temp.4 1e6 DIV = | xyz2grd -Ggrds/Txy.crosssection.grd -I3.7033/5 -R-1896.1/1896.1/-52.5/2.5 -F -ZTLa
  #gmtmath temp.5 1e6 DIV = | xyz2grd -Ggrds/Txz.crosssection.grd -I3.7033/5 -R-1896.1/1896.1/-52.5/2.5 -F -ZTLa
  #gmtmath temp.6 1e6 DIV = | xyz2grd -Ggrds/Tyz.crosssection.grd -I3.7033/5 -R-1896.1/1896.1/-52.5/2.5 -F -ZTLa

  gmtmath temp.1 1e6 DIV = | xyz2grd -Ggrds/Txx.crosssection.grd -I3.7033/2 -R-1896.1/1896.1/-51/1 -F -ZTLa
  gmtmath temp.2 1e6 DIV = | xyz2grd -Ggrds/Tyy.crosssection.grd -I3.7033/2 -R-1896.1/1896.1/-51/1 -F -ZTLa
  gmtmath temp.3 1e6 DIV = | xyz2grd -Ggrds/Tzz.crosssection.grd -I3.7033/2 -R-1896.1/1896.1/-51/1 -F -ZTLa
  gmtmath temp.4 1e6 DIV = | xyz2grd -Ggrds/Txy.crosssection.grd -I3.7033/2 -R-1896.1/1896.1/-51/1 -F -ZTLa
  gmtmath temp.5 1e6 DIV = | xyz2grd -Ggrds/Txz.crosssection.grd -I3.7033/2 -R-1896.1/1896.1/-51/1 -F -ZTLa
  gmtmath temp.6 1e6 DIV = | xyz2grd -Ggrds/Tyz.crosssection.grd -I3.7033/2 -R-1896.1/1896.1/-51/1 -F -ZTLa

#
# clean up
#
  rm temp.*
  rm grds/temp.*

date

#
# plot the cross sections using GMT.  Should match the profiles in Fig A1.a,b,c,e of Luttrell and Sandwell 2010.
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
  gmtset HEADER_OFFSET	       = 0.3c
  gmtset LABEL_OFFSET	       = 0.3c

  set R = -400/400/-50/0
  set Scale = 7/2
  set name = stepload_profiles

  makecpt -Cno_green -T-2/2/.05 -D >  Txx.cpt
  makecpt -Cno_green -T-.6/.6/.05 -D >  Tyy.cpt
  makecpt -Cno_green -T-.6/.6/.05 -D >  Tzz.cpt
  makecpt -Cno_green -T-.8/.8/.05 -D >  Txz.cpt

  psbasemap -JX$Scale -R$R -Ba200f100g0/a25f12.5g0:"Txx":Wsen -K -Y18 -X3 > $name.ps
  grdimage grds/Txx.crosssection.grd -CTxx.cpt -J -R -O -K >> $name.ps
  psscale -CTxx.cpt -Al -D12/1.25/8/0.5h -B.5:"MPa": -O -K >> $name.ps

  psbasemap -JX$Scale -R$R -Ba200f100g0/a25f12.5g0:"Tyy":Wsen -O -K -Y-3 >> $name.ps
  grdimage grds/Tyy.crosssection.grd -CTyy.cpt -J -R -O -K >> $name.ps
  psscale -CTyy.cpt -Al -D12/1.25/8/0.5h -B.2:"MPa": -O -K >> $name.ps

  psbasemap -JX$Scale -R$R -Ba200f100g0/a25f12.5g0:"Tzz":Wsen -O -K -Y-3 >> $name.ps
  grdimage grds/Tzz.crosssection.grd -CTzz.cpt -J -R -O -K >> $name.ps
  psscale -CTzz.cpt -Al -D12/1.25/8/0.5h -B.2:"MPa": -O -K >> $name.ps

  psbasemap -JX$Scale -R$R -Ba200f100g0/a25f12.5g0:"Txz":WSen -O -K -Y-3 >> $name.ps
  grdimage grds/Txz.crosssection.grd -CTxz.cpt -J -R -O -K >> $name.ps
  psscale -CTxz.cpt -Al -D12/1.25/8/0.5h -B.2:"MPa": -O -K >> $name.ps

#
# clean up
#
  rm *.cpt

date
open $name.ps


