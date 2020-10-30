%% Generate Figure 4
% Kernel embeddings example showing the First-hitting time problem
% for a 6-D quadrotor system.
%

%%
% Specify the time horizon, the safe set $\mathcal{K}$, and the target set
% $\mathcal{T}$.

N = 5;
K = srt.Tube(N, Polyhedron('lb', [-1 -100 0 -100 -100 -100], ...
                           'ub', [1 100 0.8 100 100 100]));
T = srt.Tube(N, Polyhedron('lb', [-1 -100 0.8 -100 -100 -100], ...
                           'ub', [1 100 100 100 100 100]));

problem = srt.problems.FirstHitting('ConstraintTube', K, 'TargetTube', T);

%% System Definition
% Generate input/output samples for the Planar Quadrotor system
%

% Sampling time.
Ts = 0.25;

% Xd is the 'desired' state, which is defined as hovering at y = 1.
Xd = [0 0 1 0 0 0].';

% Number of elements in each dimension.
el = [10, 3, 10, 3, 3, 2];

X   = linspace( -1.1,    1.1, el(1));
dX  = linspace(    0,   -0.1, el(2));
Y   = linspace( -0.1,      1, el(3));
dY  = linspace( -0.1,    0.1, el(4));
T   = linspace(  -pi,     pi, el(5));
dT  = linspace( -0.1,    0.1, el(6));

% Create a mesh of sample points.
% Note that we need to do this in reverse due to ndgrid.
[dTdT, TT, dYdY, YY, dXdX, XX] = ndgrid(dT, T, dY, Y, dX, X);

% Reshape them into a matrix of samples.
X = reshape(XX, 1, []);
dX = reshape(dXdX, 1, []);
Y = reshape(YY, 1, []);
dY = reshape(dYdY, 1, []);
T = reshape(TT, 1, []);
dT = reshape(dTdT, 1, []);

Xs = [X; dX; Y; dY; T; dT];

% Gain matrix precomputed using LQR.
K = [   -0.3370   -0.6738    0.6396    1.8992    4.9544    2.0982;
         0.3370    0.6738    0.6396    1.8992   -4.9544   -2.0982;];

% Generate input samples.
Us = 0.01*K*(Xs - Xd);

% Generate output samples for a Gaussian disturbance.
Ys = quadrotorDynamics(Xs, Us, Ts, 1);

sys1 = srt.systems.SampledSystem('X', Xs, 'U', Us, 'Y', Ys);

% Generate output samples for a Beta disturbance.
% Note that this requires the betarnd function in Matlab.
Ys = quadrotorDynamics(Xs, Us, Ts, 2);

sys2 = srt.systems.SampledSystem('X', Xs, 'U', Us, 'Y', Ys);

%% Algorithm
% Initialize the algorithm.

alg = srt.algorithms.KernelEmbeddings('sigma', 0.1, 'lambda', 1);

%% Test Points
% Generate the test points.

x = linspace(-1.1, 1.1, 100);
y = linspace(0, 1, 100);
z = zeros(1, 100^2);
[xx, yy] = meshgrid(x, y);
xx = reshape(xx, 1, []);
yy = reshape(yy, 1, []);
Xt = [xx; z; yy; z; z; z];
Ut = zeros(2,size(Xt,2));

%% Call the algorithm.

resultsGauss = SReachPoint(problem, alg, sys1, Xt, Ut);

resultsBeta  = SReachPoint(problem, alg, sys2, Xt, Ut);

%% Plot the results.

width = 80;
height = 137;

figure('Units', 'points', ...
       'Position', [0, 0, 243, 172])

ax1 = subplot(1, 2, 1, 'Units', 'points');
surf(ax1, x, y, reshape(resultsGauss.Pr(1, :), 100, 100), 'EdgeColor', 'none');
view([0 90]);
axis([-1.1 1.1 0.5 1])

colorbar(ax1, 'off');
ax1.Position = [30, 25, width, 137];
ax1.XLabel.Interpreter = 'latex';
ax1.XLabel.String = '$z_{1}$';
ax1.YLabel.Interpreter = 'latex';
ax1.YLabel.String = '$z_{2}$';
set(ax1, 'FontSize', 8);

ax2 = subplot(1, 2, 2, 'Units', 'points');
surf(ax2, x, y, reshape(resultsBeta.Pr(1, :), 100, 100), 'EdgeColor', 'none');
view([0 90]);
axis([-1.1 1.1 0.5 1])

colorbar(ax2);
ax2.YAxis.Visible = 'off';
ax2.Position = [30 + 90, 25, width, 137];
ax2.XLabel.Interpreter = 'latex';
ax2.XLabel.String = '$z_{1}$';
ax2.YLabel.Interpreter = 'latex';
ax2.YLabel.String = '$z_{2}$';
set(ax2, 'FontSize', 8);

% Save the figure as 'figure4'.
saveas(gcf, '../results/figure4.png')
