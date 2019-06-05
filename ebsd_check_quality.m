function ebsd_check_quality(ebsd, out_path, varargin)
% EBSD_CHECK_QUALITY Check quality of indexing of Kikuchi diffraction
% patterns.
%
% Input
%  ebsd - @EBSD object
%  out_path - path to output directory
%
% Options
%  save - bool, if 1 (default), write figures to file.
%  type - string, {'ang' (default), 'osc', 'astro' or 'emsoft'}.
%  to_plot - bool, if 1 (default), show plots and not just save them.
%  scalebar - bool, if 1 (default), show a scalebar.
%  colorbar - bool, if 1 (default), show colorbar.
%
% Assumes the indexing data file from AstroEBSD is created with the
% astroebsd2mtex script found here (https://github.com/hwagit/mtex-snippets).
% 
% Requires the export_fig package to write figures to file
% (https://se.mathworks.com/matlabcentral/fileexchange/23629-export_fig).
%
% Created by Håkon Wiik Ånes (hakon.w.anes@ntnu.no), 2019-02-21

% Set default values
save = 1;
type = 'ang';
to_plot = 1;
scalebar = 1;
colorbar = 1;

% Override default values if passed to function
if check_option(varargin, 'save')
    save = get_option(varargin, 'save');
end
if check_option(varargin, 'type')
    type = get_option(varargin, 'type');
end
if check_option(varargin, 'to_plot')
    to_plot = get_option(varargin, 'to_plot');
end
if check_option(varargin, 'scalebar')
    scalebar = get_option(varargin, 'scalebar');
end
if check_option(varargin, 'colorbar')
    colorbar = get_option(varargin, 'colorbar');
end

% To show figures or not
set(0, 'DefaultFigureVisible', 'on')
if ~to_plot
    set(0, 'DefaultFigureVisible', 'off')
end

% Image resolution
res = '-r200';

% Write mean values for index and reliability to file
if save
    fid = fopen(fullfile(out_path, 'ebsd_quality.dat'), 'w');
    if strcmp(type, 'ang')
        fprintf(fid, 'iq\t\tci\t\tfitn\n%.4f\t%.4f\t%.4f', nanmean(ebsd.iq),...
            nanmean(ebsd.ci), nanmean(ebsd.fit));
    elseif strcmp(type, 'osc')
        fprintf(fid, 'iq\t\tci\t\tfit\n%.4f\t%.4f\t%.4f',...
            nanmean(ebsd.imagequality), nanmean(ebsd.confidenceindex),...
            nanmean(ebsd.fit));
    elseif strcmp(type, 'emsoft')
        fprintf(fid, 'iq\t\tci\n%.4f\t%.4f',...
            nanmean(ebsd.iq), nanmean(ebsd.ci));        
    else % astro
        fprintf(fid, 'pq\t\tps\t\tmae\t\tbn\n%.4f\t%.4f\t%.4f\t%.4f',...
            nanmean(ebsd.pq), nanmean(ebsd.ps), nanmean(ebsd.mae)/degree,...
            nanmean(ebsd.bn));
    end
    fclose(fid);
end

% Plot pattern quality
figure
if ismember(type, {'ang', 'emsoft'})
    [~, mP] = plot(ebsd, ebsd.iq);
    fname = 'quality_iq.png';
elseif strcmp(type, 'osc')
    [~, mP] = plot(ebsd, ebsd.imagequality);
    fname = 'quality_iq.png';
else % astro
    [~, mP] = plot(ebsd, ebsd.pq);
    fname = 'quality_pq.png';
end
mtexColorMap black2white
if colorbar
    mtexColorbar
end
if ~scalebar
    mP.micronBar.visible = 'off';
end
if save
    export_fig(fullfile(out_path, fname), res);
end

% Plot confidence index
figure
if ismember(type, {'ang', 'emsoft'})
    [~, mP] = plot(ebsd, ebsd.ci);
    fname = 'quality_ci.png';
elseif strcmp(type, 'osc')
    [~, mP] = plot(ebsd, ebsd.confidenceindex);
    fname = 'quality_ci.png';
else % astro
    [~, mP] = plot(ebsd, ebsd.ps);
    fname = 'quality_ps.png';
end
mtexColorMap black2white
if colorbar
    mtexColorbar
end
if ~scalebar
    mP.micronBar.visible = 'off';
end
if save
    export_fig(fullfile(out_path, fname), res);
end

% Plot pattern fit
if strcmp(type, 'astro')
    figure
    [~, mP] = plot(ebsd, ebsd.mae);
    fname = 'quality_mae.png';
elseif ismember(type, {'ang', 'osc'})
    figure
    [~, mP] = plot(ebsd, ebsd.fit);
    fname = 'quality_fit.png';
end
if ismember(type, {'ang', 'osc', 'astro'})
    mtexColorMap white2black
    if colorbar
        mtexColorbar
    end
    if ~scalebar
        mP.micronBar.visible = 'off';
    end
    if save
        export_fig(fullfile(out_path, fname), res);
    end
end

% Plot kernel average misorientation
kam = KAM(ebsd, 'threshold', 2*degree);

figure
[~, mP] = plot(ebsd,kam./degree);
if colorbar
    mtexColorbar
end
if ~scalebar
    mP.micronBar.visible = 'off';
end
if save
    export_fig(fullfile(out_path, 'quality_kam.png'), res);
end

end