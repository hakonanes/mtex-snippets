function [grains, grainsSub,...
    grainsRex] = ebsd_fraction_recrystallised(grains, varargin)
% EBSD_FRACTION_RECRYSTALLISED Determine if a grain is recrystallised.
%
% Input
%  grains - @grains2d object
%
% Options
%  critECD - double, criterium for minimum equivalent circular diameter (ECD).
%    Default is 3 um.
%  critGOS - double, criterium for maximum grain orientation spread (GOS).
%    Default is 2 degrees.
%  critHAB - double, criterium for minimum fraction of high angle grain
%    boundary (HAB). Default is 0.5.
%  to_plot - bool, if 1 (default), show plot of grains.
%  hab - double, lower bound for a high angle boundary (HAB) in
%    degrees. Default is 15 degrees.
%  ebsd - @EBSD object, needs to be passed in if next option is to be used.
%  overlay_metric - for example {ebsd.fit or ebsd.iq}, @EBSD object quality
%    metric to overlay grain boundaries and colouring of subgrains and
%    recrystallised grains.
%  overlay_cmap - bool, mtexColorMap for overlay_metric. 1: black2white,
%    2: white2black. Default is 1.
%
% Returns
%  grains - New @grains2d object containing indexed grains only with a
%    boolean recrystallisation property.
%  grainsSub - New @grains2d object containing grains considered subgrains.
%  grainsRex - New @grains2d object containing grains considered
%    recrystallised.
%
% Example usage:
% [grains, sub, rx] = ebsd_fraction_recrystallised(grains, 'ebsd', ebsd,...
%    'overlay_metric', ebsd.fit, 'overlay_cmap', 2);
%
% The script assumes that the grains object has grains.ECD and grains.Xhab
% properties, and if not assigns these to the grains object.
%
% Created by Håkon Wiik Ånes (hakon.w.anes@ntnu.no), 2019-05-02.

% Set default values
critECD = 3; % [um]
critGOS = 2*degree; % [degrees]
critHAB = 0.5; % fraction
to_plot = 1;
hab = 15;
overlay_cmap = 1;

% Override default values if passed to function
if check_option(varargin, 'critECD')
    critECD = get_option(varargin, 'critECD');
end
if check_option(varargin, 'critGOS')
    critGOS = get_option(varargin, 'critGOS');
end
if check_option(varargin, 'critHAB')
    critHAB = get_option(varargin, 'critHAB');
end
if check_option(varargin, 'to_plot')
    to_plot = get_option(varargin, 'to_plot');
end
if check_option(varargin, 'hab')
    hab = get_option(varargin, 'hab');
end
if check_option(varargin, 'ebsd')
    ebsd = get_option(varargin, 'ebsd');
end
if check_option(varargin, 'overlay_metric')
    overlay_metric = get_option(varargin, 'overlay_metric');
end
if check_option(varargin, 'overlay_cmap')
    overlay_cmap = get_option(varargin, 'overlay_cmap');
end

% Assign ECD and Xhab properties if they do not exist
properties = grains.prop;
if ~isfield(properties, 'ECD')
    grains('indexed').prop.ECD = 0.816*2*grains('indexed').equivalentRadius;
end
if ~isfield(properties, 'Xhab')
    grains = ebsd_fraction_hab(grains, 'hab', hab);
end
    
% New recrystallisation (RX) property, default to zero (subgrain)
grains('indexed').prop.RX = zeros(length(grains('indexed')), 1);

% Set recrystallised grains to 1
grains(grains.phase==0 & grains.ECD > critECD & grains.GOS < critGOS &...
     grains.Xhab > critHAB).RX = 1;

% Get subgrains and recrystallized grains
grainsSub = grains(grains.phase==0 & grains.RX==0);
grainsRex = grains(grains.phase==0 & grains.RX==1);
numGrainsSub = length(grainsSub);
numGrainsRex = length(grainsRex);

% Plot subgrains, recrystallized grains and grain boundaries
if to_plot
    % Separate LABs and HABs
    gb = grains('indexed').boundary('indexed', 'indexed');
    mAngles = gb.misorientation.angle./degree;
    maxmori = max(mAngles);
    minmori = round(min(mAngles), 1);
    [~, ~, gbid] = histcounts(mAngles, 'NumBins', 2, 'BinEdges',...
        [minmori hab maxmori]);

    % Set up figure and legends
    figure
    if exist('overlay_metric', 'var') && exist('ebsd', 'var')
        plot(ebsd, overlay_metric)
        if overlay_cmap == 1
            mtexColorMap black2white
        else
            mtexColorMap white2black
        end
        hold on
    end
    plots = [];
    lgText = {};

    % Set up plots
    if numGrainsSub ~= 0
        p1 = plot(grainsSub, grainsSub.RX, 'facecolor', 'b');
        hold on
        plots = [plots p1(1)];
        lgText{end + 1} = 'Sub';
        alpha(p1, 0.2)
    end
    if numGrainsRex ~= 0
        p2 = plot(grainsRex, grainsRex.RX, 'facecolor', 'r');
        hold on
        plots = [plots p2(1)];
        lgText{end + 1} = 'RX';
        alpha(p2, 0.2)
    end

    % Draw plots
    p3 = plot(gb(gbid==1), 'linecolor', [0.5 0.5 0.5], 'linewidth', 1);
    p4 = plot(gb(gbid==2), 'linecolor', [0 0 0], 'linewidth', 1);
    plot(grains('notindexed'), grains('notindexed').GOS, 'facecolor', 'k')

    % Draw legend
    hold on
    lgText{end + 1} = [num2str(minmori) mtexdegchar ' < LAB < '...
        num2str(hab) mtexdegchar];
    lgText{end + 1} = ['HAB > ' num2str(hab) mtexdegchar];
    l = legend([plots p3(1) p4(1)], lgText);
    set(l.BoxFace, 'ColorType', 'truecoloralpha', 'ColorData',...
            uint8(255*[1; 1; 1; 0.6]));
    l.FontSize = 15;
    l.Location = 'north';
    l.Orientation = 'horizontal';
    l.ItemTokenSize = [10, 10];
end

end