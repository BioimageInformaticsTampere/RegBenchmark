# RegBenchmark - Benchmarking framework for 3D histology reconstruction algorithms

RegBenchmark is a MATLAB (R2016b) framework for evaluating the accuracy of serial registration algorithms for 3D histology reconstructions based on serial histological sections. The evaluation is based on a panel of metrics including landmark (fiducial) correspondences and pixel-wise similarity metrics. The prerequisite for running the evaluation is to have three sets of images: the actual series of N images depicting the tissue, a series of N binary mask images defining the area of interest in each image and a series of N or 2N-2 images containing up to four landmark points per pair of sections in the form of disks. The binary images specifying the region of interest (e.g. the tissue section) in each image can be obtained by segmentation. If the entire image area contains tissue of interest, binary masks with a value of 1 (or 255 in 8-bit units) everywhere can be supplied. The fiducial points can be collected in any suitable manner, for example by manually annotating corresponding structures on neighboring sections or by using an automated procedure to detect synthetic fiducial markers, such as holes introduced into the specimen. The collection of these annotations is up to the user and depends on the type of dataset. After collecting the coordinates, they have to be stored in the form of fiducial images, as described below. This approach of handling the region of interest and landmark annotations as images is generic in nature and does not depend on the form of transformation model employed by the reconstruction algorithm being studied nor requires any knowledge of the way the algorithm operates, as long as the results of the algorithm can be output as images and re-applied to the masks and fiducial images. 

When performing the series alignment to build a 3D reconstruction of the sample by registering the N images in series, the same transformations applied to the actual images to bring them into alignment should be applied also to the masks and the fiducial images. How to accomplish this depends entirely on the implementation of the serial registration algorithm which is to be evaluated. All three sets of images should thus share the same coordinate system and have identical dimensions. In addition, a fourth set of images representing the binary masks before registration should be available in order to calculate the amount of change in tissue area during registration. If this metric is not of interest, the registered masks can be supplied in the place of non-registered masks, which will result in a tissue area change of 0 %. Currently only TIFF images are supported.

The actual tissue images and binary masks should be named 001.tif, 002.tif ... N.tif in the order corresponding to their Z-location in the sample. The fiducial points can be specified in two different ways. If the fiducials extend through the entire stack of sections (for example holes drilled through the sample) there should be N fiducial images (one fiducial image per section), named identically to the tissue and binary images. The fiducial images should be RGB images and contain disks of different colours (one colour per fiducial) on a black background. Up to four fiducial markers are supported: the first one should be marked by red pixels (255,0,0), the second one by green pixels (0,255,0), the third one by blue pixels (0,0,255) and the fourth one by yellow pixels (255,255,0). The centroid of each group of pixels is detected and used as the coordinate of the fiducial point. The other option is to provide fiducial points in pairwise manner for targets that are only visible on two (or a handful) of neighboring sections. In this case, there should be two RGB images per one tissue image, named for example 001_002.tif and 002_001.tif. The former contains the fiducial points in image 001.tif and the latter contains these same points in image 002.tif. For the next pair of sections (2->3), there should again be two fiducial images 002_003.tif and 003_002.tif, and so on. Because the number of section pairs for N sections is N-1, the fiducial images N_N+1.tif and N+1_N.tif should not exist.

See the article below for more information on the various quality metrics computed by the framework and if you use RegBenchmark in a publication, please cite:  
A Comparison of Reconstruction Algorithms for 3D Histology  
Kimmo Kartasalo, Leena Latonen, Jorma Vihinen, Tapio Visakorpi, Matti Nykter, Pekka Ruusuvuori

USAGE:  
result = regbenchmark_Main_parallel(inputpath_images,inputpath_masks,inputpath_fiducials,inputpath_originalmasks,pixelsize,slicethickness,resamplingfactor);

For example:
result = regbenchmark_Main_paralle('/Data/tissueimages','/Data/tissuemasks','Data/tissuefiducials','Data/originaltissuemasks',0.46,5,1);

INPUT:  
inputpath_images - The full path to the folder containing N registered images.  
inputpath_masks - The full path to the folder containing N registered binary masks (tissue > 0, background = 0).  
inputpath_fiducials - The full path to the folder containing fiducial points (=landmarks) stored as N or 2N-2 registered images.  
inputpath_originalmasks - The full path to the folder containing N pre-registration (original) binary masks.  
pixelsize - A scalar specifying the size of a single pixel in physical units.  
slicethickness - A scalar specifying the section-to-section spacing in physical units.  
resamplingfactor - A scalar specifying the amount of resampling to apply to the images before doing the calculations.  

OUTPUT:  
result.pixelsize, result.slicethickness, result.resamplingfactor, result.inputpath_images, result.inputpath_masks, result.inputpath_fiducials - The settings described above as INPUT.  

result.fiducialpoints - The coordinates of all detected fiducial points.  

result.TRE_pairwise - Euclidean distance between each fiducial point on each pair of adjacent sections.  

result.TRE_accumulated - Accumulated error of the fiducial points. If the fiducials extend through the entire series, this represents the residual Euclidean error between the location of the fiducials and a linear least-squares fit through the stack. If the fiducials are pairwise, this represents the cumulative magnitude of the mean pairwise TRE vector.  

result.TRE_accumulated_vectors - Accumulated error in vector form for each section, in case the fiducials are pairwise.

result.fittedpoints - The coordinates of the linear least-squares fit on each section, in case the fiducials extend through the entire series.

result.RMSE - Pixelwise RMS error between each pair of sections computed within the area defined by the binary mask.  

result.NCC - Pixelwise normalized cross correlation between each pair of sections computed within the area defined by the binary mask. 

result.MI - Pixelwise mutual information between each pair of sections computed within the area defined by the binary mask.

result.NMI - Pixelwise normalized mutual information between each pair of sections computed within the area defined by the binary mask.

result.Jaccard - Jaccard index between each pair of sections computed based on the area defined by the binary mask. 

result.Zcontrast - GLCM-based scalar contrast value for the entire registered stack along the Z-direction.  

result.Zcorrelation - GLCM-based scalar correlation value for the entire registered stack along the Z-direction.  

result.shrinkpercentage - Relative change in tissue area between original and post-registration binary masks.  

CONTACT:  
Kimmo Kartasalo  
kimmo.kartasalo@tut.fi or kimmo.kartasalo@gmail.com  
Tampere University of Technology, Tampere, Finland  
University of Tampere, Tampere, Finland  

LICENSE:  
RegBenchmark, Copyright (c) 2017 Kimmo Kartasalo, Tampere University of Technology  
MATLAB(r). (c) 1984 - 2014 The MathWorks, Inc.  
By using RegBenchmark, you agree to the terms of the disclaimer below and
the GNU General Public License (GPL).

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, 
THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR 
PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS 
BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) 
HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, 
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS 
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 
MATHWORKS AND ITS LICENSORS ARE EXCLUDED FROM ALL LIABILITY FOR DAMAGES OR 
ANY OBLIGATION TO PROVIDE REMEDIAL ACTIONS.
