function [result] = regbenchmark_Main_parallel(inputpath_images,inputpath_masks,inputpath_fiducials,inputpath_originalmasks,pixelsize,slicethickness,resamplingfactor)
%regbenchmark_Main_parallel - Benchmark 3D reconstruction algorithms.
%
%   [result] = regbenchmark_Main_parallel(inputpath_images,inputpath_masks,inputpath_fiducials,inputpath_originalmasks,pixelsize,slicethickness,resamplingfactor)
%   Computes a number of metrics representing the quality of a 3D
%   reconstruction from serial sections. At the moment only images in TIFF
%   format are supported.
%
%   'inputpath_images' is the path to the actual registered image files.
%
%   'inputpath_masks' is the path to binary mask files specifying the
%   region of interest in each actual image.
%
%   'inputpath_fiducials' is the path to the fiducial image files
%   containing fiducial markers for the images.
%
%   'inputpath_originalmasks' is the path to the original (non-aligned)
%   binary mask files specifying the region of interest in each actual
%   image.
%
%   'pixelsize' is the size of pixels in the images.
%
%   'slicethickness' is the interslice spacing.
%
%   'resamplingfactor' allows down- or upsampling the images when computing
%   the quality metrics. For example, a value of 1/2 results in two-fold
%   downsampling. Make sure you adjust the 'pixelsize' value accordingly.
%
%   'result' is a struct containing the quality metrics and input
%   parameters.
%

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

% Get sorted filenames for images, masks and fiducial images.
[filenames_images, filenames_masks, filenames_fiducials] = util_getSortedFilenames(inputpath_images,inputpath_masks,inputpath_fiducials,'.tif');
numimages = length(filenames_images);
numfiducials = length(filenames_fiducials);

% Initialize result arrays.
if numfiducials == numimages
    fiducialpoints = cell(numimages,1);
else
    fiducialpoints = cell(numimages-1,1);
end
t = Tiff([inputpath_images,filesep,filenames_images{1}],'r'); image1 = read(t); close(t);
GLCM = zeros(double(intmax(class(image1))) + 1,double(intmax(class(image1))) + 1,numimages-1);
RMSE = nan(numimages-1,1);
NCC = nan(numimages-1,1);
MI = nan(numimages-1,1);
NMI = nan(numimages-1,1);
Jaccard = nan(numimages-1,1);
shrinkpercentage = nan(numimages,1);

% Loop through images.
parfor imind = 1:numimages-1
    % Read first image and mask.
    t = Tiff([inputpath_images,filesep,filenames_images{imind}],'r'); image1 = read(t); close(t);
    image1 = rgb2gray(image1);
    t = Tiff([inputpath_masks,filesep,filenames_masks{imind}],'r'); image1_mask = read(t); close(t);
    if size(image1_mask,3) > 1
        image1_mask = image1_mask(:,:,1);
    end
    % Resample if required.
    if resamplingfactor ~= 1
        image1 = imresize(image1,resamplingfactor,'bilinear');
        image1_mask = imresize(image1_mask,resamplingfactor,'nearest');
    end
    
    % Read the second image and mask.
    t = Tiff([inputpath_images,filesep,filenames_images{imind+1}],'r'); image2 = read(t); close(t);
    image2 = rgb2gray(image2);
    t = Tiff([inputpath_masks,filesep,filenames_masks{imind+1}],'r'); image2_mask = read(t); close(t);
    if size(image2_mask,3) > 1
        image2_mask = image2_mask(:,:,1);
    end
    % Resample if required.
    if resamplingfactor ~= 1
        image2 = imresize(image2,resamplingfactor,'bilinear');
        image2_mask = imresize(image2_mask,resamplingfactor,'nearest');
    end
    
    % Read the original mask for first image.
    t = Tiff([inputpath_originalmasks,filesep,filenames_masks{imind}],'r'); image1_originalmask = read(t); close(t);
    if size(image1_originalmask,3) > 1
        image1_originalmask = image1_originalmask(:,:,1);
    end
        
    % Compute the change in mask area as a percentage relative to the
    % original mask.
    newmaskarea = sum(image1_mask(:) > 0);
    originalmaskarea = sum(image1_originalmask(:) > 0);
    shrinkpercentage(imind) = 100*(newmaskarea - originalmaskarea)/originalmaskarea;
    
    % There are two fiducial images associated with each image.
    if numfiducials == 2*numimages-2
        % Read the first fiducial image for this image. Resample the
        % fiducial image if required.
        t = Tiff([inputpath_fiducials,filesep,filenames_fiducials{2*imind-1}],'r'); image_fiducial = read(t); close(t);
        if resamplingfactor ~= 1
            image_fiducial = imresize(image_fiducial,resamplingfactor,'bilinear');
        end
        fiducialpoints{imind} = regbenchmark_DetectFiducials(image_fiducial);
        % Read the second fiducial image for this image and append the
        % fiducial points into the fiducial point matrix. Resample the
        % fiducial image if required.
        t = Tiff([inputpath_fiducials,filesep,filenames_fiducials{2*imind}],'r'); image_fiducial = read(t); close(t);
        if resamplingfactor ~= 1
            image_fiducial = imresize(image_fiducial,resamplingfactor,'bilinear');
        end
        fiducialpoints{imind} = [fiducialpoints{imind} regbenchmark_DetectFiducials(image_fiducial)];
    % There is a single fiducial image associated with each image.
    elseif numfiducials == numimages
        % Read the fiducial image for this image and store the fiducial
        % points. Resample the fiducial image if required.
        t = Tiff([inputpath_fiducials,filesep,filenames_fiducials{imind}],'r'); image_fiducial = read(t); close(t);
        if resamplingfactor ~= 1
            image_fiducial = imresize(image_fiducial,resamplingfactor,'bilinear');
        end
        fiducialpoints{imind} = regbenchmark_DetectFiducials(image_fiducial);
    end

    % Sometimes there is a small (typically one pixel) difference in the
    % mask and image sizes due to interpolation error. Make sure the masks
    % are the same size as the image to avoid indexing errors.
    if ~all(size(image1_mask) == size(image1))
        image1_mask = imresize(image1_mask,size(image1),'nearest');
    end
    if ~all(size(image2_mask) == size(image2))
        image2_mask = imresize(image2_mask,size(image2),'nearest');
    end
    % However, all images should be exactly the same size since they're
    % supposed to be on a common 'canvas'. Check this.
    if ~all(size(image1) == size(image2))
        error(['Image size mismatch between ',inputpath_images,filesep,filenames_images{imind},' and ',inputpath_images,filesep,filenames_images{imind+1}]);
    end
    
    % Compute Jaccard index.
    ROIintersection = image1_mask & image2_mask;
    ROIunion = image1_mask | image2_mask;
    Jaccard(imind) = sum(ROIintersection(:))/sum(ROIunion(:));
    % If there are overlapping pixels, compute correspondence measures.
    if any(ROIintersection(:))
        % Pixel-wise correspondences.
        [~,RMSE(imind),NCC(imind),MI(imind),NMI(imind),GLCM(:,:,imind)] = regbenchmark_PixelwiseCorrespondence(image1(ROIintersection),image2(ROIintersection));
    end
end

% Compute the change in mask area for the last image since it was not
% accessed in the for loop.
% Read the mask for the last image.
t = Tiff([inputpath_masks,filesep,filenames_masks{numimages}],'r'); image1_mask = read(t); close(t);
if size(image1_mask,3) > 1
    image1_mask = image1_mask(:,:,1);
end
% Read the original mask for the last image.
t = Tiff([inputpath_originalmasks,filesep,filenames_masks{numimages}],'r'); image1_originalmask = read(t); close(t);
if size(image1_originalmask,3) > 1
    image1_originalmask = image1_originalmask(:,:,1);
end
% Compute the change in mask area as a percentage relative to the
% original mask.
newmaskarea = sum(image1_mask(:) > 0);
originalmaskarea = sum(image1_originalmask(:) > 0);
shrinkpercentage(numimages) = 100*(newmaskarea - originalmaskarea)/originalmaskarea;

% If there is a single fiducial image associated with each image, read the
% last one that was not read within the loop.
if numfiducials == numimages
    t = Tiff([inputpath_fiducials,filesep,filenames_fiducials{numimages}],'r'); image_fiducial = read(t); close(t);
    if resamplingfactor ~= 1
        image_fiducial = imresize(image_fiducial,resamplingfactor,'bilinear');
    end
    fiducialpoints{numimages} = regbenchmark_DetectFiducials(image_fiducial);
end

% Benchmarking: contrast and correlation across the stack.
GLCM = sum(GLCM,3);
stats = graycoprops(GLCM,{'contrast','correlation'});
Zcontrast = stats.Contrast;
Zcorrelation = stats.Correlation;

% Benchmarking: pairwise TRE.
result.TRE_pairwise = pixelsize*regbenchmark_PairwiseTRE(fiducialpoints);

% Benchmarking: accumulated TRE.
% Accumulated TRE relative to linear fits for the liver and brain datasets.
if size(fiducialpoints{1},2) == 2
    [result.TRE_accumulated,result.fittedpoints] = regbenchmark_AccumulatedTRE_linearfit(fiducialpoints,slicethickness/pixelsize);
    result.TRE_accumulated = pixelsize*result.TRE_accumulated;
% Accumulated TRE as the cumulative resultant TRE vector for the prostate dataset.
elseif size(fiducialpoints{1},2) == 4
    [result.TRE_accumulated,result.TRE_accumulated_vectors] = regbenchmark_AccumulatedTRE_cumulative(fiducialpoints);
    result.TRE_accumulated = pixelsize*result.TRE_accumulated;
    result.TRE_accumulated_vectors = pixelsize*result.TRE_accumulated_vectors;
end

% Store the settings.
result.pixelsize = pixelsize;
result.slicethickness = slicethickness;
result.resamplingfactor = resamplingfactor;
result.inputpath_images = inputpath_images;
result.inputpath_masks = inputpath_masks;
result.inputpath_fiducials = inputpath_fiducials;

% Form output structure.
result.fiducialpoints = fiducialpoints;
result.RMSE = RMSE;
result.NCC = NCC;
result.MI = MI;
result.NMI = NMI;
result.Jaccard = Jaccard;
result.Zcontrast = Zcontrast;
result.Zcorrelation = Zcorrelation;
result.shrinkpercentage = shrinkpercentage;