function [TRE,fittedpoints] = regbenchmark_AccumulatedTRE_linearfit(fiducialpoints,Zscaling)
%regbenchmark_AccumulatedTRE_linearfit - Compute target registration errors relative to linear fits.
%
%   [TRE,fittedpoints] = regbenchmark_AccumulatedTRE_linearfit(fiducialpoints,zscaling)
%   Computes Accumulated Target Registration Error (in pixels) for each
%   image based on the locations of fiducial markers provided in
%   'fiducialpoints'. The error is computed relative to lines fitted
%   through the fiducial markers. It is thus assumed that in the case of
%   perfect alignment, markers should be collinear. However, it is not
%   assumed that the holes represented by series of markers would have to
%   be parallel relative to each other or perpendicular to the image plane.
%
%   'fiducialpoints' is a Mx1 cell array with one cell per image. Each cell
%   contains an Nx2 matrix of fiducial point locations. Each image has N fiducial
%   points and each row of the matrix contains the [Y X] coordinates of a
%   single point. In this case the points retain their correspondence from
%   image to image. That is, the point at row N in any cell i corresponds to
%   the point at row N in all other cells.
%
%   'Zscaling' is a scalar specifying the interval of z-planes relative to
%   the in-plane resolution. For example, for a pixel size of 1 �m and a
%   section thickness of 10 �m, 'Zscaling' should be 10.
%
%   'TRE' is a MxN matrix which contains the ATRE values for M images
%   and N fiducial points in pixels.
%
%   'fittedpoints' is a Mx1 cell array with one cell per image. Each cell
%   contains an Nx2 matrix of point locations on the fitted line.

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

% Find out number of images and number of fiducial holes.
numpairs = length(fiducialpoints);
numfiducials = size(fiducialpoints{1},1);

% Initialize result matrix.
fittedpoints = cell(numpairs,1);
TRE = zeros(numpairs,numfiducials);

% Go through all fiducial holes.
for j = 1:numfiducials
    % Get the coordinates of the fiducial hole in 3D space on all sections.
    pointstofitY = zeros(numpairs,1);
    pointstofitX = zeros(numpairs,1);
    pointstofitZ = zeros(numpairs,1);
    for i = 1:numpairs
        pointstofitY(i) = fiducialpoints{i}(j,1); % Y-coordinate.
        pointstofitX(i) = fiducialpoints{i}(j,2); % X-coordinate.
        pointstofitZ(i) = (i-1)*Zscaling; % Z-coordinate.
    end
    
    % Check if some coordinates are NaN i.e. the fiducial point is missing.
    nanpoints = isnan(pointstofitY);
    pointstofitnonanX = pointstofitX(~nanpoints);
    pointstofitnonanY = pointstofitY(~nanpoints);
    pointstofitnonanZ = pointstofitZ(~nanpoints);
    
    % Find the centroid of data points to make sure the line fit goes
    % through the centroid (the LS solution indeed should). This way
    % there's no need to fit constant terms, the X and Y coeffs are enough.
    P = [mean(pointstofitnonanX),mean(pointstofitnonanY),mean(pointstofitnonanZ)]';
    
    % Perform SVD for centered datapoints to minimize orthogonal MSE.
    %[~,~,V] = svd([pointstofitnonanX-P(1),pointstofitnonanY-P(2),pointstofitnonanZ-P(3)]);
    %V = V(:,1);
    
    % Perform ordinary linear LS for centered X and Y separately to minimize
    % MSE on the XY-plane.
    Xcoeff = (pointstofitnonanZ-P(3))\(pointstofitnonanX-P(1));
    Ycoeff = (pointstofitnonanZ-P(3))\(pointstofitnonanY-P(2));
    V = [Xcoeff(1); Ycoeff(1); 1];
    
    % Get the coordinates of the fitted line on all sections.
    % Simultaneously compute the in-plane residual error (ATRE) between the
    % fitted point and the actual datapoint.
    for i = 1:numpairs
        % If the original point is missing, set fitted point and ATRE to NaN.
        if nanpoints(i)
            fittedpoints{i}(j,1) = NaN;
            fittedpoints{i}(j,2) = NaN;
            TRE(i,j) = NaN;
        % Otherwise get the [X,Y] coordinate of the line on this section.
        else
            % Solve parameter t using the known Z coordinate of this
            % section based on the parameteric equation of the line:
            % X = P(1) + t*V(1)
            % Y = P(2) + t*V(2)
            % Z = P(3) + t*V(3)
            t = (pointstofitZ(i) - P(3))/V(3);
            % Solve for the fitted Y-coordinate.
            Y2 = P(2) + t*V(2);
            fittedpoints{i}(j,1) = Y2;
            % Solve for the fitted X-coordinate.
            X2 = P(1) + t*V(1);
            fittedpoints{i}(j,2) = X2;
            % The actual Y-coordinate.
            Y1 = fiducialpoints{i}(j,1);
            % The actual X-coordinate.
            X1 = fiducialpoints{i}(j,2);
            % Calculate the distance between corresponding coordinates.
            TRE(i,j) = sqrt(((Y2-Y1)^2) + ((X2-X1)^2));
        end
    end
end