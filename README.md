# RegBenchmark
Benchmarking framework for 3D histology reconstruction algorithms

MATLAB (R2016b) framework used for evaluating the accuracy of reconstruction algorithms for 3D histology based on serial histological sections.

If you use RegBenchmark in a publication, please cite the article:
A Comparison of Algorithms for 3D Tissue Reconstruction from Serial Histological Sections
Kimmo Kartasalo, Leena Latonen, Jorma Vihinen, Tapio Visakorpi, Matti Nykter, Pekka Ruusuvuori
See the article for more information on the various quality metrics computed by the framework.

USAGE:
result = regbenchmark_Main_parallel(inputpath_images,inputpath_masks,inputpath_fiducials,inputpath_originalmasks,pixelsize,slicethickness,resamplingfactor);

INPUT:
inputpath_images - The full path to the folder containing N registered images.

inputpath_masks - The full path to the folder containing N registered binary masks (tissue > 0, background = 0).

inputpath_fiducials - The full path to the folder containing fiducial points (=landmarks) stored as N or 2N-2 registered images.

inputpath_originalmasks - The full path to the folder containing N pre-registration (original) binary masks .

pixelsize - A scalar specifying the size of a single pixel in physical units.

slicethickness - A scalar specifying the section-to-section spacing in physical units.

resamplingfactor - A scalar specifying the amount of resampling to apply to the images before doing the calculations. 1 -> no resampling, < 1 -> downsampling, > 1 -> upsampling.

OUTPUT:
result - A struct containing the input settings, the detected fiducial point locations and the values of accuracy metrics described below.

TRE_pairwise: Euclidean distance between each fiducial point on each pair of adjacent sections. An N-1 x M matrix of pairwise errors for N-1 pairs of images and M fiducial points per pair.

TRE_accumulated: Accumulated error of the fiducial points. If the fiducials extend through the entire series, this represents the residual Euclidean error between the location of the fiducials and a linear least-squares fit through the stack, given as an N x M matrix of errors for N sections and M fiducial point series. If the fiducials are pairwise, this represents the cumulative magnitude of the mean pairwise TRE vector, given as an N-1 x 1 vector of errors for N-1 image pairs.

RMSE: Pixelwise RMS error between each pair of sections computed within the area defined by the binary mask. An N-1 x 1 vector of RMSE values for N-1 pairs of sections.

NCC: Pixelwise normalized cross correlation between each pair of sections computed within the area defined by the binary mask. An N-1 x 1 vector of NCC values for N-1 pairs of sections.

MI: Pixelwise mutual information between each pair of sections computed within the area defined by the binary mask. An N-1 x 1 vector of MI values for N-1 pairs of sections.

NMI: Pixelwise normalized mutual information between each pair of sections computed within the area defined by the binary mask. An N-1 x 1 vector of NMI values for N-1 pairs of sections.

Jaccard: Jaccard index between each pair of sections computed based on the area defined by the binary mask. An N-1 x 1 vector of Jaccard indices for N-1 pairs of sections.

Zcontrast: GLCM-based scalar contrast value for the entire registered stack along the Z-direction.

Zcorrelation: GLCM-based scalar correlation value for the entire registered stack along the Z-direction.
shrinkpercentage: Relative change in tissue area between original and post-registration binary masks.

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
