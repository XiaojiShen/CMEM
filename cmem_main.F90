! Copyright 2006-2014 ECMWF.
!
! This software is licensed under the terms of the Apache Licence Version 2.0
! which can be obtained at http://www.apache.org/licenses/LICENSE-2.0.
!
! In applying this licence, ECMWF does not waive the privileges and immunities granted to it by
! virtue of its status as an intergovernmental organisation nor does it submit to any jurisdiction.
!
PROGRAM CMEM_MAIN
!
!
!
!       PURPOSE.
!       -------
!     CMEM Main program
!     CMEM: Copyright © ECMWF
!     Compute Low frequency passive microwave emission of the surface, 
!     from 1.4 to 20 GHz.
!
!       INTERFACE :
!       ---------
!
!       EXTERNALS :
!       ---------
!         RD_*    : Read input data
!         CMEM_*  : module of emission model
!         IO_* : read grib and netcdf data
!         WR*  : write output data
!
!       REFERENCES
!      ------------
!      Drusch, M., T. Holmes, P. de Rosnay and G. Balsamo, 2009: 
!      Comparing ERA-40 based L-band brightness temperatures with Skylab observations: 
!      A calibration / validation study using the
!      Community Microwave Emission Model, J. Hydromet., Vol 10, DOI: 10.1175/2008JHM964.1, 2009 
!
!      de Rosnay P., M. Drusch, A. Boone, G. Balsamo, 
!      B. Decharme, P. Harris, Y. Kerr, T. Pellarin, J.
!      Polcher and J.-P. Wigneron, 
!      "The AMMA Land Surface Model Intercomparison 
!      Experiment coupled to the Community Microwave Emission Model: ALMIP-MEM", 
!      J. Geophys. Res., Vol 114, doi:10.1029/2008JD010724, 2009  
!
!      AUTHORS.
!      --------
!     Thomas Holmes   ECMWF     v0 6/09/06
!     Patricia de Rosnay ECMWF: v1.1 Dec  2007 (Grib and ASCII options)      
!                               v1.2 February 2008 (Netcdf option added)
!                               v1.3 April 2008
!                               v1.4 November 2008 
!                                    December 2008 (Grib API option added)
!                               v2.0 January 2009  (GRIB API version released)
!                               v2.1 March 2009  (gfortran and IFC compatibility)
!                               v3.0 November 2009  (IFS interface structure, SSS(N))
!                               v4.0 February 2012  HTessel option, bug fixes in TEFF, Liebe and VEGTABLE
!                               v4.1 May 2012  Improved Wilheit multilayer (flexible LSM and MW layers)
!                               v5.1 February 2014 fixed bugs, code cleaning and Apache license
!
!------------------------------------------------------------------------------
!
USE PARKIND1, ONLY : JPIM, JPRM
USE YOMLUN, ONLY : NULOUT, NULTMP
USE YOMCMEMPAR
USE YOMCMEMFIELDS
USE YOMCMEMSOIL
USE YOMCMEMVEG, ONLY : wc_veg, tb_veg, w_eff, bj, tauN, & 
                      & tb_veg, tau_veg, t_veg, a_geo, a_geoL, a_geoH,tth,ttv
USE YOMCMEMATM, ONLY : tau_atm, tb_au, tb_ad, tb_toa, tb_tov,fZ,tair 
! 
IMPLICIT NONE
!
INTEGER(KIND=JPIM) :: JJPOL 
REAL(KIND = JPRM) :: RSN(2), ESN(2)
REAL(KIND = JPRM) :: tfrac(JPCMEMTILE)
!
!
! 1.0 Model SETUP
! ------------------------------------
!
CALL CMEM_SETUP 
!
!
! 1. Get information on the input files and allocate variables accordingly
!------------------------------------------------------------------------------
!  
! Read input file and get information on grid size N 
!
!
SELECT CASE ( CFINOUT )
!
!  CASE ( 'gribapi' ) !gribapicase
!!
!   CALL RDCMEMGRIBAPIINFO !gribapicase
!
  CASE ( 'ascii' )
!
  CALL RDCMEMASCIIINFO
!
!  CASE ( 'netcdf' ) !netcdfcase
!!
!  CALL RDCMEMNETCDFINFO !netcdfcase
!
!  CASE ( 'ifs' )
!!  
!  N = 1
!
END SELECT
!
!
!
! 1.2 Allocate variables according to the size of input 
!
ALLOCATE (ftau_atm(N))
ALLOCATE (ftau_veg(N,2))
ALLOCATE (ftb_au(N))
ALLOCATE (ftb_ad(N))
ALLOCATE (ftair(N))
ALLOCATE (fsnowd(N))          
ALLOCATE (frsnow(N))  
ALLOCATE (fwater(N))
ALLOCATE (mask(N))
ALLOCATE (fTVL(N))
ALLOCATE (fTVH(N))
ALLOCATE (fs_laiL(N))
ALLOCATE (ftfrac(N,JPCMEMTILE))
ALLOCATE (ftskin(N))
ALLOCATE (ftl_lsm(N,nlay_soil_ls))
ALLOCATE (fwc_lsm(N,nlay_soil_ls))
ALLOCATE (fsand(N))
ALLOCATE (fclay(N))
ALLOCATE (frho_b(N))
ALLOCATE (fp(N))
ALLOCATE (fWP(N))
ALLOCATE (falpha(N))
ALLOCATE (fsal_wat(N))
ALLOCATE (fh(N))
ALLOCATE (ftveg(N))
ALLOCATE (fwc_veg(N,2))
ALLOCATE (fb(N,2))
ALLOCATE (ftauN(N,2))
ALLOCATE (fw_effL(N,2))
ALLOCATE (fw_effH(N,2))
ALLOCATE (tsoil(nlay_soil_mw))  
ALLOCATE (fNrh_L(N))
ALLOCATE (fNrh_H(N))
ALLOCATE (fNrv_L(N))
ALLOCATE (fNrv_H(N))
ALLOCATE(fhrmodel(N,2))
ALLOCATE (ftth(N,2))
ALLOCATE (fttv(N,2))
ALLOCATE (fZ(N))
ALLOCATE (sal_sea(N))
!
!
SELECT CASE (CFINOUT)
   CASE ('ascii')
   ALLOCATE (ndate(N))
   ALLOCATE (ntime(N))
   ALLOCATE (nbpt(N))
   ALLOCATE (doy(N))
END SELECT
!
!  allocate output
!  ----------------
!
ALLOCATE ( ftb_soil(N,2) )
ALLOCATE ( ftb_toa(N,2) )
ALLOCATE ( fsurf_emis(N,2) )
ALLOCATE ( fteffC(N,3) )  
!
!
! 2. Read input data
!      ---------------
!
SELECT CASE (CFINOUT)
!
!  CASE ('gribapi') !gribapicase
!!
!   CALL RDCMEMGRIBAPI !gribapicase
!
  CASE ('ascii')
!  
   CALL RDCMEMASCII
!
!  CASE ('netcdf') !netcdfcase
!!
!   CALL RDCMEMNETCDF !netcdfcase
!
!  CASE ('ifs')
!!
!   CALL RDCMEMIFS
!
END SELECT
!
!
WRITE(NULOUT,*) 'Read input files done'
!
! 2.1 Compute atmospheric and vegetation optical depth,  and soil roughness 
!
CALL CMEM_INIT
! 
!
! 2.0 deallocate variables that are not useful anymore
!
DEALLOCATE (fwater) ! read in RD_frac used in RD_soil
DEALLOCATE (fTVL)   ! read in RD_frac used in RD_veg 
DEALLOCATE (fTVH)   ! read in RD_frac used in RD_veg
DEALLOCATE (fs_laiL) ! read in RD_frac used in RD_veg
!
DEALLOCATE (fZ)
!
!
!
IF (LGPRINT) WRITE(NULOUT,*) 'CMEM_main, end of 1.2'
!
!
! 3. Compute toa brightness temperatures
!    -----------------------------------
!
WRITE(NULOUT,*) 'CMEM_main, compute TB field'
!
!

FIELD: DO JJ = 1, N 
!
! 3.1 Initialize
!---------------
!
tb_soil(:) = (/0.,0./)
tb_veg(:) = (/0.,0./)
tb_toa(:) = (/0.,0./)
fsurf_emis(JJ,:) = (/0.,0./) 
ftb_soil(JJ,:) = (/0.,0./) 
ftau_veg(JJ,:) = (/0.,0./) 
!  
SELECT CASE (MASK(JJ))  
!
  CASE ( 0_JPIM )    ! points on which TB is not computed (merge MASK_AUTO and MASK_OCEAN)
!
    CYCLE
!
  CASE ( 1_JPIM )    ! points on which TB is computed
!
! Cell values
  tfrac(:) = (ftfrac(JJ,:))
  tau_atm = ftau_atm(JJ) / costheta
  tb_au = ftb_au(JJ)
  tb_ad = ftb_ad(JJ)
  IF (LGPRINT)  WRITE(NULOUT,*) '--- TBSKY up:' ,tb_au
  IF (LGPRINT)  WRITE(NULOUT,*) '--- TBSKY down:' ,tb_ad
  t_veg = ftveg(JJ)
  tair = ftair(JJ)
!
!
  DO JCMEMTILE = 1, JPCMEMTILE ! 1-7
!
  IF (LGPRINT) WRITE(NULOUT,*) '--- Mean TEFF a',fteffC(JJ,:)
    IF (ftfrac(JJ,JCMEMTILE) == 0.)   CYCLE  
!
IF (LGPRINT) WRITE(NULOUT,*) '----------- Tile',JCMEMTILE
!
!
! 3.2 Compute surface emissivity    
!
    SELECT CASE (JCMEMTILE)  
      CASE ( 1,2 )  ! bare soil and that with snow
        Nrh = fNrh_L(JJ)
        Nrv = fNrv_L(JJ)
        hrmodel = fhrmodel(JJ,1) ! Hr for low vegetation
        tsoildeep = ftl_lsm(JJ,nlay_soil_ls) ! soil temperature
        CALL CMEM_SOIL
        IF (LGPRINT) WRITE(NULOUT,*) '--- Mean TEFF bf',&
          & ftfrac(JJ,JCMEMTILE),fteffC(JJ,1),t_eff(1),fteffC(JJ,2),t_eff(2),&
          & fteffC(JJ,3),t_eff(3)
        fteffC(JJ,:) = fteffC(JJ,:) + ftfrac(JJ,JCMEMTILE) * t_eff(:)
        IF (LGPRINT) WRITE(NULOUT,*) '--- Mean TEFF b',fteffC(JJ,:)
      CASE ( 6 ) ! high vegetation with snow
        Nrh = fNrh_H(JJ)
        Nrv = fNrv_H(JJ)
        hrmodel = fhrmodel(JJ,2) ! Hr for high vegetation
        tsoildeep = ftl_lsm(JJ,1) ! soil temperature, why surface temperature ?
        CALL CMEM_SOIL
        IF (LGPRINT) WRITE(NULOUT,*) '--- Mean TEFF bf',&
          & ftfrac(JJ,JCMEMTILE),fteffC(JJ,1),t_eff(1),fteffC(JJ,2),t_eff(2),&
          & fteffC(JJ,3),t_eff(3)
        fteffC(JJ,:) = fteffC(JJ,:) + ftfrac(JJ,JCMEMTILE) * t_eff(:)
        IF (LGPRINT) WRITE(NULOUT,*) '--- Mean TEFF c',fteffC(JJ,:)
      CASE (  3, 4 )
        Nrh = fNrh_L(JJ)
        Nrv = fNrv_L(JJ)
        hrmodel = fhrmodel(JJ,1)
        tsoildeep = ftl_lsm(JJ,nlay_soil_ls)
        CALL CMEM_SOIL
        IF (LGPRINT) WRITE(NULOUT,*) '--- Mean TEFF bf',&
          & ftfrac(JJ,JCMEMTILE),fteffC(JJ,1),t_eff(1),fteffC(JJ,2),t_eff(2),&
          & fteffC(JJ,3),t_eff(3)
        fteffC(JJ,:) = fteffC(JJ,:) + ftfrac(JJ,JCMEMTILE) * t_eff(:)
        IF (LGPRINT) WRITE(NULOUT,*) '--- Mean TEFF d',fteffC(JJ,:)
      CASE ( 5 )
        Nrh = fNrh_H(JJ)
        Nrv = fNrv_H(JJ)
        hrmodel = fhrmodel(JJ,2)
        tsoildeep = ftl_lsm(JJ,nlay_soil_ls)
        CALL CMEM_SOIL
        IF (LGPRINT) WRITE(NULOUT,*) '--- Mean TEFF bf',&
          & ftfrac(JJ,JCMEMTILE),fteffC(JJ,1),t_eff(1),fteffC(JJ,2),t_eff(2),&
          & fteffC(JJ,3),t_eff(3)
        fteffC(JJ,:) = fteffC(JJ,:) + ftfrac(JJ,JCMEMTILE) * t_eff(:)
        IF (LGPRINT) WRITE(NULOUT,*) '--- Mean TEFF e',fteffC(JJ,:)
      CASE ( 7 )
        Nrh = 0.0_JPRM
        Nrv = 0.0_JPRM
        hrmodel = 0.0_JPRM
        tsoildeep = ftl_lsm(JJ,nlay_soil_ls)
        CALL CMEM_SOIL
        IF (LGPRINT) WRITE(NULOUT,*) '--- Mean TEFF bf',&
          & ftfrac(JJ,JCMEMTILE),fteffC(JJ,1),t_eff(1),fteffC(JJ,2),t_eff(2),&
          & fteffC(JJ,3),t_eff(3)
        !fteffC(JJ,1) = fteffC(JJ,1) + ftfrac(JJ,JCMEMTILE) * t_eff(1)
        fteffC(JJ,2) = fteffC(JJ,2) + ftfrac(JJ,JCMEMTILE) * t_eff(2)
        fteffC(JJ,3) = fteffC(JJ,3) + ftfrac(JJ,JCMEMTILE) * t_eff(3)
        IF (LGPRINT) WRITE(NULOUT,*) '--- Mean TEFF f',fteffC(JJ,:)
    END SELECT
!          
! 3.3 Compute vegetation emissivity if present          
!
!
    SELECT CASE (JCMEMTILE)  
      CASE ( 3, 4 )  ! Low vegetation
        w_eff(:) = fw_effL(JJ,:) 
        a_geo = a_geoL 
        wc_veg =  fwc_veg(JJ,1)
        bj =  fb(JJ,1)
        tauN = ftauN(JJ,1)
        tth = ftth(JJ,1)
        ttv = fttv(JJ,1)
        IF (tb_veg(1) == 0.)  CALL CMEM_VEG   
     CASE ( 5 )  ! High vegetation
        w_eff(:) = fw_effH(JJ,:)
        a_geo = a_geoH 
        wc_veg = fwc_veg(JJ,2)
        bj =  fb(JJ,2)
        tauN = ftauN(JJ,2)
        tth = ftth(JJ,2)
        ttv = fttv(JJ,2)
        CALL CMEM_VEG         
     CASE ( 1, 2, 6, 7 ) 
        ! high veg (case 6) will be accounted for on the top of snow in 3.6
        ! so, for now do not account for high veg vegetation
        tau_veg(:) = (/0.,0./)
        tb_veg(:) = (/0.,0./)
    END SELECT     
!
!
! 3.4 Compute top-of-vegetation brightness temperature
!
    CALL CMEM_RTM
!     
!  3.5 Add snow layer: tb_tov-->tb top-of-snow
!
    SELECT CASE (JCMEMTILE)  
      CASE ( 2_JPIM, 4_JPIM, 6_JPIM )
        XMV = 0.1 ! Snow Moisture, should be from data field
        DO JJPOL = 1,2    ! h- and v-polarization
          RSN(JJPOL)=1._JPRM  - tb_tov(JJPOL) / ftl_lsm(JJ,1)
        ENDDO
        CALL CMEM_SNOW(RSN,frsnow(JJ)/1000.,fsnowd(JJ),ESN)
    END SELECT    
!    
!
! 3.6 Add vegetation layer for High vegetation over snow
!
    SELECT CASE (JCMEMTILE)  
      CASE ( 6_JPIM )  ! High vegetation, snow
        ! soil
        DO JJPOL = 1,2    ! h- and v-polarization
          r_r(JJPOL)=1. - ESN(JJPOL)
        ENDDO
        tb_soil = tb_tov
        ! vegetation
        w_eff(:) = fw_effH(JJ,:) 
        a_geo = a_geoH 
        wc_veg = fwc_veg(JJ,2)
        bj =  fb(JJ,2)
        CALL CMEM_VEG   
        ! Tb top-of-vegetation
        CALL CMEM_RTM
    END SELECT  
!           
! 3.7 Compute contribution to top-of-atmosphere brightness temperature
!
     tb_toa(:) = tb_toa(:) + ftfrac(JJ,JCMEMTILE) * tb_tov(:)
     fsurf_emis(JJ,:) = fsurf_emis(JJ,:) + ftfrac(JJ,JCMEMTILE) * surf_emis(:)
     ftb_soil(JJ,:) = ftb_soil(JJ,:) + ftfrac(JJ,JCMEMTILE) * tb_soil(:)
!    Diagnostic Tau_veg
     ftau_veg(JJ,:) = ftau_veg(JJ,:) + ftfrac(JJ,JCMEMTILE) * tau_veg(:)   
!    Diagnostic mean TEFF
     IF (LGPRINT) WRITE(NULOUT,*) 'end of cmem tile loop',JCMEMTILE
     IF (LGPRINT) WRITE(NULOUT,*) '                 TB TOV',tb_tov(:)
     IF (LGPRINT) WRITE(NULOUT,*) '                 tb_soil',tb_soil(:)
     
!
  ENDDO ! end JCMEMTILE
!
!
!   3.7 Top-of-Atmosphere brightness temperature
!
  IF (LGPRINT) WRITE(NULOUT,*) '--- TB no atm:',tb_toa(:)
  ftb_toa(JJ,:) = tb_toa(:) * exp(-tau_atm) + ftb_au(JJ)   
  IF (LGPRINT) WRITE(NULOUT,*) '--- TBTOA:',ftb_toa(JJ,:)
!
!
END SELECT  ! end of mask selection
!
ENDDO FIELD
!
!
! 4. Write outputs 
!-----------------
!
WRITE(NULOUT,*) 'CMEM_main, write output'
!

SELECT CASE (CFINOUT)
!
!  CASE ('gribapi') !gribapicase
!!
!     CALL WRCMEMGRIBAPI !gribapicase
!
  CASE ('ascii')
!
    CALL WRCMEMASCII
!
!  CASE ('netcdf') !netcdfcase
!!
!    CALL WRCMEMNETCDF !netcdfcase
!
!  CASE ('ifs')
!!
!    CALL WRCMEMIFS
!
END SELECT
!
!
! 5 Clean up
!   --------
!
DEALLOCATE ( fteffC )  
!
DEALLOCATE (ftb_soil)
DEALLOCATE (fsurf_emis)
!
DEALLOCATE (ftveg)
DEALLOCATE (ftskin)
DEALLOCATE (ftl_lsm)
!
DEALLOCATE (fwc_lsm)
DEALLOCATE (ftb_toa)
!
DEALLOCATE (fsand)
DEALLOCATE (fclay)
DEALLOCATE (mask)
DEALLOCATE (frho_b)
DEALLOCATE (fp)
DEALLOCATE (fWP)
DEALLOCATE (falpha)
DEALLOCATE (fsal_wat) 
DEALLOCATE (sal_sea)
!
DEALLOCATE (ftfrac)
!
DEALLOCATE (fwc_veg)
DEALLOCATE (fh)
DEALLOCATE (fb)
DEALLOCATE (ftauN)
DEALLOCATE (fw_effL)
DEALLOCATE (fw_effH)
!
DEALLOCATE (fNrh_L)
DEALLOCATE (fNrh_H)
DEALLOCATE (fNrv_L)
DEALLOCATE (fNrv_H)
!
DEALLOCATE (fhrmodel)
!
DEALLOCATE (ftth)
DEALLOCATE (fttv)
!
DEALLOCATE (ftau_veg)
DEALLOCATE (ftau_atm)
DEALLOCATE (ftb_au)
DEALLOCATE (ftb_ad)
DEALLOCATE (ftair)
!
DEALLOCATE (fsnowd)
DEALLOCATE (frsnow)
!
DEALLOCATE (tsoil)
DEALLOCATE (z_lsm)
!
SELECT CASE (CFINOUT)
   CASE ('ascii')
   DEALLOCATE (ndate)
   DEALLOCATE (ntime)
   DEALLOCATE (doy)
   DEALLOCATE (nbpt)
END SELECT
!
!
END PROGRAM CMEM_MAIN
