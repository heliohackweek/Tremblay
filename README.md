# SEgmentation of polAR Coronal Holes (SEARCH)

Using unsupervised learning to SEARCH for polar coronal holes in synoptic EUV images.

__Contents__

1. [Data Reduction Pipeline](#data-prep)
2. [Unsupervised Learning for CHs and ARs Segmentation](#segmentation)

---

## Data Prep

__Plan:__ from now until CoolStars 20.5 (March 2-4)

__Objective:__ Generate multi-wavelength (171A, 195A, and 304A) synchronic maps using SoHO/EIT and STEREO/EUVI data for the period 2010 (_included_) to 2015 (excluded).

- [ ] _Step 1:_ Wavelet-enhancement of the imagery for improvised contrast (dark coronal holes, bright active regions):
  - Translation of pre-existing IDL code to Python. This would allow us to be consistent with existing wavelet-enhanced satellite data.
  - Compare results to original paper on enhancement method.
  - Compare EUVI enhanced imagery to existing database (at APL?)
  - Alternative methods have been explored by Ajay. Perform comparisons.

- [ ] _Step 2:_ Combination of maps from three different vantage points (homogenized and wavelet-enhanced):
  - Address issues with SunPy for this step (if some still remain). We previously experienced missing patches where there should have been data.

- [ ] _Step 3:_ Generate synchronic maps:
  - Generate synchronic map at 195A and compare to PSI database synchronic maps at 193A/195A. Maps should be consistent.
  - Once imagery is satisfactory, generate synchronic maps at 171A and 304A. Assess quality (though no direct comparisons are possible).

## Segmentation

__Plan:__ from now until CoolStars 20.5 (March 2-4)

__Objective:__ Identify CHs and ARs boundaries in synchronic maps through unsupervised machine learning methods (W-net, K-means).

- [ ] _Step 1:_ W-net: Train and test with higher resolution single wavelength (193A/195A) imagery, ideally without downsampling synchronic maps.
- [ ] _Step 2:_ W-net: Optimization for CHs and ARs segmentation. As of now, the W-net has been used out-of-the-box, i.e., without modifications.
  - Modify depth of the U-nets.
  - Other tweaks (TBD).

- [ ] _Step 3:_ Once multi-wavelength data is ready, repeat training and testing of K-means and W-net using:
  - Single-wavelength images (i.e., single channel as input)
  - Multi-wavelength images (i.e., multiple channels as input)
  - Study how the boundaries change depending upon the inputs.

- [ ] _Step 4:_ Study properties of polar CHs:
  - Area
  - Polarity

- [ ] _Step 5:_ Matthew has suggested another approach (hierarchical clustering?) To be explored.

---

__Plan:__ beyond CoolStars 20.5 (March 2-4); _Note:_ No specific timeline yet.

__Objective:__ Transition to synoptic maps. Two different datasets are to be considered: SoHO/EIS (22+ years) and SDO/AIA (11 years, more recent data, higher resolution).

- [ ] _Step 1:_ Generalization:
  - Use synoptic maps as inputs into algorithms trained on synchronic maps.

- [ ] _Step 2:_ Training and testing of W-net and K-means using single- or multi-wavelength synoptic maps:
  - First set: SoHO/EIT data
  - Second set: SDO/AIA data
  - Compare predictions to algorithms trained on synchronic maps.

- [ ] _Step 3:_ Study properties of polar CHs as the solar cycle evolves:
  - Area
  - Polarity
