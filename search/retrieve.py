#! /usr/bin/env python
'''
This class enables one to retrieve STEREO EUVI and SoHO EIT full-disk imagery.

B Smith 2020
'''
def get_data():
    pass

# having trouble finding SOHO EIT full-disk imagery for all 4 wavelengths
# I found this website that has FITS files of EIT for SOHO, not sure it's correct.
# https://sohowww.nascom.nasa.gov/data/summary/eit/

# From https://umbra.nascom.nasa.gov/eit/eit-catalog.html
# EIT data will continue to be at the Virtual Solar Observatory
# https://vso.nascom.nasa.gov/cgi/search?time=1&provider=1&version=current&build=1
# Only shows 1996-2007 SOHO EIT, what about prior to that or near real time?

# Virtual Solar Observatory has newer search form, however, it's not a great way to automate retrieval of products.
# https://seal.nascom.nasa.gov/archive/soho/public/data/REPROCESSING/Completed/1996/eit171/19960125/19960125_1614_eit171_1024.jpg
# gives 19960101 - 20200825

# https://umbra.nascom.nasa.gov/eit/ for SOHO EIT imagery
# - EIT data from VSO or older EIT Web catalog
#   - VSO - presented a customizable web search; selected product type; searched between 1970-20200912, pearl script to perform SDAC search to link to EIT imagery; 530,330 records found but only returned 10k.
#   - EIT Web - form doesn't seem to work

# automation: retrieve from url given from VSO

# for STEREO EUVI
# https://stereo-ssc.nascom.nasa.gov/data.shtml
# http://solar.jhuapl.edu/Data-Products/EUV-Synchronic-Maps.php?channel=195&dir=euvi_only#EUVISynchronicMaps
# 
