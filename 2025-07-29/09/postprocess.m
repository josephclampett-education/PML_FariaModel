BASE_DIRECTORY = "../..";

addpath(BASE_DIRECTORY);

% ================================================================
% PARAMS
% ================================================================

% Saving
VAR_outputFolder = "RES";

%% ================================================================

files = dir(fullfile(VAR_outputFolder, "*.mat"));
threadCount = length(files);

outputData = [];

for i = 1:threadCount
    filePath = fullfile(files(i).folder, files(i).name);
    loadP = load(filePath);
    p = loadP.p;

    [pathstr, name, ext] = fileparts(filePath);
    pathId = fullfile(pathstr, name);

    close all

    %% Setup
    xs = [];
    ys = [];
    for j = 1:size(p.x_data, 2)
        xs = [xs; p.x_data(:, j)];
        ys = [ys; p.y_data(:, j)];
    end

    bounds = [-(p.Rc + 1), (p.Rc + 1)];
    
    %% Figure 1
    figure(1)
    cellcount = 180;
    
    xEdges = linspace(-p.Lx/2, p.Lx/2, cellcount);
    yEdges = linspace(-p.Ly/2, p.Ly/2, cellcount);
    [bins, xEdges, yEdges] = histcounts2(xs, ys, xEdges, yEdges, Normalization="probability");
    gridX = meshgrid(xEdges(1:end-1));
    gridY = meshgrid(yEdges(1:end-1))';
    hold on
    pcolorHandle = pcolor(gridX, gridY, bins);
    set(pcolorHandle, 'EdgeColor', 'none');
    viscircles([0, 0], [p.Rc], 'LineWidth', 0.2, 'LineStyle','--');
    hold off
    
    axis square
    %colorbar
    xlim(bounds)
    ylim(bounds)
    %clim([0.1, 1.7] * 10e-5)

    exportgraphics(gca, pathId + "_histogram.png");

    
    %% Figure 2
    figure(2)
    bincount = 80;
    
    r_data = sqrt(xs.^2 + ys.^2);
    radEdges = linspace(0, p.Rc, bincount);
    radBins = histcounts(r_data, radEdges);
    radCenters = (radEdges(1:end - 1) + radEdges(2:end)) / 2;
    radProb = radBins ./ radCenters;
    radProb = radProb / length(r_data);
    
    j0Domain = (0:0.02:p.Rc);
    J0 = besselj(0, (2*pi) * j0Domain);
    
    hold on
    bar(radCenters, radProb, 'hist');
    plot(j0Domain, abs(J0) * max(radProb), Color="red");
    xlim([0 p.Rc]);
    hold off

    exportgraphics(gca, pathId + "_radial_histogram.png");

    %% Figure 3
    figure(3)
    hold on
    for j = 1:size(p.x_data, 2)
        xs = p.x_data(:, j);
        ys = p.y_data(:, j);

        x_diff = diff(xs);
        y_diff = diff(ys);

        v_data = sqrt(x_diff .^ 2 + y_diff .^ 2);

        v_data = v_data * p.lambdaF / p.TF;

        cline(xs(2:end), ys(2:end), v_data);
        colorbar
    end
    viscircles([0, 0], [p.Rc], 'LineWidth', 0.2, 'LineStyle','--');
    hold off
    
    axis square
    xlim(bounds)
    ylim(bounds)

    exportgraphics(gca, pathId + "_trajectory.png");

    %% Figure 4
    figure(4)
    hold on
    wavefield = p.eta_data(:, :, end);
    contourf(p.xx, p.yy, wavefield, 50, "EdgeColor", "none");
    viscircles([p.x_data(end,:); p.y_data(end,:)]', p.drop_radius / p.lambdaF * ones(1, p.n_drops));
    viscircles([0, 0], [p.Rc], 'LineWidth', 0.2, 'LineStyle','--');
    hold off
    
    axis square
    xlim(bounds)
    ylim(bounds)

    exportgraphics(gca, pathId + "_wavefield.png");
end