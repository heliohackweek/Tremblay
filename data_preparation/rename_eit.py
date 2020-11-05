'''
Renames EIT images to help identify waveleghth and date time from filename

'''

import glob
import os
from astropy.io.fits import getheader


path_to_files=input('path to EIT files')

eit=sorted(glob.glob(path_to_files+'efz*'))

for files in eit:
    hed1 = getheader(files)
    os.rename(files,path_to_files+'EIT_'+str(hed1.get('date_obs'))+'_'+str(hed1.get('wavelnth'))+'.fits')
