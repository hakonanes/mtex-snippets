function [data] = distance_from_grain_boundary(data, boundaries, varargin)
% DISTANCE_FROM_GRAIN_BOUNDARY Return an @EBSD object with the euclidian
% distance in pixels of each measurement to a grain boundary as a property.
% Whether the measurement is a boundary or not is also included as a property
% to the @EBSD object. Edge boundaries are excluded for the distance
% calculation. If a misorientation signifying a high angle boundary
% threshold is passed, the same is also done for these boundaries.
% 
% Input
%  data - @EBSD object
%  boundaries - @grainBoundary object
%
% Options
%  hab - double, misorientation in degrees at which boundaries are considered
%   high angle boundaries (HABs)
%
% Created by Håkon Wiik Ånes (hakon.w.anes@ntnu.no), 2019-07-30

% Set default value and overwrite if passed
hab = 0;
if check_option(varargin, 'hab')
    hab = get_option(varargin, 'hab');
end

% Exclude edge boundaries
outer_boundary_id = any(boundaries.grainId == 0, 2);
boundaries(outer_boundary_id) = [];

% Prepare data properties
data.prop.isBoundary = zeros(data.size);

% Find all boundary segments
h = waitbar(0, 'Finding all boundary segments');
n_boundary_segments = length(boundaries.midPoint);
for i=1:n_boundary_segments
    waitbar(i/n_boundary_segments)
    x = boundaries.midPoint(i, 1);
    y = boundaries.midPoint(i, 2);
    data(x, y).isBoundary = 1;
end
close(h)

% Calculate distance in pixels from boundary segment
bw = data.prop.isBoundary;
bw = reshape(bw, data.gridify.size);
data.prop.distanceFromBoundary = bwdist(bw);

% HABs
if hab
    data.prop.isBoundaryHAB = zeros(data.size);
    boundaries_hab = boundaries(boundaries.misorientation.angle / degree > hab);

    % Find HAB segments
    h = waitbar(0, 'Finding all boundary segments');
    n_hab_segments = length(boundaries_hab.midPoint);
    for i=1:n_hab_segments
        waitbar(i/n_hab_segments)
        x = boundaries_hab.midPoint(i, 1);
        y = boundaries_hab.midPoint(i, 2);
        data(x, y).isBoundaryHAB = 1;
    end
    close(h)
    
    % Calculate distance in pixels from HAB segment
    bwhab = data.isBoundaryHAB;
    bwhab = reshape(bwhab, data.gridify.size);
    data.prop.distanceFromBoundaryHAB = bwdist(bwhab);    
end

end