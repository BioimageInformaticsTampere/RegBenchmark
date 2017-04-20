function [TRE,TREvectors] = regbenchmark_AccumulatedTRE_cumulative(fiducialpoints)
%regbenchmark_AccumulatedTRE - Compute target registration errors as cumulative errors.
%
%   [TRE,TREvectors] = regbenchmark_AccumulatedTRE(fiducialpoints)
%   Computes Accumulated Target Registration Error (in pixels) for each
%   image based on the locations of fiducial markers provided in
%   'fiducialpoints'. The error is computed by calculating the resultant
%   mean error vector for each image over all fiducial markers and by
%   cumulatively adding up the resultant error vectors. If the resultant
%   errors have random directions from image pair to image pair, it can be
%   assumed that the errors are not accumulating over the sections. If the
%   gross shape of the stack is distorted, the pairwise resultant errors
%   should build up cumulatively.
%
%   'fiducialpoints' is a Mx1 cell array with one cell per image pair.
%   Each cell contains an Nx4 matrix of fiducial point locations.
%   Each cell contains the coordinates of fiducials relating image i to 
%   image i+1. That is, each pair of images has N associated fiducial 
%   points and the points in other image pairs do not correpond to each
%   other. Each row of the matrix contains the [Y1 X1 Y2 X2] coordinates of
%   a single point in image i and image i+1.
%
%   'TRE' is a Mx1 vector which contains the ATRE values for M images
%   in pixels. The ATRE value is the length of the cumulative error vector
%   in the corresponding section.
%
%   'TREvectors' is a Mx2 matrix which contains the resultant error vectors
%   for each image pair in pixels. Each row of the matrix contains the
%   [Y X] components of the resultant error vector of a single image pair.

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

% Find out number of image pairs.
numpairs = length(fiducialpoints);

% Initialize result matrix.
TRE = zeros(numpairs,1);
TREvectors = zeros(numpairs,2);

% Initialize cumulative error vector.
cumerror = [0 0];
% Loop through image pairs.
for i = 1:numpairs
    % Calculate errors in Y and X directions for all fiducial points.
    Yerrors = fiducialpoints{i}(:,3) - fiducialpoints{i}(:,1);
    Xerrors = fiducialpoints{i}(:,4) - fiducialpoints{i}(:,2);
    % Calculate resultant mean error vector for this image pair.
    TREvectors(i,1) = nanmean(Yerrors,1);
    TREvectors(i,2) = nanmean(Xerrors,1);
    % Add the resultant error vector to the cumulative error.
    cumerror = cumerror + TREvectors(i,:);
    % Compute the accumulated TRE as the length of the cumulative error
    % vector on this section.
    TRE(i) = sqrt(cumerror(1)^2 + cumerror(2)^2);
end


