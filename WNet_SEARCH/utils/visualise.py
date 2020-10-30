from typing import Tuple, Iterable

import numpy as np
import matplotlib.pyplot as plt


def visualise_outputs(*args: Tuple[Iterable], titles: Iterable = ()) -> None:
    r"""Helper function for visualizing arrays of related images.  Each input argument is expected to be an Iterable of
    images -- shape:  (batch, nchan, nrow, ncol).  Will handle both RGB and grayscale images. The i-th elements from all
    input arrays are displayed along a single row, with shared x- and y-axes for visualization.

    :param args: Iterables of related images to display.
    :param titles: Titles to display above each column.
    :return: None (plots the images with Matplotlib)
    """
    nrow, ncol = len(args[0]), len(args)
    fig, ax = plt.subplots(nrow, ncol, sharex='row', sharey='row', squeeze=False)

    for j, title in enumerate(titles[:ncol]):
        ax[0, j].set_title(title)

    for i, images in enumerate(zip(*args)):
        for j, image in enumerate(images):
            if len(image.shape) < 3:
                CME = image  # / image.max()
                # import ipdb; ipdb.set_trace()

                if j == 3:
                    idx_noncme = np.where((CME != 5))
                    # CME[idx_noncme] = 0

                im = ax[i, j].imshow(CME)
            else:
                CME = np.moveaxis(image, 0, -1)  # / image.max()

                if j == 4:
                    idx_noncme = np.where((CME != 5))
                    # CME[idx_noncme] = 0

                im = ax[i, j].imshow(CME)

    plt.colorbar(im)
    # plt.savefig('EUV_test_results.eps', format='eps', dpi=300)
    plt.show()
