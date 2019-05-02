function ebsd_plot_orientation_maps(ebsd, out_path, varargin)
% EBSD_PLOT_ORIENTATION_MAPS Plot orientation maps and/or inverse pole figure
% density plots from EBSD data and write them to file.
%
% Input
%  ebsd - @EBSD object
%  out_path - path to output directory
%
% Options
%  type - string, {'ang' (default), 'osc' or 'astro'}.
%  mode - string, {'rd' (default), 'om', 'ipf', 'all'}
%  to_plot - bool, if 1 (default), show plots and not just save them.
%
% Assumes the indexing data file from AstroEBSD is created with the
% astroebsd2mtex script found here (https://github.com/hwagit/mtex-snippets).
% 
% Assumes the following Euler directions for package types:
%   * ang: Xeuler = image east, Zeuler = into image
%   * osc/astro: Xeuler = image north, Zeuler = into image
% 
% Assumes not indexed pixels are labeled 'notIndexed'.
%
% Requires the export_fig package
% (https://se.mathworks.com/matlabcentral/fileexchange/23629-export_fig).
%
% Created by Håkon Wiik Ånes (hakon.w.anes@ntnu.no), 2019-02-25

% Set default values
type = 'ang';
mode = 'rd';
to_plot = 1;

% Override default values if passed to function
if check_option(varargin, 'type')
    type = get_option(varargin, 'type');
end
if check_option(varargin, 'mode')
    mode = get_option(varargin, 'mode');
end

% To show figures or not
set(0, 'DefaultFigureVisible', 'on')
if ~to_plot
    set(0, 'DefaultFigureVisible', 'off')
end

% Image resolution
res = '-r200';

% Set specimen directions
if strcmp(type, 'ang') || strcmp(type, 'osc')
    setMTEXpref('xAxisDirection', 'north');
    setMTEXpref('zAxisDirection', 'intoPlane');
else % astro
    setMTEXpref('xAxisDirection', 'north');
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
    if strcmp(type, 'ang')
        oM.inversePoleFigureDirection = xvector;
    else % osc/astroebsd
        oM.inversePoleFigureDirection = yvector;
    end
    oMs{i} = oM;
end

% Plot orientation map with respect to (wrt.) RD
if strcmp(mode, 'rd') || strcmp(mode, 'om') || strcmp(mode, 'all')
    for i=1:length(cs) % Iterate over crystal symmetries
        figure
        mineral = cs{i}.mineral;
        oM = oMs{i};
        plot(ebsd(mineral), oM.orientation2color(ebsd(mineral).orientations));
        export_fig(fullfile(out_path, ['omrd_' lower(mineral) '.png']), res)
    end
end

% Plot remaining orientation maps
if strcmp(mode, 'om') || strcmp(mode, 'all')
    for i=1:length(cs) % Iterate over crystal symmetries
        mineral = cs{i}.mineral;
        oM = oMs{i};

        % OM wrt. TD
        if strcmp(type, 'ang')
            oM.inversePoleFigureDirection = yvector;
        else % osc/astroebsd
            oM.inversePoleFigureDirection = xvector;
        end
        figure
        plot(ebsd(mineral), oM.orientation2color(ebsd(mineral).orientations));
        export_fig(fullfile(out_path, ['omtd_' lower(mineral) '.png']), res)

        % OM wrt. ND
        oM.inversePoleFigureDirection = zvector;
        figure
        plot(ebsd(mineral), oM.orientation2color(ebsd(mineral).orientations));
        export_fig(fullfile(out_path, ['omnd_' lower(mineral) '.png']), res)
    end
end

% Plot IPFs
if strcmp(mode, 'ipf') || strcmp(mode, 'all')
    if strcmp(type, 'ang')
        directions = {xvector, yvector, zvector};
    else % osc/astroebsd
        directions = {yvector, xvector, zvector};
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
            export_fig(fullfile(out_path,...
                ['om_ipf' fnames{j} '_' lower(mineral) '.png']), res)
        end
    end
end

end