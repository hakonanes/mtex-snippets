function ebsd_plot_orientation_maps(ebsd, out_path, varargin)
% EBSD_PLOT_ORIENTATION_MAPS Plot orientation maps and/or inverse pole figure
% density plots from EBSD data and write them to file.
%
% Input
%  ebsd - @EBSD object
%  out_path - path to output directory
%
% Options
%  save - bool, if 1 (default), write figures to file.
%  type - string, {'ang' (default), 'osc', 'astro' or 'emsoft'}.
%  mode - string, {'rd' (default), 'om', 'ipf', 'all'}.
%  to_plot - bool, if 1 (default), show plots and not just save them.
%  scalebar - bool, if 1 (default), show a scalebar.
%
% Assumes the indexing data file from AstroEBSD is created with the
% astroebsd2mtex script found here (https://github.com/hwagit/mtex-snippets).
% 
% Assumes the following Euler directions for package types:
%   * ang/astro/emsoft: Xeuler = image north, Zeuler = into image.
%   * osc: Xeuler = image east, Zeuler = into image.
%
% Assumes not indexed pixels are labeled 'notIndexed'.
%
% Requires the export_fig package
% (https://se.mathworks.com/matlabcentral/fileexchange/23629-export_fig).
%
% Created by Håkon Wiik Ånes (hakon.w.anes@ntnu.no), 2019-02-25

% Set default values
save = 1;
type = 'ang';
mode = 'rd';
to_plot = 1;
scalebar = 1;

% Override default values if passed to function
if check_option(varargin, 'save')
    save = get_option(varargin, 'save');
end
if check_option(varargin, 'type')
    type = get_option(varargin, 'type');
end
if check_option(varargin, 'mode')
    mode = get_option(varargin, 'mode');
end
if check_option(varargin, 'to_plot')
    to_plot = get_option(varargin, 'to_plot');
end
if check_option(varargin, 'scalebar')
    scalebar = get_option(varargin, 'scalebar');
end

% To show figures or not
set(0, 'DefaultFigureVisible', 'on')
if ~to_plot
    set(0, 'DefaultFigureVisible', 'off')
end

% Image resolution
res = '-r200';

% Set specimen directions
if ismember(type, {'ang', 'astro', 'emsoft'})
    setMTEXpref('xAxisDirection', 'north');
    setMTEXpref('zAxisDirection', 'intoPlane');
else % osc
    setMTEXpref('xAxisDirection', 'east');
    setMTEXpref('zAxisDirection', 'intoPlane');
end

% Delete possible 'notIndexed' entry in crystal symmetry cell array
cs = ebsd.CS;
if isa(cs, 'cell')
    for i=1:length(cs)
        if strcmpi(cs{i}, 'notindexed')
            cs(i) = [];
            break
        end
    end
else % Make the single crystalSymmetry object into a cell to enable iteration
    cs = {cs};
end
    
% Get inverse pole figure (IPF) keys
oMs = cell(length(cs));
for i=1:length(cs) % Iterate over crystal symmetries
    oM = ipfHSVKey(ebsd(cs{i}.mineral));
    if ismember(type, {'ang', 'astro'})
        oM.inversePoleFigureDirection = xvector;
    else % osc/emsoft
        oM.inversePoleFigureDirection = yvector;
    end
    oMs{i} = oM;
end

% Plot orientation map with respect to (wrt.) RD
if ismember(mode, {'rd', 'om', 'all'})
    for i=1:length(cs) % Iterate over crystal symmetries
        figure
        mineral = cs{i}.mineral;
        oM = oMs{i};
        [~, mP] = plot(ebsd(mineral),...
            oM.orientation2color(ebsd(mineral).orientations));
        if ~scalebar
            mP.micronBar.visible = 'off';
        end
        if save
            export_fig(fullfile(out_path, ['omrd_' lower(mineral) '.png']), res)
        end
    end
end

% Plot remaining orientation maps
if ismember(mode, {'om', 'all'})
    for i=1:length(cs) % Iterate over crystal symmetries
        mineral = cs{i}.mineral;
        oM = oMs{i};

        % OM wrt. TD
        if ismember(type, {'ang', 'astro'})
            oM.inversePoleFigureDirection = yvector;
        elseif strcmp(type, 'osc')
            oM.inversePoleFigureDirection = xvector;
        else % emsoft
            oM.inversePoleFigureDirection = zvector;
        end
        figure
        [~, mP] = plot(ebsd(mineral),...
            oM.orientation2color(ebsd(mineral).orientations));
        if ~scalebar
            mP.micronBar.visible = 'off';
        end
        if save
            export_fig(fullfile(out_path, ['omtd_' lower(mineral) '.png']), res)
        end

        % OM wrt. ND
        if strcmp(type, 'emsoft')
            oM.inversePoleFigureDirection = xvector;
        else % ang/astro/osc
            oM.inversePoleFigureDirection = zvector;
        end
        
        figure
        [~, mP] = plot(ebsd(mineral),...
            oM.orientation2color(ebsd(mineral).orientations));
        if ~scalebar
            mP.micronBar.visible = 'off';
        end
        if save
            export_fig(fullfile(out_path, ['omnd_' lower(mineral) '.png']), res)
        end
    end
end

% Plot IPFs
if strcmp(mode, 'ipf') || strcmp(mode, 'all')
    if ismember(type, {'ang', 'astro'})
        directions = {xvector, yvector, zvector};
    elseif strcmp(type, 'osc')
        directions = {yvector, xvector, zvector};
    else % emsoft
        directions = {yvector, zvector, xvector};
    end
    fnames = {'rd', 'td', 'nd'};
    for i=1:length(cs) % Iterate over crystal symmetries
        oM = oMs{i};
        mineral = cs{i}.mineral;
        for j=1:length(directions)
            oM.inversePoleFigureDirection = directions{j};
            figure
            plot(oM)
            hold on
            plotIPDF(ebsd(mineral).orientations,...
                oM.inversePoleFigureDirection, 'markersize', 3,...
                'markerfacecolor', 'none', 'markeredgecolor', 'k')
            hold off
            if save
                export_fig(fullfile(out_path,...
                    ['om_ipf' fnames{j} '_' lower(mineral) '.png']), res)
            end
        end
    end
end

end