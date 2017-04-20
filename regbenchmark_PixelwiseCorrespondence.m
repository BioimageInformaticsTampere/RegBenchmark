function [MSE,RMSE,NCC,MI,NMI,GLCM] = regbenchmark_PixelwiseCorrespondence(image1,image2)
%regbenchmark_PixelwiseCorrespondence - Compute different measures of image similarity.
%
%   [MSE,RMSE,NCC,MI,NMI,GLCM] = regbenchmark_PixelwiseCorrespondence(image1,image2,pixellist)
%   computes Mean Squared Error (MSE), Root Mean Squared Error (RMSE),
%   Normalized Cross Correlation (NCC), Mutual Information (MI) and
%   Normalized Mutual Information (NMI) between grayscale input images.
%   Also the Gray-level co-occurrence matrix (GLCM) is computed between the
%   image pair. The images must have equal size.
%
%   'image1' and 'image2' are the grayscale images, given as vectors.
%
%   Class Support
%   -------------
%   The grayscale input images have to be int.

% Copyright 2017 Kimmo Kartasalo
% Tampere University of Technology, Tampere, Finland
% Email: kimmo.kartasalo@tut.fi/kimmo.kartasalo@gmail.com
% 
% This file is part of RegBenchmark.
% 
% RegBenchmark is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% RegBenchmark is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with RegBenchmark.  If not, see <http://www.gnu.org/licenses/>.

% Initialize GLCM.
numofvalues = double(intmax(class(image1))) + 1;
GLCM = zeros(numofvalues,numofvalues);

% Convert images to double precision vectors.
image1 = double(image1(:));
image2 = double(image2(:));

% Mean Squared Error (Sum of Squares of Differences).
MSE = mean((image1-image2).^2);

% Root Mean Squared Error.
RMSE = sqrt(MSE);

% Normalized Cross Correlation (Correlation Coefficient).
mean1 = mean(image1);
mean2 = mean(image2);
difference1 = image1-mean1;
difference2 = image2-mean2;
NCC = sum(difference1.*difference2)/sqrt(sum(difference1.^2)*sum(difference2.^2));

% Mutual Information and Normalized Mutual Information.
% Use the intensities of the two images to index the joint histogram. The
% intensities have to be double precision due to the following
% normalization step.
indrow = image1 + 1;
indcol = image2 + 1;
% Calculate the joint histogram by counting the number of pixels with
% each combination of intensity values in the two images.
histJoint = accumarray([indrow indcol],1);
% Calculate histograms for each image.
hist1 = sum(histJoint,2);
hist2 = sum(histJoint,1);
% Normalize by the total number of elements in the image to obtain PDFs.
PDFJoint = histJoint/numel(indrow);
PDF1 = hist1/numel(indrow);
PDF2 = hist2/numel(indrow);
% Get rid of entries corresponding to zero histogram counts to avoid
% trouble with the logarithm.
PDFJoint = PDFJoint(histJoint ~= 0);
PDF1 = PDF1(hist1 ~= 0);
PDF2 = PDF2(hist2 ~= 0);
% Calculate entropies.
entropyJoint = -sum(PDFJoint.*log2(PDFJoint));
entropy1 = -sum(PDF1.*log2(PDF1));
entropy2 = -sum(PDF2.*log2(PDF2));
% Calculate Mutual Information.
MI = entropy1 + entropy2 - entropyJoint;
% Calculate Normalized Mutual Information.
NMI = (entropy1 + entropy2)/entropyJoint;

% Add unity for MATLAB's one-based indexing.
image1 = image1 + 1;
image2 = image2 + 1;
 % Compute GLCM along both directions along the z-axis with distance 1.
GLCM = GLCM + accumarray([image1 image2],1,[numofvalues numofvalues]);
GLCM = GLCM + accumarray([image2 image1],1,[numofvalues numofvalues]);