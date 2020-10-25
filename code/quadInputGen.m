function U = quadInputGen(N,Ts,ulim,x0,x_d)

%% Generate system matrices.

m = 5; 
r = 2;
I = 2;
g = 9.81;

A = [0 1 0 0   0 0;
     0 0 0 0  -g 0;
     0 0 0 1   0 0;
     0 0 0 0   0 0;
     0 0 0 0   0 1;
     0 0 0 0   0 0;];
 
B = [0     0;
     0     0;
     0     0;
     1/m 1/m;
     0     0;
     r/I -r/I;];
 
sys = ss(A,B,eye(1,size(A,2)),0);

sysd = c2d(sys,Ts);

A = sysd.A;
B = sysd.B;
         

Q = 10*eye(size(A,2)*N);
R = 1*eye(size(B,2)*N);
X_d = repmat(x_d,[N 1]); 

cvx_begin

variable X(size(A,2)*N,)
variable U(size(B,2)*N,)


minimize((X-X_d)'*Q*(X-X_d) + U'*R*U)

subject to

    X(1:size(A,2)) == x0;

    for k = 1:(N-1)
        
        X(size(A,2)*k+1:size(A,2)*(k+1)) == ...
            A*X(size(A,2)*(k-1)+1:size(A,2)*(k)) + B*U(size(B,2)*(k-1)+1:size(B,2)*(k)); 

    end
    
    abs(U) <= ulim; 
    
cvx_end
end
