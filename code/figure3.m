%% Generate Figure 3
% Kernel Embedding example showing the First-hitting time problem for a 
% double integrator system. Comparison of KernelDistributionEmbedding 
% algorithm to KernelDistributionEmbeddingRFF algorithm, and including
% dynamic programing comparison.
%
% The computation times are obtained using Matlab's performance testing
% framework. The algorithms are written as unit tests, and the performance
% testing framework runs the tests 4 times to warm up the machine and then
% between 4 and 256 times to reach a sample mean with a 0.05 relative margin of
% error within a 0.95 confidence level.
%
% The results are machine-dependent, and may not match the computation times
% obtained in the paper.
% 
%%
% Specify the time horizon $\mathcal{N}$, the safe set $\mathcal{K}$, and
% the target set $\mathcal{T}$.

N = 5;
K = srt.Tube(N, Polyhedron('lb', [-1 -1], 'ub', [1 1]));
T = srt.Tube(N, Polyhedron('lb', [-0.5 -0.5], 'ub', [0.5 0.5]));

problem = srt.problems.FirstHitting('ConstraintTube', K, 'TargetTube', T);

%% System Definition
% Generate input/output samples for a double integrator system.

s = linspace(-1.1, 1.1, 50);
X = sampleunif(s, s);
U = zeros(1, size(X, 2));
W = 0.01.*randn(size(X));

A = [1, 0.25; 0, 1];
B = [0.03125; 0.25];

Y = A*X + B*U + W;

% Load the dynamic programming results for the comparison plots.
load('../data/DynamicProgrammingFHT.mat')

%% Create a sample-based stochastic system.

sys = srt.systems.SampledSystem('X', X, 'U', U, 'Y', Y);

%% Algorithm
% Initialize the algorithm.

alg1 = srt.algorithms.KernelEmbeddings('sigma', 0.1, 'lambda', 1);
alg2 = srt.algorithms.KernelEmbeddingsRFF('sigma', 0.1, 'lambda', 1, 'D', 15000);

%% Call the algorithm.

s = linspace(-1, 1, 100);
Xt = sampleunif(s, s);
Ut = zeros(1, size(Xt, 2));

results1 = SReachPoint(problem, alg1, sys, Xt, Ut);
results2 = SReachPoint(problem, alg2, sys, Xt, Ut);

%% View the results.

width = 60;
height = 60;

figure('Units', 'points', ...
       'Position', [0, 0, 510, 100])

ax1 = subplot(1, 5, 1, 'Units', 'points');
data = squeeze(PrDP(1, :, :));
ph = surf(ax1, s, s, data);
ph.EdgeColor = 'none';
caxis([0 1]);
view([0 90]);

colorbar(ax1, 'off');
ax1.Position = [30, 25, width, height];
ax1.YLabel.Interpreter = 'latex';
ax1.YLabel.String = '$x_{2}$';
ax1.Title.String = '(a)';
set(ax1, 'FontSize', 8, 'Fontweight', 'bold');

ax2 = subplot(1, 5, 2, 'Units', 'points');
data = reshape(results1.Pr(1, :), 100, 100);
ph = surf(ax2, s, s, data);
ph.EdgeColor = 'none';
caxis([0 1]);
view([0 90]);

colorbar(ax2, 'off');
ax2.YAxis.Visible = 'off';
ax2.Position = [30 + 90, 25, width, height];
ax2.YLabel.Interpreter = 'latex';
ax2.YLabel.String = '$x_{2}$';
ax2.Title.String = '(b)';
set(ax2, 'FontSize', 8, 'Fontweight', 'bold');

ax3 = subplot(1, 5, 3, 'Units', 'points');
data = abs(reshape(results1.Pr(1, :), 100, 100) - squeeze(PrDP(1, :, :)));
ph = surf(ax3, s, s, data);
ph.EdgeColor = 'none';
caxis([0 1]);
view([0 90]);

colorbar(ax3, 'off');
ax3.YAxis.Visible = 'off';
ax3.Position = [30 + 180, 25, width, height];
ax3.XLabel.Interpreter = 'latex';
ax3.XLabel.String = '$x_{1}$';
ax3.YLabel.Interpreter = 'latex';
ax3.YLabel.String = '$x_{2}$';
ax3.Title.String = '(c)';
set(ax3, 'FontSize', 8, 'Fontweight', 'bold');

ax4 = subplot(1, 5, 4, 'Units', 'points');
data = reshape(results2.Pr(1, :), 100, 100);
ph = surf(ax4, s, s, data);
ph.EdgeColor = 'none';
caxis([0 1]);
view([0 90]);

colorbar(ax4, 'off');
ax4.YAxis.Visible = 'off';
ax4.Position = [30 + 270, 25, width, height];
ax4.YLabel.Interpreter = 'latex';
ax4.YLabel.String = '$x_{2}$';
ax4.Title.String = '(d)';
set(ax4, 'FontSize', 8, 'Fontweight', 'bold');

ax5 = subplot(1, 5, 5, 'Units', 'points');
data = abs(reshape(results2.Pr(1, :), 100, 100) - squeeze(PrDP(1, :, :)));
ph = surf(ax5, s, s, data);
ph.EdgeColor = 'none';
caxis([0 1]);
view([0 90]);

colorbar(ax5);
ax5.YAxis.Visible = 'off';
ax5.Position = [30 + 360, 25, width, height];
ax5.YLabel.Interpreter = 'latex';
ax5.YLabel.String = '$x_{2}$';
ax5.Title.String = '(e)';
set(ax5, 'FontSize', 8, 'Fontweight', 'bold');


% Save the figure as 'figure3'.
saveas(gcf, '../results/figure3.png')
