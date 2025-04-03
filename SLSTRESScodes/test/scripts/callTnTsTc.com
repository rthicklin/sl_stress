#!/bin/csh
#
#
    
#
# Aki and Richards convention:
# strike=EofN with plane dipping to the right [0,360]. dip=ºfromhorizontal [0,90]. nu=slipdirection [-180,180]
#
  date


#
# San Andreas Orientation
#  
  set z = 7
  set mu = 0.6

  set str = 325
  set dip = 90
  set nu = 180

  #set zset = "3 5 7 9"
  set zset = "7"
  set muset = "0.2 0.4 0.6"

foreach z ($zset)
foreach mu ($muset)
  set yr = 21
  while ($yr <= 90)
    makeTnTsTc.com $z $yr $str $dip $nu $mu
  @ yr = ($yr + 1)
  end 
end
end
date

#
# H7 Orientation
#  
  set z = 7
  set mu = 0.6

  set str = 15
  set dip = 65
  set nu = -90

foreach z ($zset)
foreach mu ($muset)
  set yr = 21
  while ($yr <= 90)
    makeTnTsTc.com $z $yr $str $dip $nu $mu
  @ yr = ($yr + 1)
  end 
end
end
date

