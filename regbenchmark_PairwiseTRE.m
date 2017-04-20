function [TRE] = regbenchmark_PairwiseTRE(fiducialpoints)
%regbenchmark_PairwiseTRE - Compute target registration errors between image pairs.
%
%   [TRE] = regbenchmark_PairwiseTRE(fiducialpoints)
%   Computes Target Registration Error (in pixels) for each pair of images
%   based on the locations of fiducial markers provided in
%   'fiducialpoints'.
%
%   'Fiducialpoints' is a Mx1 cell array with one cell per image or image
%   pair. Each cell contains an Nx2 or Nx4 matrix of fiducial point
%   locations.
%       
%       In the case of an Nx2 matrix, each image has N fiducial
%       points and each row of the matrix contains the [Y X] coordinates of a
%       single point. In this case the points retain their correspondence from
%       image to image. That is, the point at row N in any cell i corresponds to
%       the point at row N in all other cells.
%
%       In the case of an Nx4 matrix, each cell contains the coordinates of
%       fiducials relating image i to image i+1. That is, each pair of images
%       has N associated fiducial points and the points in other image pairs 
%       do not correpond to each other. Each row of the matrix contains the
%       [Y1 X1 Y2 X2] coordinates of a single point in image i and image
%       i+1.
%
%   'TRE' is a MxN matrix which contains the TRE values for M image pairs
%   and N fiducial points.
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

% Find out if the fiducial markers extend through the entire stack or if
% each pair has its own markers.
if size(fiducialpoints{1},2) == 2
    fiducialtype = 'global';
elseif size(fiducialpoints{1},2) == 4
    fiducialtype = 'pairwise';
else
    error('Invalid fiducial point matrix!');
end

% Set number of image pairs.
switch fiducialtype
    % If the fiducials extend through the entire stack, the number of pairs
    % is one less than the number of entries in the fiducialpoints cell,
    % because there will not be a TRE value between image M and M+1.
    case 'global'
        numpairs = length(fiducialpoints)-1;
    % If each pair has its own fiducial markers, the fiducialpoints cell
    % should not contain an entry for image M and thus already has a number
    % of entries corresponding to the number of pairs.
    case 'pairwise'
        numpairs = length(fiducialpoints);
end

% Set number of fiducial markers per image pair.
numfiducials = size(fiducialpoints{1},1);

% Initialize result matrix.
TRE = zeros(numpairs,numfiducials);

% Loop through image pairs.
for i = 1:numpairs
    % Loop through fiducials for each pair.
    for j = 1:numfiducials
        % Get the coordinates of the fiducial points.
        switch fiducialtype
            % If the markers extend through the stack, compute TRE compared to
            % next image.
            case 'global'
                % Coordinates of this fiducial in first image.
                Y1 = fiducialpoints{i}(j,1);
                X1 = fiducialpoints{i}(j,2);
                % Coordinates of this fiducial in second image.
                Y2 = fiducialpoints{i+1}(j,1);
                X2 = fiducialpoints{i+1}(j,2);
            % If each pair has its own markers, compute TRE based on these
            % markers.
            case 'pairwise'
                % Coordinates of this fiducial in first image.
                Y1 = fiducialpoints{i}(j,1);
                X1 = fiducialpoints{i}(j,2);
                % Coordinates of this fiducial in second image.
                Y2 = fiducialpoints{i}(j,3);
                X2 = fiducialpoints{i}(j,4);
        end
        % Calculate the distance between corresponding coordinates.
        TRE(i,j) = sqrt(((Y2-Y1)^2) + ((X2-X1)^2));
    end
end

