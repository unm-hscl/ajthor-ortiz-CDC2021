function varargout = generate_samples_quad(params,varargin)

rng(0);

N = params.N;
Xmin = params.Xmin;
Xmax = params.Xmax;
dXmin = params.dXmin;
dXmax = params.dXmax;
Ymin = params.Ymin;
Ymax = params.Ymax;
dYmin = params.dYmin;
dYmax = params.dYmax;
Tmin = params.Tmin;
Tmax = params.Tmax;
dTmin = params.dTmin;
dTmax = params.dTmax;
Umin = params.Umin;
Umax = params.Umax;
disturb = params.disturb; 

% el  = [10, 2, 10, 2, 4, 2]; 
el = params.el;



fprintf('Number of elements: %d\n', prod(el));

X = linspace(Xmin, Xmax, el(1));
dX = linspace(dXmin, dXmax, el(2));
Y = linspace(Ymin, Ymax, el(3));
dY = linspace(dYmin, dYmax, el(4));
T = linspace(Tmin, Tmax, el(5));
dT = linspace(dTmin, dTmax, el(6));

[dTdT, TT, dYdY, YY, dXdX, XX] = ndgrid(dT, T, dY, Y, dX, X);

X = reshape(XX, 1, []);
dX = reshape(dXdX, 1, []);
Y = reshape(YY, 1, []);
dY = reshape(dYdY, 1, []);
T = reshape(TT, 1, []);
dT = reshape(dTdT, 1, []);

% Generate input samples.
U = [5; 5];

%% Generate sample vectors.
% Subscript 's' means sample vector.
Xs = [X; dX; Y; dY; T; dT];
Us = U;


%% Generate output samples.

for i = 1:N
    
    if i == 1

        Ys(1,:) = Xs(1,:) + Ts*Xs(2,:) + disturb(1);
        Ys(2,:) = -Ts/m*sin(Xs(3,:))*(U(1)+U(2)) + Xs(2,:) + disturb(2);
        Ys(3,:) = Xs(3,:) + Ts*Xs(4,:)+ disturb(3);
        Ys(4,:) = Ts/m*cos(Xs(3,:))*(U(1)+U(2)) - Ts/g + Xs(4,:) + disturb(4);
        Ys(5,:) = Xs(5,:) + Ts*Xs(6,:) + disturb(5);
        Ys(6,:) = Ts*r/I*(U(1)-U(2)) + Xs(6,:) + disturb(6);

    else
        Xs = Ys;
        Ys(1,:) = Xs(1,:) + Ts*Xs(2,:) + disturb(1);
        Ys(2,:) = -Ts/m*sin(Xs(3,:))*(U(1)+U(2)) + Xs(2,:) + disturb(2);
        Ys(3,:) = Xs(3,:) + Ts*Xs(4,:)+ disturb(3);
        Ys(4,:) = Ts/m*cos(Xs(3,:))*(U(1)+U(2)) - Ts/g + Xs(4,:) + disturb(4);
        Ys(5,:) = Xs(5,:) + Ts*Xs(6,:) + disturb(5);
        Ys(6,:) = Ts*r/I*(U(1)-U(2)) + Xs(6,:) + disturb(6);
        
    end
    
end
    

switch nargout
case 1
  varargout{1} = Ys;
case 2
  varargout{1} = Ys;
  varargout{2} = Xs;
end