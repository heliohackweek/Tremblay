# SEgmentation of polAR Coronal Holes (SEARCH)

Using unsupervised learning to SEARCH for polar coronal holes in synoptic EUV images.

__Contents__

1. [Data Reduction Pipeline](#data-prep)
2. [Unsupervised Learning for CHs and ARs Segmentation](#segmentation)

---

## Data Prep

_Plan:_ from now until CoolStars 20.5 (March 2-4)

__ Objective:__ Generate multi-wavelength (171A, 195A, and 304A) synchronic maps using SoHO/EIT and STEREO/EUVI data for the period 2010 (_included_) to 2015 (excluded).

- [ ] __Step 1:__ Wavelet-enhancement of the imagery for improvised contrast (dark coronal holes, bright active regions):
  - Translation of pre-existing IDL code to Python. This would allow us to be consistent with existing wavelet-enhanced satellite data.
  - Compare results to original paper on enhancement method.
  - Compare EUVI enhanced imagery to existing database (at APL?)
  - Alternative methods have been explored by Ajay. Perform comparisons.

- [ ] __Step 2:__ Combination of maps from three different vantage points (homogenized and wavelet-enhanced):
  - Address issues with SunPy for this step (if some still remain). We previously experienced missing patches where there should have been data.

- [ ] __Step 3:__ Generate synchronic maps:
  - Generate synchronic map at 195A and compare to PSI database synchronic maps at 193A/195A. Maps should be consistent.
  - Once imagery is satisfactory, generate synchronic maps at 171A and 304A. Assess quality (though no direct comparisons are possible).

## Segmentation

_Plan:_ from now until CoolStars 20.5 (March 2-4)

__Objective:__ Identify CHs and ARs boundaries in synchronic maps through unsupervised machine learning methods (W-net, K-means).

- [ ] __Step 1:__ W-net: Train and test with higher resolution single wavelength (193A/195A) imagery, ideally without downsampling synchronic maps.
- [ ] __Step 2:__ W-net: Optimization for CHs and ARs segmentation. As of now, the W-net has been used out-of-the-box, i.e., without modifications.
  - Modify depth of the U-nets.
  - Other tweaks (TBD).

- [ ] __Step 3:__ Once multi-wavelength data is ready, repeat training and testing of K-means and W-net using:
  - Single-wavelength images (i.e., single channel as input)
  - Multi-wavelength images (i.e., multiple channels as input)
  - Study how the boundaries change depending upon the inputs.

- [ ] __Step 4:__ Study properties of polar CHs:
  - Area
  - Polarity

- [ ] __Step 5:__ Matthew has suggested another approach (hierarchical clustering?) To be explored.

_Plan:_ beyond CoolStars 20.5 (March 2-4); _Note:_ No specific timeline yet.

__Objective:__ Transition to synoptic maps. Two different datasets are to be considered: SoHO/EIS (22+ years) and SDO/AIA (11 years, more recent data, higher resolution).

- [ ] __Step 1:__ Generalization:
  - Use synoptic maps as inputs into algorithms trained on synchronic maps.

- [ ] __Step 2:__ Training and testing of W-net and K-means using single- or multi-wavelength synoptic maps:
  - First set: SoHO/EIT data
  - Second set: SDO/AIA data
  - Compare predictions to algorithms trained on synchronic maps.

- [ ] __Step 3:__ Study properties of polar CHs as the solar cycle evolves:
  - Area
  - Polarity
