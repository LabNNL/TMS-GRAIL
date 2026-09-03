function MEP_figure(peaks_cell, aucs_cell, mep_cell, cond, colors)

% Boxplots Peak-to-Peak et AUC, et courbes MEP moyennes +std par condition

n = length(cond);
dark_colors = colors * 0.55;

panel_title_font = {'FontSize', 12, 'FontWeight', 'bold'};
cond_label_font  = {'FontSize', 10, 'FontWeight', 'normal'};

figure('Name', 'TMS-GRAIL - MEP Analysis', 'Color', 'w', 'Position', [100, 100, 1100, 700]);
outer = tiledlayout(2, 1, 'TileSpacing', 'compact', 'Padding', 'compact');

% Panneau du haut
box_layout = tiledlayout(outer, 1, 6, 'TileSpacing', 'compact', 'Padding', 'compact');
box_layout.Layout.Tile = 1;

plot_boxplot(box_layout, 1, peaks_cell, cond, colors, dark_colors, 'Peak-to-Peak Amplitude', 'Amplitude (\muV)', panel_title_font, cond_label_font);
plot_boxplot(box_layout, 4, aucs_cell,  cond, colors, dark_colors, 'Area Under Curve (AUC)',  'AUC (\muV \cdot ms)', panel_title_font, cond_label_font);

% Panneau du bas
mep_layout = tiledlayout(outer, 1, n, 'TileSpacing', 'compact', 'Padding', 'compact');
mep_layout.Layout.Tile = 2;
title(mep_layout, 'Mean MEPs (\pm SD)', panel_title_font{:})

ax_meps = gobjects(1, n);
ylims   = NaN(n, 2);
for c = 1:n
    ax = nexttile(mep_layout, c);
    ax_meps(c) = ax;
    hold(ax, 'on')
    xline(ax, 0, 'Color', 'r', 'LineWidth', 1.5, 'LineStyle', ':');
    if ~isempty(mep_cell{c})
        MEP_mean_fig(mep_cell{c}, colors(c, :));
    end
    box(ax, 'on')
    axis(ax, 'padded')
    xlim(ax, [-100, 200])
    xlabel(ax, "time (ms)")
    title(ax, cond{c}, cond_label_font{:})
    if c == 1
        ylabel(ax, "Amplitude (V)")
    end
    if ~isempty(mep_cell{c})
        ylims(c, :) = ylim(ax);
    end
end

common_ylim = [min(ylims(:, 1)), max(ylims(:, 2))];
for c = 1:n
    ylim(ax_meps(c), common_ylim);
end

end

function plot_boxplot(parent, tile_idx, data_cell, cond, colors, dark_colors, ttl, ylab, panel_title_font, cond_label_font)

n = length(cond);
ax = nexttile(parent, tile_idx, [1, 3]);
hold(ax, 'on')

for c = 1:n
    v = data_cell{c};
    if isempty(v)
        continue
    end
    xg = categorical(repmat(cond(c), length(v), 1), cond);
    boxchart(ax, xg, v, ...
        'BoxFaceColor', colors(c, :), 'BoxFaceAlpha', 0.15, ...
        'BoxEdgeColor', dark_colors(c, :), 'WhiskerLineColor', dark_colors(c, :), ...
        'LineWidth', 1.5, 'BoxWidth', 0.35, 'MarkerStyle', 'none');
end

for c = 1:n
    v = data_cell{c};
    jitter = (rand(size(v)) - 0.5) * 0.2;
    scatter(ax, c + jitter, v, 25, colors(c, :), 'filled', 'MarkerFaceAlpha', 0.6);
end

box(ax, 'on')
grid(ax, 'on')
ylabel(ax, ylab)
title(ax, ttl, panel_title_font{:})
ax.XAxisLocation = 'top';

set(ax, cond_label_font{:})

end