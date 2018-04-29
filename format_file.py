# -*- coding: utf-8 -*-
__author__ = 'Xiaoji Shen'
import glob

filelist = glob.glob('out_tbtoat*.asc')
for file in filelist:
    with open(file, 'r+') as f:
        f.seek(0)
        f.writelines('     year     month     day     doy    TBH(K)  TBV(K)   TEFF_H(K)   TEFF')
