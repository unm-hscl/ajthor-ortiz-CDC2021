function presolve_setup()
%     % Use GUROBI
%     % We take additional steps to overcome path bugs with CVX
%     % See http://ask.cvxr.com/t/mismangement-of-matlab-path-in-cvxv2-2-and-external-gurobi-v9-0-2/7346/3
%     addpath '/home/ubuntu/Documents/MATLAB/gurobi902/linux64/matlab';
%     evalc('cvx_setup;cvx_solver Gurobi_2;cvx_save_prefs;');
%     evalc('mpt_init');

    % Use SeDuMi
    evalc('cvx_solver(''SeDuMi'');cvx_save_prefs;');
end
