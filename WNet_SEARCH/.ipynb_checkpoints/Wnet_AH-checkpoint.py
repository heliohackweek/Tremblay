import os
from datetime import datetime
import argparse

import numpy as np
import torch

from src.wnet import WNet
from src.crf import crf_batch_fit_predict, crf_fit_predict
from utils.visualise import visualise_outputs
from utils.data import load_data
from utils.callbacks import model_checkpoint
import matplotlib.pyplot as plt
import h5py
import scipy.io as sio
import skimage.measure
import mat73
from tqdm import tqdm

p = argparse.ArgumentParser(
    formatter_class=argparse.ArgumentDefaultsHelpFormatter)

p.add_argument('-data_path', type=str, default='data/EUV_test_large_all2.mat',
               help='path of EUV images')
p.add_argument('-model', type=str, default='models/wnet.pt',
               help='path of pre-trained model')
p.add_argument('-epochs', type=int, default=100,
               help='how many epochs to train')
p.add_argument('-win_size', type=int, default=1,
               help='window size of pre-downsamplling')
p.add_argument('-batch_size', type=int, default=1,
               help='batch size of training')
p.add_argument('-vis_num', type=int, default=5,
               help='number of visualised test images')
p.add_argument('-test_range', nargs='+', type=int,
               default=[2560, 2616],
               help='range of test cases (make sure no missing samples in between)')
p.add_argument('-num_classes', type=int, default=20,
               help='number of classes during clustering')
p.add_argument('-lr', type=float, default=2e-5,
               help='learning rate')
p.add_argument('-per_train', type=float, default=0.7,
               help='percentage samples for training')
p.add_argument('-weight_decay', type=float, default=2e-5,
               help='regularisation factor')
p.add_argument("-cuda", action='store_true',
               help="GPU or CPU")
p.add_argument("-train", action='store_true',
               help="train or load the model")
p.add_argument("-test_save", action='store_true',
               help="save outputs for testing")
p.add_argument("-visualise", action='store_true',
               help="if do visualisation")
args = p.parse_args()

# ----------------------------------------------------------------------------------

print(r'---------------------- LOADING ----------------------')
# Load training & validation data
if args.data_path[-3:] == '.h5':
    with h5py.File(args.data_path, 'r') as f:

        x_train = torch.from_numpy(np.array(f['X_train'])
                                   .astype(np.float32))
        x_val = torch.from_numpy(np.array(f['X_val'])
                                 .astype(np.float32))
        x_train = (x_train - x_train.min()) / (x_train.max() - x_train.min())
        x_val = (x_val - x_val.min()) / (x_val.max() - x_val.min())

        f.close()

elif args.data_path[-4:] == '.mat':

    d = mat73.loadmat(args.data_path)

    X = torch.zeros([np.array(d['X']).shape[0],
                     3,
                     int(np.array(d['X']).shape[1]/args.win_size),
                     int(np.array(d['X']).shape[2]/args.win_size)])

    for i in range(X.shape[0]):
        # import ipdb; ipdb.set_trace()
        X[i, 0, :, :] = torch.from_numpy(
            skimage.measure.block_reduce(
                np.array(d['X'][i, :, :]),
                (args.win_size, args.win_size),
                np.nanmin))

    for i in range(1, 3):
        X[:, i, :, :] = X[:, 0, :, :]

    '''
    plt.pcolor(np.array(d['X'])[0, :, :])
    plt.clim(0, 3)

    plt.colorbar()
    plt.show()

    plt.contourf(X[0, 0, :, :])
    plt.clim(0, 3)
    plt.colorbar()
    plt.show()

    import ipdb; ipdb.set_trace()
    '''
    idx = int(X.shape[0]*args.per_train)
    x_train = X[:idx]
    x_val = X[idx:]
    x_test = X[np.arange(args.test_range[0],
                         args.test_range[1])]

    idx_nan_train = np.where(x_train < 0)
    idx_inf_train = np.where(x_train > 3.5)

    x_train[idx_nan_train] = 0
    x_train[idx_inf_train] = 3.5

    idx_nan_val = np.where(x_val < 0)
    idx_inf_val = np.where(x_val > 3.5)

    idx_nan_val_ex = []
    idx_inf_val_ex = []

    # import ipdb; ipdb.set_trace()

    for i in tqdm(range(x_val.shape[0])):

        idx_nan_val_ex.append(np.where(x_val[i, 0, :, :] < 0)[0])
        idx_inf_val_ex.append(np.where(x_val[i, 0, :, :] > 3.5)[0])

    x_val[idx_nan_val] = 0
    x_val[idx_inf_val] = 3.5

    idx_nan_test = np.where(x_test < 0)
    idx_inf_test = np.where(x_test > 3.5)

    x_test[idx_nan_test] = 0
    x_test[idx_inf_test] = 3.5

    x_train = (x_train - 1) / (x_train.max() - 1)
    x_val = (x_val - 1) / (x_val.max() - 1)
    x_test = (x_test - 1) / (x_test.max() - 1)

'''
plt.contourf(x_train[0, 0, :, :])
# plt.clim(0, 3)
plt.colorbar()
plt.show()
'''
y_train, y_val, y_test = x_train.clone(), x_val.clone(), x_test.clone()

print('shape of X_train:', x_train.shape)
print('shape of X_val:', x_val.shape)
print('shape of X_test:', x_test.shape)
print('shape of Y_train:', y_train.shape)
print('shape of Y_val:', y_val.shape)
print('shape of Y_test:', y_test.shape)
# Declare or load a model, and push to CUDA if needed

print(r'---------------------- TRAINING ----------------------')
if args.model:
    net = torch.load(args.model)
else:
    net = WNet(num_channels=x_train.shape[1],
               num_classes=args.num_classes)

if args.cuda:
    net = net.cuda()

if args.train:
    date = datetime.now().__str__()
    date = date[:16].replace(':', '-').replace(' ', '-')

    net.fit(
        x_train, y_train,
        x_val, y_val,
        epochs=args.epochs,
        learn_rate=args.lr,
        weight_decay=args.weight_decay,
        batch_size=args.batch_size,
        callbacks=[
            model_checkpoint(os.path.join('models', f'wnet-{date}.pt'))
        ]
    )

print(r'---------------------- TESTING ----------------------')
inputs = x_test
if args.cuda:
    inputs = inputs.cuda()

    mask, outputs = net.forward(inputs)
    inputs = inputs.detach().cpu().numpy()
    outputs = outputs.detach().cpu().numpy()

else:
    mask, outputs = net.forward(inputs)

mask = mask.detach().cpu().numpy()
new_mask = crf_batch_fit_predict(mask, inputs)

label = mask.argmax(1)
new_label = new_mask.argmax(1)
'''
idx_label = np.where((label < 0.6) & (label > 0.8))
idx_new_label = np.where((new_label < 0.6) & (new_label > 0.8))

label[idx_label] = 10
new_label[idx_new_label] = 10
'''
# import ipdb; ipdb.set_trace()

'''
n = 0

for idx_t in tqdm(idx):
    # label[n, idx_nan_val_ex[idx_t]] = -1
    # new_label[n, idx_nan_val_ex[idx_t]] = -1
    n += 1
'''

# import ipdb; ipdb.set_trace()
if args.test_save:

    with h5py.File('test_CH.h5', 'w') as f:
        f.create_dataset('origin', data=inputs)
        f.create_dataset('AE', data=outputs)
        f.create_dataset('Wnet', data=label)
        f.create_dataset('Wnet+CRF', data=new_label)
        f.close()

if args.visualise:

    print(r'---------------------- VISUALISING ----------------------')
    idx = np.random.randint(x_test.shape[0], size=(args.vis_num, ))
    visualise_outputs(inputs[idx], outputs[idx], label[idx], new_label[idx],
                      titles=['Origin', 'AE_recon', 'Wnet Mask',
                              'Wnet+CRF Mask'])
