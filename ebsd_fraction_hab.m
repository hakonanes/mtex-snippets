function [grains] = ebsd_fraction_hab(grains, varargin)
% EBSD_FRACTION_HAB Calculate the fraction of each grain's boundary that
% has a given high angle misorientation to its surrounding grains.
%
% Input
%  grains - @grains2d object
%
% Options
%  hab - double, lower bound for a high angle boundary (HAB) in
%    degrees. Default is 15 degrees.
%  to_plot - bool, if 1 (default), show plot of fraction of HAB.
%
% Returns
%  grains - New @grains2d object, containing only indexed grains, with a Xhab
%    property.
%
% Created by Håkon Wiik Ånes (hakon.w.anes@ntnu.no), 2019-05-02.

% Set default values
hab = 15;
to_plot = 1;

% Override default values if passed to function
if check_option(varargin, 'hab')
    hab = get_option(varargin, 'hab');
end
if check_option(varargin, 'to_plot')
    to_plot = get_option(varargin, 'to_plot');
end

% Get fraction of HAB for each grain
h = waitbar(0, 'Calculating fraction of HAB around each grain');
grain_ids = grains('indexed').id;
numGrains = length(grains('indexed'));
for i = 1:numGrains
    waitbar(i/numGrains)
    id = grain_ids(i);
    % Create logical vector
    try
        isHAB = grains(id).boundary('indexed', 'indexed').misorientation...
            .angle./degree > hab;
        % Create new property of HAB fraction (nnz = number of non-zero)
        grains(id).prop.Xhab = nnz(isHAB)/length(isHAB);
    catch ME
        fprintf('Grain %i is not here!\n', id);
    end
end
close(h)

% Plot fraction HAB
if to_plot
    % Separate LABs and HABs
    gb = grains('indexed').boundary('indexed', 'indexed');
    mAngles = gb.misorientation.angle./degree;
    maxmori = max(mAngles);
    minmori = round(min(mAngles), 1);
    [~, ~, gbid] = histcounts(mAngles, 'NumBins', 2, 'BinEdges',...
        [minmori hab maxmori]);

    figure
    plot(grains('indexed'), grains('indexed').Xhab)
    hold on
    plot(gb(gbid==1), 'linecolor', [0.5 0.5 0.5], 'linewidth', 1)
    plot(gb(gbid==2), 'linecolor', [0 0 0], 'linewidth', 1)
    plot(grains('notindexed'), grains('notindexed').GOS,'facecolor','k')
    mtexColorbar('title', 'Fraction HAB, Xhab')
    hold off
end

end