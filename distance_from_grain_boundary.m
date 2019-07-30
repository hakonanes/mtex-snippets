function [data] = distance_from_grain_boundary(data, grain_boundaries)
% DISTANCE_FROM_GRAIN_BOUNDARY Return an @EBSD object with the euclidian
% distance of each measurement to a grain boundary as a property. Whether
% the measurement is a boundary or not is also included as a property to
% the @EBSD object.
% 
% Input
% data - @EBSD object
% grain_boundaries - @grainBoundary object
%
% Created by Håkon Wiik Ånes (hakon.w.anes@ntnu.no), 2019-07-30

data.prop.isBoundary = zeros(data.size);

% Find boundary segments
h = waitbar(0, 'Finding boundary segments');
n_boundary_segments = length(grain_boundaries.midPoint);
for i=1:n_boundary_segments
    waitbar(i/n_boundary_segments)
    x = grain_boundaries.midPoint(i, 1);
    y = grain_boundaries.midPoint(i, 2);
    data(x, y).isBoundary = 1;
end
close(h)

% Watershed transform
bw = data.isBoundary;
bw = reshape(bw, data.gridify.size);
data.prop.distanceFromBoundary = bwdist(bw);

end