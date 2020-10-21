function results = KernelEmbeddings_impl(prob, sys, x0, u0, varargin)
% KERNELEMBEDDINGS_IMPL Implementation of the KernelEmbeddings algorithm.
%
%   Requires SReachTools for the problem and system definittions.
%
%   Usage: KERNELEMBEDDINGS_IMPL(prob, sys, x0, u0)
%
%   Inputs:
%       prob    - Problem definition. This can be one of:
%                 srt.problems.TerminalHitting, srt.problems.FirstHitting,
%                 srt.problems.Viability.
%       sys     - System definition. KERNELEMBEDDINGS_IMPL uses the
%                 srt.systems.SampledSystem to hold the samples X, U, and Y.
%       x0      - Initial condition to compute the safety probabilities for.
%       u0      - Initial control action chosen at x0.
%
%   Outputs:
%       results - Results structure containing the computed safety probabilities
%                 from the algorithm. Note that the safety probabilities are
%                 stored in results.Pr, a matrix where the columns correspond to
%                 the initial conditions (x0, u0), and the rows correspond to
%                 the safety probabilities at different times [0, N].
%
% See also: srt.algorithms.KernelEmbeddings

p = inputParser;
addRequired(p, 'prob');
addRequired(p, 'sys');
addRequired(p, 'x0');
parse(p, prob, sys, x0, varargin{:});

import srt.*

% Constants

N = prob.TimeHorizon;

M = sys.length;
Mt = size(x0, 2);

sigma = 0.1;
lambda = 1;

t_start = tic;

% Compute weight matrix.

Gx = compute_autocovariance(sys.X, sigma);
Gu = compute_autocovariance(sys.U, sigma);

G = Gx.*Gu;

W = inv(G + lambda*M*eye(M));

% Compute value functions.

Vk = zeros(N, M);

cxy = compute_cross_covariance(sys.X, sys.Y, sigma);
cuv = compute_cross_covariance(sys.U, sys.U, sigma);

beta = cxy.*cuv;
beta = W*beta; %#ok<*MINV>
beta = normalize_beta(beta);

switch class(prob)
    case 'srt.problems.FirstHitting'

        Vk(N, :) = prob.TargetTube.contains(N, sys.Y);

        for k = N-1:-1:2
            Vk(k, :) = prob.TargetTube.contains(k, sys.Y) + ...
                       (prob.ConstraintTube.contains(k, sys.Y) & ...
                        ~prob.TargetTube.contains(k, sys.Y)).*(Vk(k+1, :)*beta);
        end

    case 'srt.problems.TerminalHitting'

        Vk(N, :) = prob.TargetTube.contains(N, sys.Y);

        for k = N-1:-1:2
            Vk(k, :) = prob.ConstraintTube.contains(k, sys.Y).*(Vk(k+1, :)*beta);
        end

    case 'srt.problems.Viability'

        Vk(N, :) = prob.ConstraintTube.contains(N, sys.Y);

        for k = N-1:-1:2
            Vk(k, :) = prob.ConstraintTube.contains(k, sys.Y).*(Vk(k+1, :)*beta);
        end

end

% Compute probabilities for point.

Pr = zeros(N, Mt);

cxt = compute_cross_covariance(sys.X, x0, sigma);
cut = compute_cross_covariance(sys.U, u0, sigma);

beta = cxt.*cut;
beta = W*beta;
beta = normalize_beta(beta);

switch class(prob)
    case 'srt.problems.FirstHitting'

        Pr(N, :) = prob.TargetTube.contains(N, x0);

        for k = N-1:-1:1
            Pr(k, :) = prob.TargetTube.contains(k, x0) + ...
                       (prob.ConstraintTube.contains(k, x0) & ...
                        ~prob.TargetTube.contains(k, x0)).*(Vk(k+1, :)*beta);
        end

    case 'srt.problems.TerminalHitting'

        Pr(N, :) = prob.TargetTube.contains(N, x0);

        for k = N-1:-1:1
            Pr(k, :) = prob.ConstraintTube.contains(k, x0).*(Vk(k+1, :)*beta);
        end

    case 'srt.problems.Viability'

        Pr(N, :) = prob.ConstraintTube.contains(N, x0);

        for k = N-1:-1:1
            Pr(k, :) = prob.ConstraintTube.contains(k, x0).*(Vk(k+1, :)*beta);
        end

end

t_elapsed = toc(t_start);

results = struct;
results.Pr = Pr;
results.time = t_elapsed;

end

%% Helper Functions.
% Helper functions for computing the kernel and the Gram matrices.

function n = compute_norm(x)
    % COMPUTE_NORM Compute the norm.
    M = size(x, 2);
    n = zeros(M);

    for k = 1:size(x, 1)
        n = n + (repmat(x(k, :), [M, 1]) - repmat(x(k, :)', [1, M])).^2;
    end
end

function n = compute_norm_cross(x, y)
    % COMPUTE_CROSS_NORM Compute the cross norm.
    M = size(x, 2);
    T = size(y, 2);

    n = zeros(M, T);

    for k = 1:size(x, 1)
        n = n + (repmat(y(k, :), [M, 1]) - repmat(x(k, :)', [1, T])).^2;
    end
end

function n = normalize_beta(b)
    % NORMALIZE_BETA Normalize beta to ensure values are in [0, 1]
    n = b./sum(abs(b), 1);
end

function cxx = compute_autocovariance(x, sigma)
    % COMPUTE_AUTOCOVARIANCECOMPUTE Compute autocovariance matrix.
    cxx = compute_norm(x);
    cxx = exp(-cxx/(2*sigma^2));
end

function cxy = compute_cross_covariance(x, y, sigma)
    % COMPUTE_CROSS_COVARIANCE Compute cross-covariance matrix.
    cxy = compute_norm_cross(x, y);
    cxy = exp(-cxy/(2*sigma^2));
end
