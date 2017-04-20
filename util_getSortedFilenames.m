function [filenames_images, filenames_masks, filenames_fiducials] = util_getSortedFilenames(inputpath_images,inputpath_masks,inputpath_fiducials,ext)
%util_getSortedFilenames - Sort filenames.
%
%   [filenames_images, filenames_masks, filenames_fiducials] = util_getSortedFilenames(inputpath_images,inputpath_masks,inputpath_fiducials,ext)
%   Sorts the filenames of files with extension 'ext' in the folders 
%   specified by'inputpath_images','inputpath_masks' and 
%   'inputpath_fiducials'. The files are sorted assuming they start with a
%   number specifying the position of the image file in the series, for
%   example 001.tif, 002.tif etc. Outputs cell arrays of strings containing
%   the sorted filenames in each of the three folders.

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

if ~isempty(inputpath_images)
    % Get filenames of the images.
    filenames_images = dir([inputpath_images,filesep,'*',ext]);
    filenames_images = {filenames_images.name}';
    numimages = length(filenames_images);
    % Sort them according to leading number.
    slidenumbers = zeros(numimages,1);
    for k=1:numimages
        tempstr = strsplit(filenames_images{k},{'.','_'});
        slidenumbers(k) = str2double(regexp(tempstr{1},'^\d*','match'));
    end
    [~,indx] = sort(slidenumbers);
    filenames_images = filenames_images(indx);
else
    filenames_images = [];
end

if ~isempty(inputpath_masks)
    % Get filenames of the masks. There should be one mask per image.
    filenames_masks = dir([inputpath_masks,filesep,'*',ext]);
    filenames_masks = {filenames_masks.name}';
    nummasks = length(filenames_masks);
    assert(numimages == nummasks,['Number of images ',num2str(numimages),' does not match number of masks ',num2str(nummasks)]);
    % Sort them in the same order as the images.
    filenames_masks = filenames_masks(indx);
else
    filenames_masks = [];
end

if ~isempty(inputpath_fiducials)
    % Get filenames of the fiducial images. There should be either one fiducial
    % image per image (liver and brain datasets) or two fiducial images per
    % image - 2 (prostate dataset).
    filenames_fiducials = dir([inputpath_fiducials,filesep,'*',ext]);
    filenames_fiducials = {filenames_fiducials.name}';
    numfiducials = length(filenames_fiducials);
    assert(numfiducials == numimages | numfiducials == 2*numimages-2,['Number of images ',num2str(numimages),' does not match the number of fiducial images ',num2str(numfiducials)]);
    % Sort them according to one or two leading numbers.
    slidenumbers = zeros(numfiducials,1);
    for k=1:numfiducials
        tempstr = strsplit(filenames_fiducials{k},{'.','_'});
        slidenumbers(k,1) = str2double(regexp(tempstr{1},'^\d*','match'));
        secondarynumber = str2double(regexp(tempstr{2},'^\d*','match'));
        if ~isempty(secondarynumber)
            slidenumbers(k,2) = secondarynumber;
        end
    end
    [~,indx] = sortrows(slidenumbers);
    filenames_fiducials = filenames_fiducials(indx);
else
    filenames_fiducials = [];
end