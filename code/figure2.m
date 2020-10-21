%% Generate Figure 2
% Kernel embeddings computation time for a double integrator system.
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
%% Run the performance tests.
profileResults = runperf('tests/profile/ProfileKernelEmbeddings.m');

%% Compile the results.

fullTable = vertcat(profileResults.Samples);

results = varfun(@mean, fullTable, ...
    'InputVariables', 'MeasuredTime', ...
    'GroupingVariables', 'Name');

%% Plot the results.

% The following code assumes there are 25 values of M.

M = 100:100:2500;
KernelEmbeddingsTime = zeros(size(M, 2), 1);

for p = 1:size(M, 2)
    KernelEmbeddingsTime(p) = table2array(results(p, 3));
end

figure('Units', 'points', ...
       'Position', [0, 0, 240, 100]);
hold on
grid on
plot(M, KernelEmbeddingsTime);
ax = gca;
ax.XLabel.String = 'Number of Samples $$M$$';
ax.XLabel.Interpreter = 'latex';
ax.YLabel.String = 'Computation Time [s]';
ax.YLabel.Interpreter = 'latex';
set(ax, 'FontSize', 8);
yticks([0, 0.2, 0.4, 0.6, 0.8])
xlim([100 2500]);
hold off

% Save the figure as 'figure2'.
saveas(gcf, '../results/figure2.png')
