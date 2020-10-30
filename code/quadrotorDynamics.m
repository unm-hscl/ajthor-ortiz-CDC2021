function Ys = quadrotorDynamics(Xs, Us, Ts, dtype)
% QUADROTORDYNAMICS Dynamics for a planar quadrotor system.
%
%   Usage:
%
%       Ys = QUADROTORDYNAMICS(Xs, Us, Ts, dtype)
%
%   Used to generate samples for the system, where Xs is the current state, Us
%   is the current action, Ts is the sampling time, dtype is either 1 for
%   Gaussian or 2 for Beta disturbance, and Ys are the output states.

% Set the random number generator for repeatability.
rng(0);

% Constants
m = 5;      % Mass
r = 2;      % Length
I = 2;      % Inertia
g = 9.81;   % Gravity

% Generate samples based on the choice of disturbance.
if dtype == 1

    % Gaussian disturbance.
    Ys(1,:) = Xs(1,:) + Ts*Xs(2,:) + 1E-3*randn(1,size(Xs,2));
    Ys(2,:) = -Ts/m*sin(Xs(3,:)).*(Us(1,:)+Us(2,:)) + Xs(2,:) + 1E-5*randn(1,size(Xs,2));
    Ys(3,:) = Xs(3,:) + Ts*Xs(4,:)+ 1E-3*randn(1,size(Xs,2));
    Ys(4,:) = Ts/m*cos(Xs(3,:)).*(Us(1,:)+Us(2,:)) - Ts/g + Xs(4,:) + 1E-5*randn(1,size(Xs,2));
    Ys(5,:) = Xs(5,:) + Ts*Xs(6,:) + 1E-3*randn(1,size(Xs,2));
    Ys(6,:) = Ts*r/I.*(Us(1,:)-Us(2,:)) + Xs(6,:) + 1E-5*randn(1,size(Xs,2));

elseif dtype == 2

    % Beta disturbance.
    Ys(1,:) = Xs(1,:) + Ts*Xs(2,:) + 0.1*betarnd(1,0.5,1,size(Xs,2));
    Ys(2,:) = -Ts/m*sin(Xs(3,:)).*(Us(1,:)+Us(2,:)) + Xs(2,:) + 0.1*betarnd(1,0.5,1,size(Xs,2));
    Ys(3,:) = Xs(3,:) + Ts*Xs(4,:)+ 0.1*betarnd(1,0.5,1,size(Xs,2));
    Ys(4,:) = Ts/m*cos(Xs(3,:)).*(Us(1,:)+Us(2,:)) - Ts/g + Xs(4,:) + 0.1*betarnd(1,0.5,1,size(Xs,2));
    Ys(5,:) = Xs(5,:) + Ts*Xs(6,:) + 0.1*betarnd(1,0.5,1,size(Xs,2));
    Ys(6,:) = Ts*r/I.*(Us(1,:)-Us(2,:)) + Xs(6,:) + 0.1*betarnd(1,0.5,1,size(Xs,2));

end

end
