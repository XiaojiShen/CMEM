# -*- coding: utf-8 -*-
__author__ = 'Xiaoji Shen'
#运行前要修改cmem输出文件的第一行
import glob
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt


# 1. set up table
def settable(f, CNAMEID, doy):
    filelist = glob.glob('out_tbtoat_'+CNAMEID+'_'+f+'_*.asc')
    if len(filelist) == 0:
        raise('read filelist error!')
    tbvsangle = pd.DataFrame()
    for file in filelist:
        angle = int(file[-6:-4])
        table = pd.read_table(file, delim_whitespace=True)
        table.index = np.linspace(angle, angle, table.shape[0], dtype='int')
        tbvsangle = tbvsangle.append(table)
    tbvsangle.pop('year')
    tbvsangle.pop('month')
    tbvsangle.pop('day')
    tbvsangle.index = pd.MultiIndex.from_arrays([tbvsangle.index, tbvsangle.pop('doy')], names=['angle', 'doy'])

    # 2. calculation
    tbondate = tbvsangle.loc[(slice(None), [float(doy)]), ['TBH(K)', 'TBV(K)']]
    tbondate.insert(0, 'angle', tbondate.index.get_level_values(0).values)
    # corr = tbondate.corr()
    return tbondate


# 3. plotting
f = '014'  # frequency
CNAMEID = 'MiWiFrWsWiPeTsHT'  # model options
doy = '220.67'
tbondate = settable(f, CNAMEID, doy)
plt.scatter(tbondate['angle'], tbondate['TBH(K)'], s=10, label=str(int(f)/10)+' GHz H')
plt.scatter(tbondate['angle'], tbondate['TBV(K)'], s=10, label=str(int(f)/10)+' GHz V')
f = '008'
tbondate = settable(f, CNAMEID, doy)
plt.scatter(tbondate['angle'], tbondate['TBH(K)'], s=10, label=str(int(f)/10)+' GHz H')
plt.scatter(tbondate['angle'], tbondate['TBV(K)'], s=10, label=str(int(f)/10)+' GHz V')
plt.title('TB vs. Incidence angle    model option='+CNAMEID)
# plt.title('TB vs. Incidence angle\n f='+str(float(f)/10)+'GHz  model option='+CNAMEID)
plt.xlabel('Incidence angle (°)')
plt.ylabel('TB (K)')
# plt.legend(title='Polarization')
# plt.savefig('TBvsAngle '+f+CNAMEID+date)
plt.legend()
plt.savefig('TBvsAngle '+CNAMEID+doy.replace('.', '-'))
plt.close()