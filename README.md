# SEgmentation of polAR Coronal Holes (SEARCH)

Using unsupervised learning to SEARCH for polar coronal holes in synoptic EUV images.

__Contents__

1. [Introduction](#introduction)
2. [Data Preparation](#data-preparation)
3. [Segmentation](#segmentation)
4. [Testing](#testing)

---

## Introduction

- __Project Pitch:__ [Slides](https://docs.google.com/presentation/d/1fVU3TLTAzfbDvXf7WfI2kvGJPOjLjqk_DWkyohbk7VU/edit?usp=sharing) _by Ajay Kumar Tiwari, Andong Hu, Benoit Tremblay, Luisa Capannolo & Michael Kirk_

## Data Preparation
_In preparation for the Hackweek..._

- [x] __Step 0:__ Acquisition of SoHO/EIT & STEREO/EUVI Data
  - [Sample data](https://drive.google.com/drive/folders/1WtUW-a6fZvcFKvPwtAY-wYfHLyi1hrF5?usp=sharing) _courtesy of Michael Kirk & Sam Wallace_

- [x] __Step 1:__ Identification of Time Intervals to Map the Entire Sun at an Instantaneous Time
  - Inspiration: [Creating a Full Sun Map with AIA and EUVI](https://docs.sunpy.org/en/stable/generated/gallery/map_transformations/reprojection_aia_euvi_mosaic.html)

- [ ] __Step 2:__ Wavelet Enhancement of EUV Images for Improved Contrast
  - [ ] SoHO/EIT images: [A Fresh View of the Extreme-Ultraviolet Corona from the Application of a New Image-Processing Technique](https://ui.adsabs.harvard.edu/abs/2008ApJ...674.1201S/abstract) _by G. Stenborg, A. Vourlidas & R.A. Howard_
  - [x] [STEREO/EUVI images](http://solar.jhuapl.edu/Data-Products/EUVI-Wavelets.php) _by the Johns Hopkins University Applied Physics Laboratory_

- [x] __Step 3:__ Homogenization of the SoHO/EIT & STEREO/EUVI Datasets
  - Inspiration: [New Homogeneous Dataset of Solar EUV Synoptic Maps from SOHO/EIT and SDO/AIA](https://link.springer.com/article/10.1007/s11207-019-1563-y) _by A. Hamada, T. Asikainen & K. Mursula_

- [x] __Step 4:__ Composite Synoptic Maps
  - Inspiration: [Creating a Full Sun Map with AIA and EUVI](https://docs.sunpy.org/en/stable/generated/gallery/map_transformations/reprojection_aia_euvi_mosaic.html)

- [ ] __Step 5:__ Generation of a Training Set for the Event
    - _Work in progress on a AWS server_

## Segmentation

- __Examples of Non Machine Learning Methods:__
  - [The SPoCA-suite: Software for extraction, characterization, and tracking of active regions and coronal holes on EUV images](https://www.aanda.org/articles/aa/abs/2014/01/aa21243-13/aa21243-13.html) _by C. Verbeeck, V. Delouille, B. Mampaey & R. De Visscher_
  - [Coronal Hole Observer and Regional Tracker for Long-term Examination (CHORTLE)](https://github.com/lowderchris/CHORTLE) _by C. Lowder_

- __Examples of Supervised Machine Learning Methods:__
  - [Segmentation of Coronal Holes in Solar Disk Images with a Convolutional Neural Network](https://academic.oup.com/mnras/article-abstract/481/4/5014/5113474?redirectedFrom=fulltext) _by E. Illarionov & A. Tlatov_
  - [Machine-Learning Approach to Identification of Coronal Holes in Solar Disk Images and Synoptic Maps](https://arxiv.org/abs/2006.08529) _by E. Illarionov, A. Kosovichev & A. Tlatov_

- __Unsupervised Machine Learning Methods:__
  - Principle: Data clustering.
  - Suggestion: [W-Net: A Deep Model for Fully Unsupervised Image Segmentation](https://arxiv.org/abs/1711.08506) _by X. Xia & B. Kulis_

- [x] __Step 1:__ Write Template for Unsupervised Learning Algorithm
  - [Kmeans & Wnet]

- [x] __Step 2:__ Experiment with Unsupervised Learning Methods
  -[Wnet:] in WNet_SEARCH folder
  -[Kmeans:] 


## Testing

- [x] __Step 0:__ Generation of a Test Set
  - [Database of Coronal Holes Identified by Hand](https://drive.google.com/drive/folders/1WtUW-a6fZvcFKvPwtAY-wYfHLyi1hrF5?usp=sharing) _courtesy of Sam Wallace_

- [x] __Step 1:__ Write Test code
  - IOU & Similarity are use as standard scores to compare between predictions and the database from Step 0 (WNet_SEARCH/Compare.ipynb)
