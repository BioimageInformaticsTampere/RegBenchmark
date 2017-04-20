function [fiducialpoints] = regbenchmark_DetectFiducials(inputimage)
%regbenchmark_DetectFiducials - Detect color-coded fiducial points in image.
%
%   [fiducialpoints] = regbenchmark_DetectFiducials(inputimage)
%   Detects the locations of four fiducial markers in 'inputimage'.
%   The markers are defined as groups of pixels with following colors:
%   Fiducial 1: Red (R > G, G = B)
%   Fiducial 2: Green (G > R, R = B)
%   Fiducial 3: Blue (B > R, R = G)
%   Fiducial 4: Yellow (R > B, R = G)
%   
%   'Fiducialpoints' is a 4x2 matrix containing the [y,x] coordinates of
%   the centroid of each fiducial on each row.
%
%   Class Support
%   -------------
%   Inputimage has to be MxNx3 RGB image.

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

% Find fiducials matching color conditions.
fiducialpoints = NaN(4,2);
% Simpler, faster logical conditions.
[point1y,point1x] = find(inputimage(:,:,1) > inputimage(:,:,2));
[point2y,point2x] = find(inputimage(:,:,2) > inputimage(:,:,1));
[point3y,point3x] = find(inputimage(:,:,3) > inputimage(:,:,1));
[point4y,point4x] = find(inputimage(:,:,1) > inputimage(:,:,3) & inputimage(:,:,1) == inputimage(:,:,2));
% Complete, slower logical conditions.
%[point1y,point1x] = find(inputimage(:,:,1) > inputimage(:,:,2) & inputimage(:,:,2) == inputimage(:,:,3));
%[point2y,point2x] = find(inputimage(:,:,2) > inputimage(:,:,1) & inputimage(:,:,1) == inputimage(:,:,3));
%[point3y,point3x] = find(inputimage(:,:,3) > inputimage(:,:,1) & inputimage(:,:,1) == inputimage(:,:,2));
%[point4y,point4x] = find(inputimage(:,:,1) > inputimage(:,:,3) & inputimage(:,:,1) == inputimage(:,:,2));

% Check if fiducials were found and compute the centroids as the locations of the fiducials.
if isempty(point1y)
    warning('Detection of fiducial 1 failed!');
else
    fiducialpoints(1,1) = mean(point1y);
    fiducialpoints(1,2) = mean(point1x);
end
if isempty(point2y)
    warning('Detection of fiducial 2 failed!');
else
    fiducialpoints(2,1) = mean(point2y);
    fiducialpoints(2,2) = mean(point2x);
end
if isempty(point3y)
    warning('Detection of fiducial 3 failed!');
else
    fiducialpoints(3,1) = mean(point3y);
    fiducialpoints(3,2) = mean(point3x);
end
if isempty(point4y)
    warning('Detection of fiducial 4 failed!');
else
    fiducialpoints(4,1) = mean(point4y);
    fiducialpoints(4,2) = mean(point4x);
end



