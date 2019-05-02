function [ebsd_new] = ebsd_denoise(ebsd, filter, varargin)
% EBSD_DENOISE Denoise EBSD data following these steps:
%   1. Reconstruct grains (including the smallest grains in the bigger grains
%   based upon a given minimum pixel threshold) with a given misorientation
%   angle threshold (mat).
%   2. Denoise with a given filter while filling in not indexed pixels.
%   3. Reconstruct grains again with a different given mat, still including the
%   smallest grains in the bigger grains. Grains are also smoothed.
%   4. Denoise again with the given filter while filling in not indexed
%   pixels.
%
% The script assumes:
%   * low quality pixels are removed, for example by calling
%     ebsd = ebsd(ebsd.fit > 2).phase = -1;
%   * that the EBSD object only has one phase if plotting to assertain quality
%     of denoising is desired.
% 
% Input
%  ebsd - @EBSD object.
%  filter - @Filter object.
%
% Options
%  type - string, {'ang' (default), 'osc' or 'astro'}.
%  to_plot - bool, if 1 (default), show plots to assert quality of denoising.
%  mat1 - double, mat of first grain reconstruction in degrees.
%  mat2 - double, mat of second grain reconstruction in degrees.
%  minPx - int, minimum grain size in pixels.
%
% Returns
%  ebsd_new - Denoised @EBSD object.
% 
% Created by Håkon Wiik Ånes (hakon.w.anes@ntnu.no), 2019-05-02.

% Set default values
type = 'ang';
to_plot = 1;
mat1 = 5;
mat2 = 0.5;
minPx = 8;

% Override default values if passed to function
if check_option(varargin, 'type')
    type = get_option(varargin, 'type');
end
if check_option(varargin, 'to_plot')
    to_plot = get_option(varargin, 'to_plot');
end
if check_option(varargin, 'mat1')
    mat1 = get_option(varargin, 'mat1');
end
if check_option(varargin, 'mat2')
    mat2 = get_option(varargin, 'mat2');
end
if check_option(varargin, 'minPx')
    minPx = get_option(varargin, 'minPx');
end

% Set specimen directions
if strcmp(type, 'ang') || strcmp(type, 'osc')
    setMTEXpref('xAxisDirection', 'north');
    setMTEXpref('zAxisDirection', 'intoPlane');
else % astro
    setMTEXpref('xAxisDirection', 'north');
    setMTEXpref('zAxisDirection', 'intoPlane');
end

% Keep original data for plotting
ebsd2 = ebsd;

% 1. Reconstruct grains
fprintf('* Reconstructing grains...\n')
mat1 = mat1*degree; % Radians
[grains, ebsd2.grainId, ebsd2.mis2mean] = calcGrains(ebsd2, 'angle', mat1);
ebsd2(grains(grains.grainSize < minPx)) = [];
[~, ebsd2.grainId, ebsd2.mis2mean] = calcGrains(ebsd2, 'angle', mat1);

% 2. Denoise
fprintf('* Denoising...\n')
ebsd3 = smooth(ebsd2, filter, 'fill');

% 3. Reconstruct grains again
fprintf('* Reconstructing grains again...\n')
mat2 = mat2*degree;
ebsd4 = ebsd3;
[grains, ebsd4.grainId, ebsd4.mis2mean] = calcGrains(ebsd4, 'angle', mat2);
ebsd4(grains(grains.grainSize < minPx)) = [];
[grains, ebsd4.grainId, ebsd4.mis2mean] = calcGrains(ebsd4, 'angle', mat2);
grains = smooth(grains, 5);

% 4. Denoise again
fprintf('* Denoising again...\n')
ebsd_new = smooth(ebsd4, filter, 'fill');

% Assert quality of denoising
if to_plot
    fprintf('* Plotting...\n')

    % Plot original EBSD data
    figure
    plot(ebsd('indexed'), ebsd('indexed').orientations)
    mtexTitle('Original EBSD data')
    
    % Plot EBSD after first denoising
    figure
    plot(ebsd3('indexed'), ebsd3('indexed').orientations)
    mtexTitle('EBSD after 1st denoising')
    
    % Separate LABs and HABs
    gb = grains('indexed').boundary('indexed', 'indexed');
    mAngles = gb.misorientation.angle./degree;
    maxmori = max(mAngles);
    hagb = 15;
    [~, ~, gbid] = histcounts(mAngles, 'NumBins', 2, 'BinEdges',...
        [mat2 hagb maxmori]);

    % Plot EBSD and grain boundaries after second denoising
    figure
    plot(ebsd_new('indexed'), ebsd_new('indexed').orientations)
    hold on
    plot(gb(gbid==1), 'linecolor', [0.7 0.7 0.7], 'linewidth', 1)
    plot(gb(gbid==2), 'linecolor', [0 0 0], 'linewidth', 1)
    plot(grains('notindexed'), grains('notindexed').GOS, 'facecolor', 'k')
    mtexTitle('EBSD and GBs after 2nd denoising')
    hold off
end

end