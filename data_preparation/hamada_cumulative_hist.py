# Imports
import numpy as np
import numpy.ma as ma
import sunpy.map
import sunpy.sun
from sunpy.map.maputils import all_coordinates_from_map
from sunpy.coordinates import get_horizons_coord
import glob


# Masking function
def mask_outside_disk(inst_map):
    # Find coordinates and radius
    hpc_coords = all_coordinates_from_map(inst_map)
    r = np.sqrt(hpc_coords.Tx ** 2 + hpc_coords.Ty ** 2) / inst_map.rsun_obs
    
    # Mask everything outside of the solar disk
    mask = ma.masked_greater_equal(r, 1)
    ma.set_fill_value(mask, np.nan)
    where_disk = np.where(mask.mask == 1)
    
    return where_disk


def make_hist(norm_log_inst, bins_inst):
    
    where_mask = np.isfinite(norm_log_inst)
    arr = norm_log_inst[where_mask]
    hist, bins = np.histogram(arr, bins=bins_inst, density=True)
    width = bins[1] - bins[0]
    
    return hist*width


# Nb. of samples to use for the Hamada process
nb_samples = 8
nb_bins = 400
nb_channels = 3

# Find sample data
path_to_files = '/home/btremblay/Documents/dir.HelioHackWeek/sampledata/'
filenames_eit_0 = sorted(glob.glob(path_to_files+'eit_l1*'))
filenames_euvil_0 = sorted(glob.glob(path_to_files+'*eu_L.fts'))
# Benoit: Needs fixing
filenames_eit_1 = sorted(glob.glob(path_to_files+'eit_l1*'))
filenames_euvil_1 = sorted(glob.glob(path_to_files+'*eu_L.fts'))
# Benoit: Needs fixing
filenames_eit_2 = sorted(glob.glob(path_to_files+'eit_l1*'))
filenames_euvil_2 = sorted(glob.glob(path_to_files+'*eu_L.fts'))

# Arrays for cdf
cdf_eit = np.zeros((nb_channels, nb_bins-1))
bins_eit = np.zeros((nb_channels, nb_bins))
cdf_euvil = np.zeros((nb_channels, nb_bins-1))
bins_euvil = np.zeros((nb_channels, nb_bins))

# Output
filename_output = 'cumulative_hist.npz'

# Loop over wavelengths
for channel_nb in range(nb_channels):
    
    if channel_nb == 0:
        filenames_eit = filenames_eit_0
        filenames_euvil = filenames_euvil_0
    elif channel_nb == 1:
        filenames_eit = filenames_eit_1
        filenames_euvil = filenames_euvil_1
    elif channel_nb == 2:
        filenames_eit = filenames_eit_2
        filenames_euvil = filenames_euvil_2
    
    # Map objects
    eit_maps = sunpy.map.Map(filenames_eit)  # [channel_nb, :])
    nx_eit, ny_eit = eit_maps[0].data.shape
    euvil_maps = sunpy.map.Map(filenames_euvil)  # [channel_nb, :])
    nx_euvil, ny_euvil = euvil_maps[0].data.shape
    
    # Log arrays
    norm_log_eit = np.zeros((nb_samples, nx_eit, ny_eit))
    norm_log_euvil = np.zeros((nb_samples, nx_euvil, ny_euvil))

    # Histograms (of the standardized log intensities)
    hist_eit = np.zeros((nb_samples, nb_bins - 1))
    hist_euvil = np.zeros((nb_samples, nb_bins - 1))
    
    # Loop over objects
    for file_nb in range(nb_samples):
        
        if eit_maps[file_nb].observatory in ['SOHO']:
            new_coords = get_horizons_coord(eit_maps[file_nb].observatory.replace(' ', '-'),
                                            eit_maps[file_nb].date)
            eit_maps[0].meta['HGLN_OBS'] = new_coords.lon.to('deg').value
            eit_maps[0].meta['HGLT_OBS'] = new_coords.lat.to('deg').value
            eit_maps[0].meta['DSUN_OBS'] = new_coords.radius.to('m').value
            eit_maps[0].meta.pop('hec_x')
            eit_maps[0].meta.pop('hec_y')
            eit_maps[0].meta.pop('hec_z')
        
        # Mask everything outside of the solar disk
        # where_mask = mask_outside_disk(eit_maps[file_nb])
        hpc_coords = all_coordinates_from_map(eit_maps[file_nb])
        r = np.sqrt(hpc_coords.Tx ** 2 + hpc_coords.Ty ** 2) / eit_maps[file_nb].rsun_obs
        # Masking operation
        mask = ma.masked_greater_equal(r, 1)
        ma.set_fill_value(mask, np.nan)
        # Adjust data
        where_mask_eit = np.where(mask.mask == 1)
        eit_maps[file_nb].data[where_mask_eit] = np.nan
        
        # Mask everything outside of the solar disk
        # where_mask = mask_outside_disk(euvil_maps[file_nb])
        hpc_coords = all_coordinates_from_map(euvil_maps[file_nb])
        r = np.sqrt(hpc_coords.Tx ** 2 + hpc_coords.Ty ** 2) / euvil_maps[file_nb].rsun_obs
        # Masking operation
        mask = ma.masked_greater_equal(r, 1)
        ma.set_fill_value(mask, np.nan)
        # Adjust data
        where_mask_euvi = np.where(mask.mask == 1)
        euvil_maps[file_nb].data[where_mask_euvi] = np.nan

        # Benoit: Insert wavelet filter here for EIT and square data
        
        
        # Log intensities
        log_eit = np.log10(eit_maps[file_nb].data)
        log_euvil = np.log10(euvil_maps[file_nb].data**2)

        # Normalization
        mean_log_eit = np.nanmean(log_eit)
        std_log_eit = np.nanstd(log_eit)
        mean_log_euvil = np.nanmean(log_euvil)
        std_log_euvil = np.nanstd(log_euvil)
        norm_log_eit[file_nb, :, :] = (log_eit - mean_log_eit)/std_log_eit
        norm_log_euvil[file_nb, :, :] = (log_euvil - mean_log_euvil) / std_log_euvil
        
    # Compute histograms
    dmin = np.nanmin(norm_log_eit)
    dmax = np.nanmax(norm_log_eit)
    bins_eit[channel_nb, :] = np.linspace(dmin, dmax, nb_bins)
    dmin = np.nanmin(norm_log_euvil)
    dmax = np.nanmax(norm_log_euvil)
    bins_euvil[channel_nb, :] = np.linspace(dmin, dmax, nb_bins)
    
    # Individual histograms
    for file_nb in range(nb_samples):
        # EIT
        hist_eit[file_nb, :] = make_hist(norm_log_eit[file_nb, :, :], bins_eit[channel_nb, :])
        # EUVI-l
        hist_euvil[file_nb, :] = make_hist(norm_log_euvil[file_nb, :, :], bins_euvil[channel_nb, :])

    # Average
    hist_eit = np.mean(hist_eit, axis=0)
    hist_euvil = np.mean(hist_euvil, axis=0)
    
    # Cumulative
    cdf_eit[channel_nb, :] = np.cumsum(hist_eit)
    cdf_euvil[channel_nb, :] = np.cumsum(hist_euvil)
    

# Save CDFs and bins
np.savez(filename_output, cdf_eit=cdf_eit, bins_eit=bins_eit, cdf_euvil=cdf_euvil, bins_euvil=bins_euvil)

#############
# End of file
#############
