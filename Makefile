# Makefile for CMEM sources
#

# Example of makefile for local ECMWF use
#
FORTRAN_COMPILER = gfortran

GRIBAPI_INCLUDE_PATHS =-I/usr/local/apps/grib_api/1.12.3/GNU/4.8.1/include
GRIBAPI_LIBRARY_PATHS =-L/usr/local/apps/grib_api/1.12.3/GNU/4.8.1/lib -L/usr/local/apps/grib_api/1.12.3/GNU/4.8.1/lib
GRIBAPI_LIBRARY_NAMES = -lgrib_api_f90 -lgrib_api -ljasper


NETCDF_INCLUDE_PATHS =-I/usr/local/apps/netcdf/3.6.3/GNU/4.8.1/include
NETCDF_LIBRARY_PATHS = -L/usr/local/apps/netcdf/3.6.3/GNU/4.8.1/lib
NETCDF_LIBRARY_NAMES = -lnetcdf


RM = rm -f


cmem : cmem.o
	${FORTRAN_COMPILER} -o cmem  parkind1.o yomlun_ifsaux.o yomlun.o abor1.o \
yomcmemgribapi.o yomcmemnetcdf.o yomcmempar.o \
io_cmemgribapi.o io_cmemnetcdf.o yomcmemsoil.o \
yomcmemveg.o yomcmematm.o yomcmemfields.o cmem_setup.o  vegtable.o \
atm_sub.o rdcmemgribapiinfo.o rdcmemgribapi.o \
rdcmemnetcdfinfo.o rdcmemnetcdf.o rdcmemasciiinfo.o rdcmemascii.o cmem_init.o dielice_sub.o \
dielwat_sub.o dielsoil_sub.o teff_sub.o fresnel_sub.o wilheit_sub.o \
rghref_sub.o veg_sub.o cmem_soil.o cmem_veg.o cmem_snow.o cmem_atm.o \
cmem_rtm.o wrcmemgribapi.o wrcmemascii.o wrcmemnetcdf.o cmem_main.o \
${GRIBAPI_LIBRARY_PATHS} ${GRIBAPI_LIBRARY_NAMES} \
${NETCDF_LIBRARY_PATHS} ${NETCDF_LIBRARY_NAMES}

	$(RM) *o
	$(RM) *mod
 

cmem.o : cmem_main.F90
	${FORTRAN_COMPILER} -c ${NETCDF_INCLUDE_PATHS} ${GRIBAPI_INCLUDE_PATHS} parkind1.F90 yomlun_ifsaux.F90 yomlun.F90 abor1.F90 \
yomcmemgribapi.F90 yomcmemnetcdf.F90 \
yomcmempar.F90 io_cmemgribapi.F90 \
io_cmemnetcdf.F90 yomcmemsoil.F90 \
yomcmemveg.F90 yomcmematm.F90 yomcmemfields.F90 cmem_setup.F90 vegtable.F90 \
atm_sub.F90 rdcmemgribapiinfo.F90 rdcmemgribapi.F90 \
rdcmemnetcdfinfo.F90 rdcmemnetcdf.F90 rdcmemasciiinfo.F90 rdcmemascii.F90 cmem_init.F90 dielice_sub.F90 \
dielwat_sub.F90 dielsoil_sub.F90 teff_sub.F90 fresnel_sub.F90 wilheit_sub.F90 \
rghref_sub.F90 veg_sub.F90 cmem_soil.F90 cmem_veg.F90 cmem_snow.F90 cmem_atm.F90 \
cmem_rtm.F90 wrcmemgribapi.F90 wrcmemascii.F90 wrcmemnetcdf.F90 cmem_main.F90


