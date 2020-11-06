#! /usr/bin/env python
# -*- coding: utf-8 -*-
'''
##############################################################################
Retrieve some data

Note: I tried to combine Ben's and Ajay's codes for downloading data, but
      they Ajay's used local files so I commented that out below. I will
      iterate upon this and make it more dynamic and user-friendly.
Note: I changed the time range to reflect the EIT processing used for Figure 1
      https://iopscience.iop.org/article/10.1086/525556/pdf
##############################################################################
'''
#import os
#import sys
#import glob
#import numpy as np
#import matplotlib.pyplot as plt
import astropy.units as u
#from astopy.coordinates import SkyCoord
#from astropy.wcs import WCS
from sunpy.net import Fido, attrs as a
#from sunpy.net import helioviewer
#import sunpy.map
#import sunpy.sun
#from sunpy.coordinates import get_body_heliographic_stonyhurst
#from reproject import reproject_interp
#from reproject.mosaicking import reproject_and_coadd
#===============================================================================
# Instruments
stereob = (a.vso.Source('STEREO_B') &
          a.Instrument('EUVI') &
          a.Time('2002-05-19', '2002-05-20T00:00:00'))
stereoa = (a.vso.Source('STEREO_A') &
          a.Instrument('EUVI') &
          a.Time('2002-05-19', '2002-05-20T00:00:00'))
eit = (a.Instrument('EIT') &
       a.Time('2002-05-19', '2002-05-20T00:00:00'))
# Wavelength(s)
wave = a.Wavelength(171*u.AA)
# wave = a.Wavelength(195*u.AA)
# wave = a.Wavelength(304*u.AA)
# Search for data from all three instruments around the same time
results = Fido.search(stereoa | stereob | eit, wave)
print(results)
# Download files
files = Fido.fetch(results, path=os.path.join(os.getcwd(), '{file}.fits'))
print(files)
#===============================================================================
#hv = helioviewer.HelioviewerClient()
# local placement of files
#path_to_files = '/home/plasmion/coronal_hole_heliohackweek/download_data/'
#eit = (a.Instrument("eit") &
#          a.Time('2007-01-03T13:01:17', '2007-01-03T16:01:17'))
#euvi = (a.vso.Source('STEREO_A') &
#        a.Instrument("EUVI") &
#        a.Time('2007-01-03T13:01:17', '2007-01-03T16:01:17'))
#euvib = (a.vso.Source('STEREO_B') &
#        a.Instrument("EUVI") &
#        a.Time('2007-01-03T13:01:17', '2007-01-03T16:01:17'))
#samp=a.vso.Sample(10*u.minute)
#wave = a.Wavelength(17.0 * u.nm, 30.4 * u.nm)
#res = Fido.search(wave, eit | euvi | euvib, samp)
#eit_path=path_to_files+'*efz*'
#eit_files=sorted(glob.glob(eit_path))
#stereoa_path=path_to_files+'*4eua*.fts'
#stereoa_files=sorted(glob.glob(stereoa_path))
#stereob_path=path_to_files+'*4eub*.fts'
#stereob_files=sorted(glob.glob(stereob_path))
