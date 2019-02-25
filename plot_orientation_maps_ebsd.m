function plot_orientation_maps_ebsd(file,varargin)
% PLOT_ORIENTATION_MAPS_EBSD Plot orientation maps from EBSD data and write
% them to file.
%
% Input
%  file - string with full path to the .ANG file.
%
% Options
%  type - string, {'oim' (default) or 'astroebsd'}.
%  cs - cell array with crystal symmetries (default is 'notIndexed' and 'Al').
%  mode - string, {'rd' (default), 'om', 'ipf', 'all'}
%  filter - indexing quality metric to filter values by (default is no
%  filtering).
%  filterVal - value to filter by.
% 
% Requires the export_fig package
% (https://se.mathworks.com/matlabcentral/fileexchange/23629-export_fig).
%
% Assumes not indexed pixels are labeled 'notIndexed'.
%
% Created by Håkon Wiik Ånes (hakon.w.anes@ntnu.no), 2019-02-25

% Set default values
type = 'oim';
cs = {'notIndexed',crystalSymmetry('m-3m',[4.04 4.04 4.04],'mineral','Al')};
mode = 'rd';
filter = 0;
filterVal = 0;

% Override default values if passed to function
if check_option(varargin,'type')
    type = get_option(varargin,'type');
end
if check_option(varargin,'cs')
    cs = get_option(varargin,'cs');
end
if check_option(varargin,'mode')
    mode = get_option(varargin,'mode');
end
if check_option(varargin,'filter')
    filter = get_option(varargin,'filter');
end
if check_option(varargin,'filterVal')
    filterVal = get_option(varargin,'filterVal');
end

% Figure options
set(0,'DefaultFigureVisible','off')

% Image resolution
res = '-r200';

% Set specimen directions
if strcmp(type,'oim')
    setMTEXpref('xAxisDirection','east');
    setMTEXpref('zAxisDirection','outOfPlane');
else % astroebsd
    setMTEXpref('xAxisDirection','north');
    setMTEXpref('zAxisDirection','intoPlane');
end

% Read data from file
[path,~,~] = fileparts(file);
if strcmp(type,'oim')
    ebsd = loadEBSD(file,cs,'interface','ang',...
        'convertSpatial2EulerReferenceFrame');
else % astroebsd
    ebsd = loadEBSD(file,cs,'ColumnNames',...
        {'x' 'y' 'euler1' 'euler2' 'euler3' 'pq' 'ps' 'mae' 'bn' 'phase'});
end

% Filter orientations
if strcmp(filter,'mae')
    ebsd = ebsd(ebsd.mae/degree < filterVal);
elseif strcmp(filter,'pq')
    ebsd = ebsd(ebsd.pq > filterVal);
elseif strcmp(filter,'ps')
    ebsd = ebsd(ebsd.ps > filterVal);
elseif strcmp(filter,'ci')
    ebsd = ebsd(ebsd.ci > filterVal);
elseif strcmp(filter,'iq')
    ebsd = ebsd(ebsd.iq > filterVal);
elseif strcmp(filter,'fit')
    ebsd = ebsd(ebsd.fit < filterVal);
end

% Delete possible 'notIndexed' entry in crystal symmetry cell array
for i=1:length(cs)
    if strcmpi(cs{i},'notindexed')
        cs(i) = [];
        break
    end
end

% Get inverse pole figure (IPF) keys
oMs = cell(length(cs));
for i=1:length(cs)
    oM = ipfHSVKey(ebsd(cs{i}.mineral));
    if strcmp(type,'oim')
        oM.inversePoleFigureDirection = xvector;
    else % astroebsd
        oM.inversePoleFigureDirection = yvector;
    end
    oMs{i} = oM;
end

% Plot orientation map with respect to (wrt.) RD
if strcmp(mode,'rd') || strcmp(mode,'all')
    for i=1:length(cs)
        figure
        mineral = cs{i}.mineral;
        oM = oMs{i};
        plot(ebsd(mineral),oM.orientation2color(ebsd(mineral).orientations));
        export_fig(fullfile(path,['omrd_' lower(mineral) '.png']),res)
    end
end

% Plot rest of orientation maps
if strcmp(mode,'om') || strcmp(mode,'all')
    for i=1:length(cs)
        mineral = cs{i}.mineral;
        oM = oMs{i};

        % OM wrt. TD
        if strcmp(type,'oim')
            oM.inversePoleFigureDirection = yvector;
        else % astroebsd
            oM.inversePoleFigureDirection = xvector;
        end
        figure
        plot(ebsd(mineral),oM.orientation2color(ebsd(mineral).orientations));
        export_fig(fullfile(path,['omtd_' lower(mineral) '.png']),res)

        % OM wrt. ND
        oM.inversePoleFigureDirection = zvector;
        figure
        plot(ebsd(mineral),oM.orientation2color(ebsd(mineral).orientations));
        export_fig(fullfile(path,['omnd_' lower(mineral) '.png']),res)
    end
end

% Plot IPFs
if strcmp(mode,'ipf') || strcmp(mode,'all')
    if strcmp(type,'oim')
        directions = {xvector,yvector,zvector};
    else % astroebsd
        directions = {yvector,xvector,zvector};
    end
    fnames = {'rd','td','nd'};
    for i=1:length(cs)
        oM = oMs{i};
        mineral = cs{i}.mineral;
        for j=1:length(directions)
            oM.inversePoleFigureDirection = directions{i};
            figure
            plot(oM)
            hold on
            plotIPDF(ebsd(mineral).orientations,...
                oM.inversePoleFigureDirection,'markersize',3,...
                'markerfacecolor','none','markeredgecolor','k')
            hold off
            export_fig(fullfile(path,...
                ['om_ipf' fnames{j} '_' lower(mineral) '.png']),res)
        end
    end
end

end