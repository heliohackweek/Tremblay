#!/usr/bin/env python3

from astropy.io import fits
import numpy as np
import cupy as cp
import glob
from progressbar import progressbar
import skimage.measure

import argparse
import matplotlib.pyplot as plt
from sklearn.decomposition import KernelPCA, PCA
from sklearn.cluster import KMeans
from sklearn.cluster import DBSCAN

import torch


# arguments
p = argparse.ArgumentParser(
    formatter_class=argparse.ArgumentDefaultsHelpFormatter)

p.add_argument("-filepath", type=str, default='example/',
               help="filepath of the synoptic maps (.fits)")
p.add_argument("-image_idx", type=int, nargs='+', default=[0],
               help="index of the selected map")
p.add_argument("-win_size", type=int, default=16,
               help="the size of sliding window")
p.add_argument("-stride", type=int, default=4,
               help="stride of sliding window")
p.add_argument("-pool_size", type=int, default=4,
               help="size of pooling")
p.add_argument("-fun", type=str, default="mean",
               choices=['mean', 'std', 'max'],
               help="pooling function")
p.add_argument("-num_clu", type=int, default=4,
               help="number of clusters")
p.add_argument("-kernel", type=str, default='linear',
               choices=['sigmoid', 'rbf', 'linear'])
p.add_argument("-model", type=str, default='kmeans',
               choices=['dbscan', 'kmeans'])

args = p.parse_args()

# For testing

files = glob.glob(args.filepath+'*.fits')
np.sort(files)

# Get data shape
img_shape = fits.open(files[0])[0].data.shape

all_data = np.empty((len(files), img_shape[1], img_shape[0]),
                    dtype=np.float32)
print('shape of all_data', all_data.shape)

# Read *.fits files
p = progressbar
for i, f in p(enumerate(files)):
    fd = fits.open(f)[0]
    all_data[i] = fd.data.T[::-1]

# cuda availability
if torch.cuda.is_available():
    pass

print(all_data.shape)


def norm_ah(X):
    num = X.shape[1]
    out = np.zeros(X.shape)
    for i in range(num):
        dis = X[:, i].max() - X[:, i].min()
        out[:, i] = (X[:, i] - X[:, i].min())/dis

    # ipdb.set_trace()

    return out


i = args.image_idx

stride = args.stride
win_size_large = args.win_size
win_size_small = args.pool_size
clusters = args.num_clu

clu = []
coord = []

for m in p(range(win_size_large, all_data.shape[1]-win_size_large, stride)):
    for n in range(win_size_large+int(all_data.shape[2]/6),
                   all_data.shape[2]-win_size_large-int(all_data.shape[2]/6),
                   stride):
        t = norm_ah(all_data[i,
                             m-win_size_large:m+win_size_large,
                             n-win_size_large:n+win_size_large]**2).squeeze()
        coord_t = [m, n]
        if args.fun == 'mean':

            t1 = skimage.measure.block_reduce(
                t,
                (win_size_small, win_size_small),
                np.nanmean).reshape(-1, 1)
        elif args.fun == 'max':
            t1 = skimage.measure.block_reduce(
                t,
                (win_size_small, win_size_small),
                np.nanmax).reshape(-1, 1)
        elif args.fun == 'std':
            t1 = skimage.measure.block_reduce(
                t,
                (win_size_small, win_size_small),
                np.nanstd).reshape(-1, 1)
        clu.append(t1.squeeze())
        coord.append(coord_t)

print(np.array(clu).shape)
X = np.array(clu)
coords = np.array(coord)

# dimensional reduction again by PCA

if args.kernel == 'linear':
    X_t = PCA(n_components=clusters).fit_transform(X)

else:
    X_t = KernelPCA(n_components=clusters,
                    kernel=args.kernel).fit_transform(X)

print('shape of X_t:', X_t.shape)
# import ipdb; ipdb.set_trace()

# unsupervised learning

if args.model == 'kmeans':
    kmeans = KMeans(n_clusters=clusters).fit(X_t)
    labels = kmeans.predict(X_t)
elif args.model == 'dbscan':
    db = DBSCAN(eps=0.5, min_samples=100).fit(X_t)
    labels = db.labels_

# display

for i in range(clusters):
    idx = np.where(labels == i)[0]
    plt.plot(coords[idx, 0], coords[idx, 1], '.')

plt.show()
