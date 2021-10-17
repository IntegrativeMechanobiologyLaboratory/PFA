# Paracelluar Fluctuations Analyzer
This code takes in a sequence of phase contrast images and quantifies changes in intensity fluctuations along the intercellular boundaries.
In addition to the phase contrast, two other types of input images include: 
* image where cell monolayer is separated from no cell region (monolayer segmented image), 
* image where individual cells are separated from their neighbors (cell segmented image). 

One can use any software to generate these two segmented images. Just ensure that in the first image, monolayer is 255 and no cell region is 0, and cells are 255 and intercellular boundary is 0. In the Paudel et al. manuscript, these segmentations were acheived using the Analysis and Visualization Module of Integrative Toolkit to Analyze Cellular Signaling (Nguyen, Battle, Paudel et al, Under Review).
