# -*- coding: utf-8 -*-
__author__ = 'Xiaoji Shen'

import glob
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

angle = '50'  # incidence angle
CNAMEID = 'WaChFrWiWiPeTsHT'  # model options
date = '2016-01-02'

# 1. set up table
filelist = glob.glob('out_tbtoat_'+CNAMEID+'_*_' + angle + '.asc')
if len(filelist) == 0:
    raise('read filelist error!')
tbvsf = pd.DataFrame()
for file in filelist:
    f = int(file[-10:-7])/10.0
    table = pd.read_table(file, delim_whitespace=True)
    table.index = np.linspace(f, f, table.shape[0], dtype='float')
    tbvsf = tbvsf.append(table)
tbvsf.drop(columns='doy', inplace=True)
datecol = pd.to_datetime(pd.concat([tbvsf.pop('year'), tbvsf.pop('month'), tbvsf.pop('day')], axis=1))
tbvsf.index = pd.MultiIndex.from_arrays([tbvsf.index, datecol], names=['angle', 'date'])

# 2. calculation
tbondate = tbvsf.loc[(slice(None), [date]), ['TBH(K)', 'TBV(K)']]
tbondate.insert(0, 'f', tbondate.index.get_level_values(0).values)
# corr = tbondate.corr()


# 3. plotting
def scatterplot():
    plt.scatter(tbondate['f'], tbondate['TBH(K)'], label='H')
    plt.scatter(tbondate['f'], tbondate['TBV(K)'], label='V')
    plt.title('TB vs. f \nincidence angle='+angle+'° model option='+CNAMEID)
    plt.xlabel('Frequency (GHz)')
    plt.ylabel('TB (K)')
    plt.legend(title='Polarization')
    plt.savefig('TBvsF '+angle+CNAMEID+date)
    plt.close()


scatterplot()