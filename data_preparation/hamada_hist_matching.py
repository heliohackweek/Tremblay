# Imports
import numpy as np


class hamada():
    
    def __init__(self, filename='cumulative_hist.npz'):
        # Read
        npzfile = np.load(filename)
        self.cdf_eit = npzfile['cdf_eit']
        self.bin_eit = npzfile['bins_eit']
        self.cdf_euvil = npzfile['cdf_euvil']
        self.bin_euvil = npzfile['bins_euvil']
        self.nb_channels, self.nb_bins = self.bin_eit.shape
        
    # Histogram matching (Hamada et al., 2019)
    def hist_matching(self, data_eit, data_euvi, channel_nb):
        
        # Standardize
        log_eit = np.log10(data_eit)
        log_euvi = np.log10(data_euvi)
        mean_log_eit = np.nanmean(log_eit)
        std_log_eit = np.nanstd(log_eit)
        mean_log_euvi = np.nanmean(log_euvi)
        std_log_euvi = np.nanstd(log_euvi)
        norm_log_eit = (log_eit - mean_log_eit) / std_log_eit
        
        # Extract finite values
        where_mask = np.isfinite(norm_log_eit)
        mask_log_eit = norm_log_eit[where_mask]

        # Bins
        bin_eit = (self.bin_eit[channel_nb, :-1] + self.bin_eit[channel_nb, 1:]) / 2
        bin_euvil = (self.bin_euvil[channel_nb, :-1] + self.bin_euvil[channel_nb, 1:]) / 2
        
        # Histogram matching
        cdf_tmp = np.interp(mask_log_eit.flatten(), bin_eit.flatten(),
                            self.cdf_eit[channel_nb, :].flatten())
        norm_log_adjusted = np.interp(cdf_tmp, self.cdf_euvil[channel_nb, :].flatten(),
                                      bin_euvil.flatten())
        
        # Adjust data
        norm_log_eit[where_mask] = norm_log_adjusted
        data_eit_adjusted = 10.**(norm_log_eit*std_log_euvi + mean_log_euvi)
        
        return data_eit_adjusted
