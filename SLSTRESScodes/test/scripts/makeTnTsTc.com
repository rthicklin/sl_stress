#!/bin/csh
#
#
  
  
#
# strike, dip, and rake (nu) are in Aki and Richards format.
#
  set z = $1
  set yr = $2
  set str = $3
  set dip = $4
  set nu = $5
  set mu = $6
  set DIR = Corrected

  #set z = 5
  #set yr = 10
  #set str = 75
  #set dip = 65
  #set nu = -15
  #set mu = 0.6
  
  set Tn_name = grds/$DIR/TnTsTc/Tn_z$z.yr$yr.s$str.d$dip.grd
  set Ts_name = grds/$DIR/TnTsTc/Ts_z$z.yr$yr.s$str.d$dip.n$nu.grd
  set Tc_name = grds/$DIR/TnTsTc/Tc_z$z.yr$yr.s$str.d$dip.n$nu.m$mu.grd
  
  echo z=$z yr=$yr str=$str dip=$dip nu=$nu mu=$mu
#
# calculate normal and shear stresses
#  
 set txx = grds/$DIR/Tij_$z'km'/Txx_$yr.grd
 set tyy = grds/$DIR/Tij_$z'km'/Tyy_$yr.grd
 set tzz = grds/$DIR/Tij_$z'km'/Tzz_$yr.grd
 set txy = grds/$DIR/Tij_$z'km'/Txy_$yr.grd
 set txz = grds/$DIR/Tij_$z'km'/Txz_$yr.grd
 set tyz = grds/$DIR/Tij_$z'km'/Tyz_$yr.grd
  
#
# in bc, calculate nx,ny,nz & tx,ty,tz
#
  set strike = $str
  set rake = $nu
  
  set pi = `echo "a(1)*4" | bc -l`
  set d2r = `echo "$pi/180" | bc -l`
  
  set nx = `echo " c($strike*$d2r)*s($dip*$d2r)" | bc -l`
  set ny = `echo "-s($strike*$d2r)*s($dip*$d2r)" | bc -l`
  set nz = `echo "c($dip*$d2r)" | bc -l`
  
  set tx = `echo "-s($rake*$d2r)*c($dip*$d2r)*c($strike*$d2r)+s($strike*$d2r)*c($rake*$d2r)" | bc -l`
  set ty = `echo " s($rake*$d2r)*c($dip*$d2r)*s($strike*$d2r)+c($strike*$d2r)*c($rake*$d2r)" | bc -l`
  set tz = `echo " s($rake*$d2r)*s($dip*$d2r)" | bc -l`
  
  #echo $nx $ny $nz
  #echo $tx $ty $tz
 
#
# calculate Tijni
#
 grdmath $txx $nx MUL $txy $ny MUL ADD $txz $nz MUL ADD = temp1.grd
 grdmath $txy $nx MUL $tyy $ny MUL ADD $tyz $nz MUL ADD = temp2.grd
 grdmath $txz $nx MUL $tyz $ny MUL ADD $tzz $nz MUL ADD = temp3.grd
#
# calculate Tn=Tijninj, Ts=Tijnitj, and Tc=mu*Tn+Ts;
# 
 
 grdmath $nx temp1.grd MUL $ny temp2.grd MUL ADD $nz temp3.grd MUL ADD = grds/Tn.grd
 grdmath $tx temp1.grd MUL $ty temp2.grd MUL ADD $tz temp3.grd MUL ADD = grds/Ts.grd
 grdmath grds/Ts.grd $mu grds/Tn.grd MUL ADD = grds/Tc.grd
 
 rm temp1.grd temp2.grd temp3.grd
 
 mv grds/Tn.grd $Tn_name
 mv grds/Ts.grd $Ts_name
 mv grds/Tc.grd $Tc_name
 
 
