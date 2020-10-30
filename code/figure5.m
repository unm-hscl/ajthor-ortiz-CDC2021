%% Generate Figure 5
% Kernel embeddings example showing the Terminal-hitting time problem
% for a Linear(Sys1) and Nonlinear(Sys2) Cart-Pole System.
%

%%
% Specify the time horizon, the safe set $\mathcal{K}$, and the target set
% $\mathcal{T}$.

% Linear system
N1 = 2;

K1 = srt.Tube(N1, Polyhedron('lb', [-0.7 -1 -pi\6 -500], ...
                             'ub', [0.7 1 pi\6 500]));
T1 = srt.Tube(N1, Polyhedron('lb', [-500 -500 -0.05 -500], ...
                             'ub', [500 500 0.05 500]));

problem1 = srt.problems.TerminalHitting('ConstraintTube', K1, 'TargetTube', T1);

% Nonlinear system
N2 = 2;

K2 = srt.Tube(N2, Polyhedron('lb', [-500 -500 -500 -500], ...
                             'ub', [500 500 500 500]));
T2 = srt.Tube(N2, Polyhedron('lb', [-500 -500 -0.05 -500], ...
                             'ub', [500 500 0.05 500]));

problem2 = srt.problems.TerminalHitting('ConstraintTube', K2, 'TargetTube', T2);

%% System Definition
% Generate input/output samples for a linear cart-pole system

% Load Linear cart-pole data.
data1 = load('../data/CartPoleSamples_Linearized.mat');

X1 = data1.X;
U1 = zeros(1, size(X1, 2));
Y1 = data1.Y;

% Load Nonlinear cart-pole data.
data2 = load('../data/CartPoleSamples_Nonlinear.mat');

X2 = data2.X;
U2 = zeros(1, size(X2, 2));
Y2 = data2.Y;

%%
% Create a sample-based stochastic system.

sys1 = srt.systems.SampledSystem('X', X1, 'U', U1, 'Y', Y1);

sys2 = srt.systems.SampledSystem('X', X2, 'U', U2, 'Y', Y2);

%% Algorithm
% Initialize the algorithm.

alg = srt.algorithms.KernelEmbeddings('sigma', 0.1, 'lambda', 1);

%%
% Call the algorithm.
s = linspace(-1, 1, 100);
Xt = sampleunif(s, s);
Xt = [
    zeros(1, size(Xt, 2));
    zeros(1, size(Xt, 2));
    Xt(1, :);
    Xt(2, :)
    ];
Ut = zeros(1, size(Xt, 2));

results1 = SReachPoint(problem1, alg, sys1, Xt, Ut);
results2 = SReachPoint(problem2, alg, sys2, Xt, Ut);

%% Plot the results.

width = 60;
height = 60;
gap = 0;

figure('Units', 'points', ...
       'Position', [0, 0, 504, 100])

ax1 = subplot(1, 6, [1 2], 'Units', 'Points');
data = reshape(results1.Pr(N1-1, :), 100, 100);
ph = surf(ax1, s, s, data);
ph.EdgeColor = 'none';
caxis([0 1]);
view([-15, 60]);
ax1.Color = 'none';

colorbar(ax1, 'off');
ax1.Position = [40 + 0*(width+gap), 25, width*1.5, height];
ax1.XLabel.Interpreter = 'latex';
ax1.XLabel.String = '$\theta$';
ax1.YLabel.Interpreter = 'latex';
ax1.YLabel.String = '$\dot{\theta}$';
ax1.Title.String = '(a)';
set(ax1, 'FontSize', 8);

ax2 = subplot(1, 6, 3, 'Units', 'Points');
data = reshape(results1.Pr(N1-1, :), 100, 100);
ph = surf(ax2, s, s, data);
ph.EdgeColor = 'none';
caxis([0 1]);
view([0 90]);
ax2.Color = 'none';

colorbar(ax2);
ax2.Position = [40 + 2*(width+gap), 25, width, height];
ax2.XLabel.Interpreter = 'latex';
ax2.XLabel.String = '$\theta$';
ax2.YLabel.Interpreter = 'latex';
ax2.YLabel.String = '$\dot{\theta}$';
ax2.Title.String = '(b)';
set(ax2, 'FontSize', 8);

ax3 = subplot(1, 6, [4 5], 'Units', 'Points');
ax3.Units = 'points';
data = reshape(results2.Pr(N2-1, :), 100, 100);
ph = surf(ax3, s, s, data);
ph.EdgeColor = 'none';
caxis([0 1]);
view([-15 60]);
ax3.Color = 'none';

colorbar(ax3, 'off');
ax3.Position = [40 + 4*(width+gap), 25, width*1.5, height];
ax3.XLabel.Interpreter = 'latex';
ax3.XLabel.String = '$\theta$';
ax3.YLabel.Interpreter = 'latex';
ax3.YLabel.String = '$\dot{\theta}$';
ax3.Title.String = '(c)';
set(ax3, 'FontSize', 8);

ax4 = subplot(1, 6, 6, 'Units', 'Points');
ax4.Units = 'points';
data = reshape(results2.Pr(N2-1, :), 100, 100);
ph = surf(ax4, s, s, data);
ph.EdgeColor = 'none';
caxis([0 1]);
view([0 90]);
ax4.Color = 'none';

colorbar(ax4);
ax4.Position = [40 + 6*(width+gap), 25, width, height];
ax4.XLabel.Interpreter = 'latex';
ax4.XLabel.String = '$\theta$';
ax4.YLabel.Interpreter = 'latex';
ax4.YLabel.String = '$\dot{\theta}$';
ax4.Title.String = '(d)';
set(ax4, 'FontSize', 8);

% Save the figure as 'figure5'.
saveas(gcf, '../results/figure5.png')
