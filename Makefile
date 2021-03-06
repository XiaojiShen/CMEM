# Makefile for CMEM sources
#

# Example of makefile for local ECMWF use
#
FORTRAN_COMPILER = gfortran




RM = rm -f


cmem : cmem.o
	${FORTRAN_COMPILER} -o cmem  parkind1.o yomlun_ifsaux.o yomlun.o abor1.o \
yomcmempar.o \
yomcmemsoil.o \
yomcmemveg.o yomcmematm.o yomcmemfields.o cmem_setup.o  vegtable.o \
atm_sub.o \
rdcmemasciiinfo.o rdcmemascii.o cmem_init.o dielice_sub.o \
dielwat_sub.o dielsoil_sub.o teff_sub.o fresnel_sub.o wilheit_sub.o \
rghref_sub.o veg_sub.o cmem_soil.o cmem_veg.o cmem_snow.o cmem_atm.o \
cmem_rtm.o  wrcmemascii.o cmem_main.o \

	$(RM) *o
	$(RM) *mod
 

cmem.o : cmem_main.F90
	${FORTRAN_COMPILER} -c parkind1.F90 yomlun_ifsaux.F90 yomlun.F90 abor1.F90 \
yomcmempar.F90 \
yomcmemsoil.F90 \
yomcmemveg.F90 yomcmematm.F90 yomcmemfields.F90 cmem_setup.F90 vegtable.F90 \
atm_sub.F90 \
rdcmemasciiinfo.F90 rdcmemascii.F90 cmem_init.F90 dielice_sub.F90 \
dielwat_sub.F90 dielsoil_sub.F90 teff_sub.F90 fresnel_sub.F90 wilheit_sub.F90 \
rghref_sub.F90 veg_sub.F90 cmem_soil.F90 cmem_veg.F90 cmem_snow.F90 cmem_atm.F90 \
cmem_rtm.F90 wrcmemascii.F90 cmem_main.F90


