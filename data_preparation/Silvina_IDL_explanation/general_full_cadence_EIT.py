#! /usr/bin/env python
# -*- coding: utf-8 -*-
'''
##############################################################################
General Full Cadence - application of a wavelet-based image transform
##############################################################################
1. Find fits files.
    - FITS files: extension is typically ".fits" - check with incoming data sources as well
    - Note: Silvina recommends to NOT replicate the what_euvi.pro code - only uses STEREO data.
    - Note: what_euvi takes a string date, list of strings time range, sc?,
            wavelength string.
    - Do we replicate this functionality? Yes, but maybe not for the scope of this project.
          Depends upon how data retrieval is coded and file naming conventions.
    - What about the output directory structure in the code? Again, desired but not within scope.
2. Create circular 800px mask.
    - Note: generalize to a given width/height, and radius
    - Note: 2048 and 800 was given; need to verify for project's inputs
            STEREO data was used as inputs for IDL code - ours may be different resolutions
    - Note: If we want to block everything outside r=800, we need to use:
            data[~mask] = np.nan
    - We need to verify that these methods are identical from translation.
    - Need to find radius of Sun in image as well as if image is centered or not.
3a. Need to replace routine: secchi_prep
    - Ref: https://hesperia.gsfc.nasa.gov/ssw/stereo/secchi/doc/secchi_prep.html
    - secchi_prep is a routine that is for raw data L1 prep which we assume that the
            retrieved data for this project has already went through this standardized
            process (centering Solar North, etc.).
            Might be able to do this using SunPy? - might need to do this in data prep
            SDO - use aia_prep instead of secchi_prep
3b. Take natural log of image for pixels above 0.01.
    - Note: Just a little concerned about reproducibility here.
'''
# imports (std lib)
import os
import sys
import fnmatch
import logging
import argparse
# imports (3rd party)
import numpy as np
# imports (local)

#=============================================================================
def find(path=os.getcwd(), ext='.fits'):
    '''Recursive, top-down, file search function.'''
    for (root, dirs, files) in os.walk(path):
        for f in fnmatch.filter(files, '*'+ext):
            yield os.path.join(root, f)

def parse_args(args=None):
    '''
       #######################################################################
       Command-Line Argument Parser
       #######################################################################
    '''
    parser = argparse.ArgumentParser()

    parser.add_argument(
        '-i', '--input', default=os.getcwd(),
        help='path to input FITS file(s) \n\n (default: %(default)s)'
    )

    try:
        args = parser.parse_args(args)
    except:
        if len(args) <= 1:
            sys.exit(1)
        else:
            sys.exit(2)

    # test input directory/file
    if os.path.exists(args.input):
        if os.path.isdir(args.input):
            # collect all files recursively in directory
            args.input = os.path.abspath(args.input)
            files = list(f for f in find(path=args.input))
            logging.info('Found ' + str(len(files)) +
                ' FITS files to process in ' + args.input)
            args.input = sorted(files)
        elif os.path.isfile(args.input):
            # send list of a single file to process
            args.input = [os.path.abspath(args.input)]
        else:
            logging.error('Issue with input directory/file provided.')
            raise OSError('There is an issue with the input pathgiven.')
    else:
        logging.error('Input path does not exist.')
        raise OSError('Path does not exist.')

    return args

def create_circular_mask(h, w, center=None, radius=None):
    '''
       ########################################################################
       Creates a NumPy circular mask.
       ########################################################################
       Reference: https://stackoverflow.com/a/44874588
       ========================================================================
    '''
    if h % 2 == 0: h=h+1
    if w % 2 == 0: w=w+1
    if center is None: # use the middle of the image
        center = (int(w/2), int(h/2))
    if radius is None: # use the smallest distance between the center and image walls
        radius = min(center[0], center[1], w-center[0], h-center[1])

    Y, X = np.ogrid[:h, :w]
    dist_from_center = np.sqrt((X - center[0])**2 + (Y-center[1])**2)

    mask = dist_from_center <= radius
    return mask

def main(arguments=[]):
    '''
       #######################################################################
       The main driver of this module if invoked as a command-line utility.
       #######################################################################
    '''
    args = parse_args(arguments)

    logging.info(__doc__)
    logging.debug('Using the following configuration:')
    logging.debug(args)

    # Step 1: Find FITS files.
    print(args.input)
    # Step 2: Create a 2048x2048 mask in the shape of a disk for pixels larger
    #         than 800 (not clear if this == size of Sun). FITS images are
    #         originally also 2048x2048.

    # get image dimensions dynamically
    # manual process is radius of image
    # assume here or not that all input imagery is standardized in size and Sun radius?
    mask = create_circular_mask(2048, 2048, center=(1024, 1024), radius=800)
    print(mask)
    print(mask[1020:1028,1020:1028])

    return 0

#=============================================================================
if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
