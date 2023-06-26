# Connectome-Rewiring

This repository provides the codes for three key analysis in the manuscript:

S Meamardoost, EJ Hwang, M Bhattacharya, C Ren, L Wang, C Mewes, Y Zhang, T Komiyama, R Gunawan. Rewiring dynamics of functional connectome in motor cortex during motor skill learning. _bioRxiv_, 499746, 2022. [doi:10.1101/2022.07.12.499746](https://doi.org/10.1101/2022.07.12.499746)

### PCA Rewiring

This folder includes MATLAB codes for Principal Component Analysis of functional connectomes during motor skill learning. The functional connectomes were reconstructed via partial correlations using the tool [FARCI](https://github.com/cabsel/FARCI).

### Connectome Activity vs Motor Performance

This folder includes the codes for the analysis of trial-based functional connectome activity and its association with motor performance improvements. The subfolder "Cue to reward surface plot" contains MATLAB codes to generate surface plot of cue-to-reward times versus PC1 and PC2 of trial-based functional connectome activity. Pseudotime analysis code is provided as a Jupyter Notebook file. 

### Linear Decoders

This folder includes MATLAB codes for linear movement decoders for Core, Early Phase, Late Phase and Other neurons. The neuronal spikes data ('all_spikes.mat') can be downloaded from [here](https://drive.google.com/file/d/1fIkB9ruwcz60Wp-5v0ASvuvEyN5xxHrZ/view?usp=sharing).
