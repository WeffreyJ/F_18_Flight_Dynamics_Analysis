% Trim_stab_f18fullDU_a.m
% Objectives: 
% This file trims the aircraft at a desired flight
% condition, find the linearized model at this trim,
% and design an LQR stabilizing controller for the trim.


% Unit Conversion : Degree <--> Radian
d2r = pi/180;
r2d = 1/d2r;

h0=25000;
%========================================================================== 
% F/A-18 data
% 
% Aircraft Physical Paramters
% Reference: S. B. Buttrill and P. D. Arbuckle  and K. D. Hoffler
%            Simulation model of a twin-tail, high performance airplane
%            NASA 1992, NASA TM-107601

S = 400;                % ft^2
b =  37.4;                % ft
c =  11.52;             % ft
rho = 1.0660e-003;      % slugs/ft^3  --- 25C / 25000 ft
Ixx = 23000;            % slugs*ft^2
Iyy = 151293;           % slugs*ft^2 
Izz = 169945;           % slugs*ft^2 
Ixz = - 2971;           % slugs*ft^2
m = 1034.5;             % slugs
g = 32.2;               % ft/s^2

%==========================================================================
% Statename , Inputname and Outputname
%
% Baseline and Revised has different feedback channels 
% So, their output equations are different

statenames = {'V (ft/s)','Beta (rad)','Alpha (rad)','Roll Rate (rad/s)',...
    'Pitch Rate (rad/s)','Yaw Rate (rad/s)','Phi (rad)','Theta (rad)',...
    'Yaw (rad)','pN (ft)','pE (ft)','h (ft)'}'
inputnames = { 'Aileron (rad)','Rudder (rad)','Stabilator (rad)', 'T (lb)'}'       
% 
%==========================================================================
% load aerodynamics coefficents
% the aerodynamic data is resulted from the Minnesotadata rev2.
load aerodynamics_coefficients_rev2
          
%========================================================================== 
% Trimming initial conditions
%==========================================================================

%-------------------------------------------
% Initialization
% Initialize to find TrimA condition

% State Initial Value
V       =  300;         % Airspeed , ft/s  Guess, not fixed
beta    =  0*d2r;       % Sideslip Angle, rad   Desired to be zero
alpha   =  8*d2r;       % Angle-of-attack, rad   Desired to be 8 deg because of the change
 
p       =  0*d2r;       % Roll rate, rad/s   Desired to be zero
q       =   0*d2r;       % Pitch rate, rad/s   Desired to be zero
r       =  0*d2r;       % Yaw rate, rad/s   Desired to be zero
 

phi     =  0*d2r;       % Roll Angle, rad   Desired to be zero
theta   =  10*d2r;       % Pitch Angle, rad   Desired to be 10 deg so that gamma can be zero
psi     =  0*d2r;       % Yaw Angle, rad   Guess, not fixed
 
pN      =  0;           % Position North,  ft   Not fixed
pE      =  0;           % Position East,  ft   Not fixed
h       =  25000;           % Altitude,  ft   Not fixed

% Stack Initial Condition for State
x_init = [V;beta;alpha;p;q;r;phi;theta;psi;pN;pE;h];
x = x_init;  

% Initialize Input Value

d_STAB   = 0*d2r;    %Not fixed
d_AIL    = 0*d2r;    %Not fixed
d_RUD    = 0*d2r;    %Not fixed
T = 5000;    %Not fixed
 
u_init = [d_AIL; d_RUD; d_STAB; T]; 
%u=u_init
disp('initial values')
x_init(1)
x_init(2:9)*r2d
x_init(10:11)
x_init(12)
u_init(1:3)*r2d
u_init(4)

%==========================================================================
% Operating Point Specificaton Setup

open('f18full_DUtrim')
opys = operspec('f18full_DUtrim');

opys.States(1).Known  =  0;
opys.States(2).Known  =  1;
opys.States(3).Known  =  1;
%opys.States(2).Known  =  0;
%opys.States(3).Known  =  0;

opys.States(4).Known  =  1;
opys.States(5).Known  =  1;
opys.States(6).Known  =  1;
%opys.States(4).Known  =  0;
%opys.States(5).Known  =  0;
%opys.States(6).Known  =  0;

opys.States(7).Known  =  1;
opys.States(8).Known  =  1;
opys.States(9).Known  =  1;
%opys.States(7).Known  =  0;
%opys.States(8).Known  =  0;
%opys.States(9).Known  =  0;

opys.States(10).Known  =  0;
opys.States(11).Known  =  0;
opys.States(12).Known  =  0;


opys.States(1).steadystate = 1;
opys.States(2).steadystate = 1;
opys.States(3).steadystate = 1;
opys.States(4).steadystate = 1;
opys.States(5).steadystate = 1;
opys.States(6).steadystate = 1;
opys.States(7).steadystate = 1;
opys.States(8).steadystate = 1;
opys.States(9).steadystate = 1;
opys.States(10).steadystate = 0;
opys.States(11).steadystate = 0;
opys.States(12).steadystate = 0;


%Setting the Input value

opys.inputs(1).known = 0;
opys.inputs(2).known = 0;
opys.inputs(3).known = 0;
opys.inputs(4).known = 0;

opys.inputs(3).u = d_STAB;
opys.inputs(2).u = d_RUD;
opys.inputs(1).u = d_AIL;
opys.inputs(4).u = T;

opys.inputs(4).min = 0;
opys.inputs(4).max = 38000;
%==========================================================================
% Finding Trim/ Operating point
opt1 = optimset('MaxFunEvals',1e+04);
opt = linoptions('OptimizationOptions',opt1);
[ysop,rep] = findop('f18full_DUtrim',opys,opt);
get(ysop)



%==========================================================================
% Extracting Trim Point

x_trim = [ysop.States(1).x;  ysop.States(2).x; ysop.States(3).x;...
          ysop.States(4).x;  ysop.States(5).x; ysop.States(6).x;...
          ysop.States(7).x;  ysop.States(8).x; ysop.States(9).x;...
          ysop.States(12).x] 

u_trim = [ysop.Inputs(1).u; ysop.Inputs(2).u; ysop.Inputs(3).u; ysop.Inputs(4).u]      

disp('Trimmed Value')
x_trim(1)
x_trim(2:9)*r2d
x_trim(10)
u_trim(1:3)*r2d
u_trim(4)

Trim.T      = u_trim(4); % lb
Trim.elev   = u_trim(3); % -0.022 rad =  -1.2616 deg
Trim.ail    = u_trim(1); %rad
Trim.rud    = u_trim(2); %rad

Trim.V      = x_trim(1);   %ft/s
Trim.alpha  = x_trim(3);   %rad
Trim.q      = 0;        %rad/s
Trim.theta  = x_trim(8);   %rad
Trim.h      = h0;      %ft

Trim.beta   = 0;   %rad
Trim.p      = 0;   %rad/s
Trim.r      = 0;   %rad/s
Trim.phi    = 0;   %rad

Trim.psi    = 0;   %rad/s
Trim.pN     = 0;   %ft
Trim.pE     = 0;    %ft

%==========================================================================
% Creating Open Loop Linearized Model 

[A ,B ,C, D] = linmod('f18full_DUtrim',x_trim,u_trim);
A_trim = A([1:8], [1:8]);
B_trim = B([1:8],:);
C_trim = C([1:8], [1:8]);
D_trim = D([1:8],:);

A_longltrl = A([1 3 5 8 2 4 6 7], [1 3 5 8 2 4 6 7])
B_longltrl = B([1 3 5 8 2 4 6 7], [3 4 1 2])
C_longltrl = C([1 3 5 8 2 4 6 7], [1 3 5 8 2 4 6 7])
D_longltrl = D([1 3 5 8 2 4 6 7], [3 4 1 2])



%==========================================================================
% Decoupled longitudinal
% Longitudinal states [ V  alpha q theta ]
% Longitudinal controls [d_STAB   T]
display('Longitudnal states: [V alpha q theta ]')
display('Longitudinal controls [d_STAB   T]')

A_x = A_longltrl([1:4], [1:4])
B_x = B_longltrl([1:4], [1:2])

%{
C_x = eye(4)
D_x = zeros(4,2)
sys_x = ss(A_x,B_x,C_x,D_x)
[Wn,Zeta,P] = damp(sys_x) 
%}

% Lateral states [beta p r phi]
% Lateral controls [d_AIL  d_RUD]
display('Lateral states: [beta p r phi]')
display('Lateral controls [d_AIL  d_RUD]')

A_y = A_longltrl([5:8], [5:8])
B_y = B_longltrl([5:8], [3:4])

display('eigenvalues of A_longltrl')
eig(A_longltrl)

display('eigenvalues of A_x')
eg_x = eig(A_x)
wn_x = abs(eg_x(4))
ze_x = -real(eg_x(4))/wn_x

display('eigenvalues of A_y')
eg_y = eig(A_y)
wn_y = abs(eg_y(1))
ze_y = -real(eg_y(1))/wn_y

%Checking controllability
  disp('checking longitudinal controllability');
  Contp_x=[B_x A_x*B_x A_x^2*B_x A_x^3*B_x];
  Rank0fCont_x=svd(Contp_x)

  disp('checking lateral controllability');
  Contp_y=[B_y A_y*B_y A_y^2*B_y A_y^3*B_y A_y^4*B_y];
  Rank0fCont=svd(Contp_y)

% Design of F_x and F_y

% Nominal stabilizing controller design for longitudinal control
% Design an LQR state feedback gain F_x based on X_x
%  Q_x=diag([0.01 1 1 10]);
%  R_x=diag([100  0.1]);
%Q_x=diag([0.01 1 1 1]);   %2nd design
%R_x=diag([100  0.1]);      % 2nd design
Q_x=diag([0.01 1 1 1]);   % 4th  design
R_x=diag([1000  0.001]);   %  4th design

  X_x=are(A_x,B_x*inv(R_x)*B_x',Q_x);
  F_x=-inv(R_x)*B_x'*X_x
  disp('longitudinal eigenvalues of A_x+B_x*F_x');
  eg_xABF = eig(A_x+B_x*F_x)
  wn_xABF = abs(eg_xABF(4))
  ze_xABF = -real(eg_xABF(4))/wn_xABF
  
% Nominal stabilizing controller design for lateral control
% Design the state feedback gain F_y based on X_y
  Q_y=diag([10 100 10 10]);
  R_y=diag([100 10]);
  X_y=are(A_y,B_y*inv(R_y)*B_y',Q_y);
  F_y=-inv(R_y)*B_y'*X_y
  disp('lateral eigenvalues of A_y+B_y*F_y');
  eg_yABF = eig(A_y+B_y*F_y)
  wn_yABF = abs(eg_yABF(2))
  ze_yABF = -real(eg_yABF(2))/wn_yABF

save f18stab Trim A_x B_x A_y B_y F_x F_y 

