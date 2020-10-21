%% Generate Table 1
% Note that the 'ParticleOpen' and 'VoronoiOpen' algorithms are omitted,
% since they require a working Gurobi license.
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
profileResults = runperf('tests/profile/ProfileSReachOpen.m', ...
    'Tag', 'NoGurobi');

%% Compile the results.

fullTable = vertcat(profileResults.Samples);

results = varfun(@mean, fullTable, ...
    'InputVariables', 'MeasuredTime', ...
    'GroupingVariables', 'Name');

%% Display the results.

disp(results);

% Save the table as 'table1'.
results = removevars(results, {'GroupCount'});
writetable(results, '../results/table1.txt');
