#! /usr/bin/env python
# -*- coding: utf-8 -*-
'''
##############################################################################
Caplan Synchronic Imagery Retrieval
##############################################################################
'''
# imports (std lib)
import sys
import logging
import argparse
# imports (3rd party)
import requests
# imports (local)

#=============================================================================
def get_files(map_type):
    '''
       #######################################################################
       Retrieval of imagery through web-scraping.
       #######################################################################
    '''
    base_url = 'http://predsci.com/chd/data/maps/hdf/' + map_type + '/'

    r = requests.get(base_url)
    lines = r.text.splitlines()
    links = [line for line in lines if 'href' in line and '.hdf' in line]
    for link in links:
        url = link.split('href')[-1].split('hdf')[0][2:] + 'hdf'
        name = url #link.split()
        print('downloading...' + name)
        with open(name, 'wb') as f:
            f.write(requests.get(base_url + url).content)
    return

def parse_args(args=None):
    '''
       #######################################################################
       Command-Line Argument Parser
       #######################################################################
       Note: Could extend this for verbosity, date range, and other params.
       =======================================================================
    '''
    parser = argparse.ArgumentParser()

    parser.add_argument(
        '-t', '--itype', default='euv',
        help='type of maps \n\n (default: %(default)s)'
    )

    try:
        args = parser.parse_args(args)
    except:
        if len(args) <= 1:
            sys.exit(1)
        else:
            sys.exit(2)

    return args

def main(arguments=[]):
    '''
       #######################################################################
       The main driver of this module if invoked as a command-line utility.
       If no arguments are provided, then all files will be downloaded.
       #######################################################################
    '''
    args = parse_args(arguments)

    logging.info(__doc__)
    logging.debug('Using the following configuration:')
    logging.debug(args)

    get_files(args.itype)

    return 0

#=============================================================================
if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
