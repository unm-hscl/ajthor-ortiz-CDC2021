%% Kernel Embeddings Example (First-Hitting Time Problem)
% Kernel embeddings example showing the first-hitting time problem
% for a 6-D quadcopter system.
%
%%
% Specify the time horizon, the safe set $\mathcal{K}$, and the target set
% $\mathcal{T}$.

params.N = 5;
K = srt.Tube(params.N, Polyhedron('lb', [-1 -500 0 -500 -500 -500], 'ub', [1 500 0.8 500 500 500]));
T = srt.Tube(params.N, Polyhedron('lb', [-1 -500 0.8 -500 -500 -500], 'ub', [1 500 500 500 500 500]));

problem = srt.problems.FirstHitting('ConstraintTube', K, 'TargetTube', T);

%% System Definition
% Generate input/output samples for the Planar Quadrotor system
%

% load('.\data\figure4samples.mat');
tic
params.Ts = 0.25;
X_d = [0 0 1 0 0 0]';
params.Xmin = -1.5;
params.Xmax = 1.5;
params.dXmin = 0;
params.dXmax = -0.1;
params.Ymin = -0.3;
params.Ymax = 1.2;
params.dYmin = -0.1;
params.dYmax = 0.1;
params.Tmin = -pi;
params.Tmax = pi;
params.dTmin = -0.1;
params.dTmax = 0.1;
params.el = [10, 3, 10, 3, 3, 2];
params.Umin = -1;
params.Umax = 1;
dtype = 1;

X = linspace(params.Xmin, params.Xmax, params.el(1));
dX = linspace(params.dXmin, params.dXmax, params.el(2));
Y = linspace(params.Ymin, params.Ymax, params.el(3));
dY = linspace(params.dYmin, params.dYmax, params.el(4));
T = linspace(params.Tmin, params.Tmax, params.el(5));
dT = linspace(params.dTmin, params.dTmax, params.el(6));

[dTdT, TT, dYdY, YY, dXdX, XX] = ndgrid(dT, T, dY, Y, dX, X);

X = reshape(XX, 1, []);
dX = reshape(dXdX, 1, []);
Y = reshape(YY, 1, []);
dY = reshape(dYdY, 1, []);
T = reshape(TT, 1, []);
dT = reshape(dTdT, 1, []);

Xs = [X; dX; Y; dY; T; dT];

for k = 1:size(Xs,2)
    Us(:,k) = quadInputGen(60,params.Ts,params.Umax,Xs(:,k),X_d);
end

Us2 = 0.01*Us(1:2,:);
toc
Ys1 = generate_output_samples_quad(params,1);

sys1 = srt.systems.SampledSystem('X', Xs, 'U', Us2, 'Y', Ys1);

Ys2 = generate_output_samples_quad(params,2);

sys2 = srt.systems.SampledSystem('X', Xs, 'U', Us2, 'Y', Ys2);

x = linspace(-1.1, 1.1, 100);
y = linspace(0, 1, 100);
z = zeros(1, 100^2);
[xx, yy] = meshgrid(x, y);
xx = reshape(xx, 1, []);
yy = reshape(yy, 1, []);
Xt = [xx; z; yy; z; z; z];
Ut = zeros(2,size(Xt,2));

%% Algorithm
% Initialize the algorithm.

%algorithm = KernelDistributionEmbeddings(args{:});
alg = srt.algorithms.KernelEmbeddings('sigma', 0.1, 'lambda', 1);

%%
% Call the algorithm.

% Generate test points.
% s = linspace(-1, 1, 100);
% [X1, X2] = meshgrid(s);
s = linspace(-1, 1, 100);
x = linspace(-1.1, 1.1, 100);
y = linspace(0, 1, 100);
z = zeros(1, 100^2);
[xx, yy] = meshgrid(x, y);
xx = reshape(xx, 1, []);
yy = reshape(yy, 1, []);
Xt = [xx; z; yy; z; z; z];
Ut = zeros(2,size(Xt,2));

% Xt = sampleunif(s, s);
% Ut = zeros(1, size(Xt, 2));

resultsGauss = SReachPoint(problem, alg, sys1, Xt, Ut);

resultsBeta = SReachPoint(problem, alg, sys2, Xt, Ut);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Plot the results.
width = 80;
height = 137;

figure('Units', 'points', ...
       'Position', [0, 0, 243, 172])

ax1 = subplot(1, 2, 1, 'Units', 'points');
surf(ax1, x, y, reshape(resultsGauss.Pr(params.N-1, :), 100, 100), 'EdgeColor', 'none');
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
surf(ax2, x, y, reshape(resultsBeta.Pr(params.N-1, :), 100, 100), 'EdgeColor', 'none');
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
