function [grains, oris] = ebsd_grains_ideal_orientations(grains, oris, varargin)
% EBSD_GRAINS_IDEAL_ORIENTATIONS Assign an ideal texture component to each
% grain within a given orientation spread.
%
% Input
%  grains - @grains2d object.
%  oris - structure array of ideal orientations.
%
% Options
%  spread - orientation spread in degrees (default is 10 degrees).
% 
% The script assumes that all grains belong to one phase.
%
% Returns
%  grains - New @grains2d object with property giving ideal orientation.
%  oris - input structure array of ideal orientations, now also with number
%    of grains within given orientation spread of given ideal orientation.
%
% Created by Håkon Wiik Ånes (hakon.w.anes@ntnu.no), 2019-05-02.

% Set default values
spread = 10;

% Override default values if passed to function
if check_option(varargin, 'spread')
    spread = get_option(varargin, 'spread');
end

% Get number of grains within given spread of given ideal orientations
ori_names = fieldnames(oris);
for i=1:length(ori_names)
    ori_name = ori_names{i};
    ori = getfield(oris, ori_name);
    grains_ori = findByOrientation(grains('indexed'), ori.symmetrise, spread);
    oris = setfield(oris, ['grains_' lower(ori_name)], grains_ori);
end

% Assign a texture component to each grain (get rid of overlap!)
cs = grains(1).meanOrientation.CS;
ss = grains(1).meanOrientation.SS;
ori_default = orientation.byEuler(1*degree, 0, 0, cs, ss);
grains.prop.ori_ideal = repmat(ori_default, length(grains), 1);

h = waitbar(0, 'Assigning an ideal texture component to each grain');
% Loop over all given ideal texture components
for i = 1:length(ori_names)
    waitbar(i/size(ori_names,2))

    % Loop over all grains within the current texture component
    for j = 1:length(grainsComps{i})
        % Get id of current grain to select the current grain
        condition = grains.phase==0 & grains.id==grainsComps{i}(j).id;
        grainJ = grains(condition);
        % Check if grain already have been assigned an ideal
        % orientation
        if grainJ.idealOri ~= defaultOri
            % Get mean orientation of grain and give specimen symmetry
            grainJOri = orientation(grainJ.meanOrientation,csal,ss);
            % Angle between new ideal orientation and its mean
            % orientation
            newAngle = angle(idealOris{i},grainJOri);
            % Angle between current ideal orientation and its mean
            % orientation
            oldAngle = angle(grainJ.idealOri,grainJOri);
            % Give new ideal orientation if new angle is lower than
            % old angle
            if newAngle < oldAngle
                grains(condition).idealOri = idealOris{i};
            end
        % Give ideal orientation if already not given
        else
            grains(condition).idealOri = idealOris{i};
        end
    end
end
close(h)

% Regroup grains with same ideal orientation
grainsBr = grains(grains.idealOri==br);
grainsCu = grains(grains.idealOri==cu);
grainsCube = grains(grains.idealOri==cube);
grainscubeND = grains(grains.idealOri==cubend);
grainsGoss = grains(grains.idealOri==goss);
grainsP = grains(grains.idealOri==p);
grainsQ = grains(grains.idealOri==q);
grainsS = grains(grains.idealOri==s);

% Volume fraction from grains' mean orientation

fprintf('* Calculate volume fractions from grain mean orientations...\n')
MgBr = 100*sum(grainsBr.area)/sum(grains('Al').area);
MgCu = 100*sum(grainsCu.area)/sum(grains('Al').area);
MgCube = 100*sum(grainsCube.area)/sum(grains('Al').area);
MgcubeND = 100*sum(grainscubeND.area)/sum(grains('Al').area);
MgGoss = 100*sum(grainsGoss.area)/sum(grains('Al').area);
MgP = 100*sum(grainsP.area)/sum(grains('Al').area);
MgQ = 100*sum(grainsQ.area)/sum(grains('Al').area);
MgS = 100*sum(grainsS.area)/sum(grains('Al').area);
MgOther = 100 - (MgBr + MgCu + MgCube + MgcubeND + MgGoss + MgP +...
    MgQ + MgS);

end