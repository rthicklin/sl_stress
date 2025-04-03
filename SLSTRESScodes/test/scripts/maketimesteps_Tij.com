#! /bin/csh -f

#
# taum, H, and zobs are set within makeTij.com
#

set H = 35
set tau = 30
set zobs = -9

date

set L0 = -90
set yr = 1
while ($yr <= 20)
   
   
   cp grds/zero.grd grds/Txx.grd ; cp grds/zero.grd grds/Tyy.grd ; cp grds/zero.grd grds/Tzz.grd
   cp grds/zero.grd grds/Txy.grd ; cp grds/zero.grd grds/Txz.grd ; cp grds/zero.grd grds/Tyz.grd
   
   @ t = $yr - 1
   set c = 1
   while ($t >= 0)
     set L1 = `head -$c waterlevel.dat | tail -1 | awk '{print $2}'`
   
     echo '   ' $yr makeTij.com $L0 $L1 $t
     makeTij.com $L0 $L1 $t $H $tau $zobs

     grdmath grds/Txx.grd grds/tempTxx.grd ADD = grds/temp2Txx.grd
     grdmath grds/Tyy.grd grds/tempTyy.grd ADD = grds/temp2Tyy.grd
     grdmath grds/Tzz.grd grds/tempTzz.grd ADD = grds/temp2Tzz.grd
     grdmath grds/Txy.grd grds/tempTxy.grd ADD = grds/temp2Txy.grd
     grdmath grds/Txz.grd grds/tempTxz.grd ADD = grds/temp2Txz.grd
     grdmath grds/Tyz.grd grds/tempTyz.grd ADD = grds/temp2Tyz.grd
     
     mv grds/temp2Txx.grd grds/Txx.grd
     mv grds/temp2Tyy.grd grds/Tyy.grd
     mv grds/temp2Tzz.grd grds/Tzz.grd
     mv grds/temp2Txy.grd grds/Txy.grd
     mv grds/temp2Txz.grd grds/Txz.grd
     mv grds/temp2Tyz.grd grds/Tyz.grd
   
     set L0 = $L1
     @ c = $c + 1
     @ t = $t - 1
   end
   
     mv grds/Txx.grd grds/timesteps/Txx_$yr.grd
     mv grds/Tyy.grd grds/timesteps/Tyy_$yr.grd
     mv grds/Tzz.grd grds/timesteps/Tzz_$yr.grd
     mv grds/Txy.grd grds/timesteps/Txy_$yr.grd
     mv grds/Txz.grd grds/timesteps/Txz_$yr.grd
     mv grds/Tyz.grd grds/timesteps/Tyz_$yr.grd
   
   
   set L0 = -90
   @ yr = ($yr + 1)
   date
end

rm grds/temp*.grd
