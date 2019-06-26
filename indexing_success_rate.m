function [isr_rk, within_threshold_all] = indexing_success_rate(ebsd_comp,...
    ebsd_ref, varargin)
% INDEXING_SUCCESS_RATE Calculate an indexing success rate (ISR) value by
% comparing a given EBSD scan to a reference scan. An orientation in the
% comparison scan is compared against any of the orientations in the kernel
% of neighbouring points in the reference scan.
%
% See Wright, Stuart I., Nowell, Matthew M., Lindeman, Scott P., Camus,
% Patrick P., De Graef, Marc, Jackson, Michael A.: Introduction and comparison
% of new EBSD post-processing methodologies , Ultramicroscopy 159(P1), Elsevier,
% 81–94, 2015 for details.
%
% Input
%  ebsd_comp - @EBSD object, comparison scan
%  ebsd_ref - @EBSD object, reference scan
%  type - string, {'ang' (default), 'osc', 'astro' or 'emsoft'}
%
% Output
%  within_threshold_all - boolean map with pixels within deviation set to
%    true
%  isr_rk - indexing success rate
%
% Options
%  deviation - double, maximum deviation angle to consider match, default is 5
%    degrees
%
% Requires the export_fig package to write figures to file
% (https://se.mathworks.com/matlabcentral/fileexchange/23629-export_fig).
%
% Created by Håkon Wiik Ånes (hakon.w.anes@ntnu.no), 2019-05-10

% Set default values
deviation = 5;
type = 'ang';

% Override default values if passed to function
if check_option(varargin, 'deviation')
    deviation = get_option(varargin, 'deviation');
end
if check_option(varargin, 'type')
    type = get_option(varargin, 'type');
end

% Gridify data sets
ebsd_comp = ebsd_comp.gridify;
ebsd_ref = ebsd_ref.gridify;

[ny, nx] = ebsd_comp.size;
h = waitbar(0, 'Calculating indexing success rate from reference kernel');
within_threshold_all = false(ny, nx);
deviation = deviation*degree;
for i=1:nx
    waitbar(i/nx)
    for j=1:ny
        ori_comp = ebsd_comp(j, i);
                
        % Skip if non-indexed point
        if ismember(type, {'emsoft', 'ang'})
            if isnan(ori_comp.ci)
                continue
            end
        elseif strcmp(type, 'astro')
            if isnan(ori_comp.mae)
                continue
            end
        else % osc
            if isnan(ori_comp.confidenceindex)
                continue
            end
        end

        % Get neighbour orientations in reference data
        neighbours_y = max(j - 1, 1):min(j + 1, ny);
        neighbours_x = max(i - 1, 1):min(i + 1, nx);
        oris_ref = ebsd_ref(neighbours_y, neighbours_x);

        % Compute deviation of orientation to reference orientations
        within_dev = false(1, length(oris_ref));
        for k=1:length(oris_ref)
            within_dev(k) = angle(ori_comp.orientations,...
                oris_ref(k).orientations) < deviation;
        end
        
        % Change to true of the deviation is less than specified threshold
        within_threshold_all(j, i) = any(within_dev);
    end
end
close(h)

isr_rk = sum(within_threshold_all, 'all') / numel(within_threshold_all);
fprintf('ISR_RK = %.4f\n', isr_rk)

% Plot to check
figure
imagesc(within_threshold_all)
colormap bone

end