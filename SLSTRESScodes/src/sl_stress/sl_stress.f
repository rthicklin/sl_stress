c
      program sl_stress
c
c***********************************************************************
c  REFERENCE: 
c  The analytic solution to this problem is provided in Appendix A
c  of the following reference:
c  Smith, B. and D. Sandwell (2004), A three-dimensional semianalytic 
c    viscoelastic model for time-dependent analysis of the earthquake cycle,
c    J. Geophys. Res., 109, B12401, doi:10.1029/2004JB003185.
c
c  Surface load specific solution and benchmarks are provided in Appendix A
c  of the following reference:
c  Luttrell, K., and D. Sandwell (2010), Ocean loading effects on stress at near
c    shore plate boundary fault systems, J. Geophys. Res., 115, B08411,
c    doi:10.1029/2009JB006541.
c
c
c***********************************************************************
c
c  USAGE:
c  Program to calculate a grid of 3-D displacement or stress due to
c  a surface load on an elastic plate over a visco-elastic halfspace.
c  The program reads and writes GMT grd files so you must have the
c  netcdf and gmt libraries installed on your computer.
c
c  EXAMPLE:
c  Calculate the displacement caused by a change in
c  sea level from -100 m to 0 m that occurred 1000 years ago.  The
c  elastic plate has a thickness of 20 km and the relaxation time
c  of the viscoelastic half space is 600 yr.
c  The three components of surface displacement are stored
c  in three grd-files for use with GMT software.
c
c******************************************************************
c  sl_stress topo.grd 20 600. -100 0 1000. 0. 0 x.grd y.grd z.grd
c******************************************************************
c
c*****************   main program   ************************
c
      implicit real*8(a,b,d-h,o-z)
      implicit complex*16 (c)
c
c  User - change the grid parameters on the lines below to meet your needs
c       - change model parameters after variable declaration below.
c*******************************************************************
      parameter(ni=1024,nj=1024,nwork=32768,nj2=nj/2+1,ni2=ni/2+1)
c      parameter(g=9.8,rhow=1000.,rhom=3300.,young=7.e10)
c      parameter(fr=.6,psi=135.)
c
c  parameter   description
c  ni          # of rows in topography grid
c  nj          # of columns in topography grid
c  g           acceleration of gravity (m/s**2)
c  rhow        seawater density (kg/m**3)
c  rhom        mantle density (kg/m**3)
c  young       Young's Modulus (Pa)
c  fr          coefficient of friction on test fault for Coulomb Stress
c  psi         fault orientation CCW from east (deg)
c
c*******************************************************************
      real*8 kx,ky
      real*8 rln0,rlt0,dlt,dln,rland,rdum
      character*80 fxdisp,fydisp,fzdisp
      character*80 ch,cz,cstr,ctopo,ctsl,title
      character*80 cL0,cL1,ctau,cyoung,cpois
c
      common/plate/rlam1,rlam2,rmu1,rmu2,rho,rc,rd,alph,pi
c
      real*4 fz(nj,ni),topo(nj,ni)
      real*4 u(nj,ni),v(nj,ni),w(nj,ni)
      real*4 xwind(nj),ywind(ni)
      complex*8 fkz(nj2,ni)
      complex*8 uk(nj2,ni),vk(nj2,ni),wk(nj2,ni)
      dimension n(2)
      complex*8 work(nwork)
      equivalence (fz(1,1),fkz(1,1))
      equivalence (u(1,1),uk(1,1))
      equivalence (v(1,1),vk(1,1))
      equivalence (w(1,1),wk(1,1))
c
c*********User: set these default model parameters************

      g=9.8
      rhow=1000.
      rhom=3300.
      young=7.e10
      pois=0.25
      
      fr=0.6
      psi=135.
      
c*************************************************************
c
      pi=acos(-1.)
      rho=rhom
c
c  zero the arrays fx,fy,fz
c
      do 30 i=1,ni
      do 30 j=1,nj
      fz(j,i)=0.
  30  continue
c
c  set the dimensions for fourt
c
      n(1)=nj
      n(2)=ni
c
c   get values from command line
c
      narg = iargc()
      if(narg.ne.11.and.narg.ne.13) then
       write(*,'(a)')'  '
       write(*,'(a)')
     & 'Usage: sl_stress topo.grd H tau L0 L1 time Zobs istr x.grd y.grd 
     & z.grd [E v]'
       write(*,'(a)')
       write(*,'(a)')
     & '       topo.grd- topographic grid '
       write(*,'(a)')
     & '       H       - depth to bottom of elastic layer (km)'
       write(*,'(a)')
     & '       tau     - relaxation time (yr) '
       write(*,'(a)')
     & '       L0      - sealevel before loading relative to today (m) '
       write(*,'(a)')
     & '       L1      - sealevel after loading relative to today (m) '
       write(*,'(a)')
     & '       time    - time since loading (yr)'
       write(*,'(a)')
     & '       Zobs    - observation plane <= 0 (km)'
       write(*,'(a)')
     & '       istr    - (0)-disp. U,V,W '
       write(*,'(a)')
     & '	       - (1)-stress Txx,Tyy,Tzz'
       write(*,'(a)')
     & '               - (2)-stress Tnormal,Tshear,Tcoulomb'
       write(*,'(a)')
     & '               - (3)-stress Txy,Txz,Tyz'
       write(*,'(a)')
     & '       x,y,z.grd - output files of disp. or stress '
       write(*,'(a)')
     & '       [E]     - optional Youngs modulus (default 70GPa)'
       write(*,'(a)')
     & '       [v]     - optional Poissons ratio (default 0.25)'
       write(*,'(a)')'  '
       stop
      else 
        call getarg(1,ctopo)
c        nc=index(ctopo,' ')
c        ctopo(nc:nc)='\0'
        call getarg(2,ch)
        call getarg(3,ctau)
        call getarg(4,cL0)
        call getarg(5,cL1)
        call getarg(6,ctsl)
        call getarg(7,cz)
        call getarg(8,cstr)
        read(ch,*)thk
        read(ctau,*)taum
        read(cz,*)zobs
        read(cL0,*)rL0
        read(cL1,*)rL1
        read(ctsl,*)tsl
        read(cstr,*)istr
        call getarg(9,fxdisp)
c        nc=index(fxdisp,' ')
c        fxdisp(nc:nc)='\0'
        call getarg(10,fydisp)
c        nc=index(fydisp,' ')
c        fydisp(nc:nc)='\0'
        call getarg(11,fzdisp)
c        nc=index(fzdisp,' ')
c        fzdisp(nc:nc)='\0'
        
	rnu=pois
	if(narg.eq.13) then
          call getarg(12,cyoung)
          call getarg(13,cpois)
          read(cyoung,*)young
          read(cpois,*)rnu
        endif     
      endif
c
c  calculate the shear and bulk modulus
c
c      rnu=0.25
      
      rlam1=young*rnu/(1+rnu)/(1-2*rnu)
      rmu1=young/2/(1+rnu)
      bulk=rlam1+2*rmu1/3.
      H=abs(thk)
c
c  compute other elastic constants needed for the loading solution
c
      alph=(rlam1+rmu1)/(rlam1+2*rmu1)
      rc=alph/(4.*rmu1)
      rd=(rlam1+3*rmu1)/(rlam1+rmu1)
c
c  convert relaxation time and the time since loading
c  to seconds, and compute shear modulus ratio (rmu2/rmu1) 
c  from time since loading
c
      spmyr=365.25*24.*3600.
      tsl=tsl*spmyr
      taum=taum*spmyr
      shr=exp(-tsl/taum)/(2-exp(-tsl/taum))
c
c  allow rmu2 to vary but don't let the bulk
c  modulus change
c
      rmu2=rmu1*shr
      rlam2=bulk-2.*rmu2/3.
c
c   read the grd file
c
      call readgrd(topo,nj1,ni1,rlt0,rln0,
     +            dlt,dln,rdum,title,trim(ctopo)//char(0))
      if(ni1.ne.ni.or.nj1.ne.nj) then
        print *, ni1, ni, nj1, nj,rlt0,rln0,dlt,dln,rdum
        write(*,'(a)')' recompile program to match topo size'
        stop
      endif
c
c  compute the windows
c
      nsigy=ni/8
      do 70 i=1,ni
      if(i.lt.nsigy) then
       ywind(i)=0.5*(1.-cos(pi*(i-1)/nsigy))
      else if(i.gt.(ni-nsigy)) then
       ywind(i)=0.5*(1.-cos(pi*(ni-i)/nsigy))
      else
       ywind(i)=1.
      endif
   70 continue
      nsigx=nj/8
      do 80 j=1,nj
      if(j.lt.nsigx) then
       xwind(j)=0.5*(1.-cos(pi*(j-1)/nsigx))
      else if(j.gt.(nj-nsigx)) then
       xwind(j)=0.5*(1.-cos(pi*(nj-j)/nsigx))
      else
       xwind(j)=1.
      endif
   80 continue
c
c  generate ocean load and apply window
c  the load is multimpled by 1000 and divided by the shear modulus
c
      do 120 i=1,ni
      do 120 j=1,nj

      if(topo(j,i).lt.rL0.and.topo(j,i).lt.rL1) rload = rL1-rL0
      if(topo(j,i).gt.rL0.and.topo(j,i).gt.rL1) rload = 0.
      if(topo(j,i).ge.rL0.and.topo(j,i).le.rL1) rload = rL1-topo(j,i)
      if(topo(j,i).le.rL0.and.topo(j,i).ge.rL1) rload = topo(j,i)-rL0

      fz(j,i)=1000*rload*rhow*g/rmu1
      fz(j,i)=fz(j,i)*xwind(j)*ywind(i)/(ni*nj)
  120 continue
c              
c  compute the height and width of the area in km
c
      rlat2=abs(rlt0+ni*dlt/2)*pi/180.
      xscl=cos(rlat2)
      dy=111.*dlt
      dx=xscl*111.*dln
      width=nj*dx
      height=abs(ni*dy)
c
c  take the fourier transform of the force
c
      call fourt(fz,n,2,-1,0,work,nwork)
c
      do 255 i=1,ni
      ky=-(i-1)/height
      if(i.ge.ni2) ky= (ni-i+1)/height
      do 255 j=1,nj2
      kx=(j-1)/width
c
c  do the layered boussinesq problem
c
      call boussinesql(kx,ky,zobs,H,cub,cvb,cwb,cdudz,cdvdz,cdwdz)
c
c  now either output displacement or stress
c
      uk(j,i)=rmu1*(fkz(j,i)*cub)
      vk(j,i)=rmu1*(fkz(j,i)*cvb)
      wk(j,i)=rmu1*(fkz(j,i)*cwb)
c
c  now compute the stress if requested. 
c
      if(istr.ge.1) then
        cux=cmplx(0.,2.*pi*kx)*uk(j,i)
        cvy=cmplx(0.,2.*pi*ky)*vk(j,i)
        cuy=cmplx(0.,2.*pi*ky)*uk(j,i)
        cvx=cmplx(0.,2.*pi*kx)*vk(j,i)
        cwx=cmplx(0.,2.*pi*kx)*wk(j,i)
        cwy=cmplx(0.,2.*pi*ky)*wk(j,i)
        cuz=rmu1*(fkz(j,i)*cdudz)
        cvz=rmu1*(fkz(j,i)*cdvdz)
        cwz=rmu1*(fkz(j,i)*cdwdz)
c
c  assume units are km so divide by 1000 to get MPa
c
        uk(j,i)=.001*((rlam1+2*rmu1)*cux+rlam1*(cvy+cwz))
        vk(j,i)=.001*((rlam1+2*rmu1)*cvy+rlam1*(cux+cwz))
        wk(j,i)=.001*(rmu1*(cuy+cvx))
	if(istr.eq.1) wk(j,i)=.001*((rlam1+2*rmu1)*cwz+rlam1*(cux+cvy))
	if(istr.eq.3) then
          uk(j,i)=.001*(rmu1*(cuy+cvx))
          vk(j,i)=.001*(rmu1*(cuz+cwx))
          wk(j,i)=.001*(rmu1*(cvz+cwy))
	endif
      endif
 255  continue
c
c  do the inverse fft's
c
      call fourt(u,n,2,1,-1,work,nwork)
      call fourt(v,n,2,1,-1,work,nwork)
      call fourt(w,n,2,1,-1,work,nwork)
c
c  compute the coulomb stress if requested
c
      if(istr.eq.2) then
        do 270 i=1,ni
        do 270 j=1,nj
        txx=u(j,i)
        tyy=v(j,i)
        txy=w(j,i)
        call coulomb(txx,tyy,txy,fr,psi,rnorm,rshr,rcoul)
        u(j,i)=rnorm
        v(j,i)=rshr
        w(j,i)=rcoul
 270  continue
      endif
c
c  write 3 grd files some parameters must be real*8
c
      rland=9998.
      rdum=9999.
      if(istr.ge.1) then
       rland=9998.d0*rmu1
       rdum=9999.d0*rmu1
      endif
      call writegrd(u,nj,ni,rlt0,rln0,dlt,dln,rland,rdum,
     +              trim(fxdisp)//char(0),trim(fxdisp)//char(0))
      call writegrd(v,nj,ni,rlt0,rln0,dlt,dln,rland,rdum,
     +              trim(fydisp)//char(0),trim(fydisp)//char(0))
      call writegrd(w,nj,ni,rlt0,rln0,dlt,dln,rland,rdum,
     +              trim(fzdisp)//char(0),trim(fzdisp)//char(0))
      stop
      end
