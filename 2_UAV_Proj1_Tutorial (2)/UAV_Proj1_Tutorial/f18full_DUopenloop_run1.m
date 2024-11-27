% Filename: f18full_DUopenloop_run1.m
% Objectives: 
%   This program is to observe the open-loop behavior of the flight dynamics 
%   model of f18full_DUopenloop.mdl.
% Simulation 1:
%   1. Use the dramatic iniial condition, Init_Dramatic
%      when the initial states are dramatic.
       %{
        V       =  350;         % Airspeed , ft/s  
        beta    =  20*d2r;       % Sideslip Angle, rad   
        alpha   =  40*d2r;       % Angle-of-attack, rad   
 
        p       =  10*d2r;       % Roll rate, rad/s   
        q       =  0*d2r;       % Pitch rate, rad/s   
        r       =  5*d2r;       % Yaw rate, rad/s   
 
        phi     =  0*d2r;       % Roll Angle, rad   
        theta   =  0*d2r;       % Pitch Angle, rad   
        psi     =  0*d2r;       % Yaw Angle, rad 
 
        pN      =  0;           % Position North,  ft  
        pE      =  0;           % Position East,  ft   
        h       =  h0;           % Altitude,  ft  
       %}
%   2. Use the following control inputs
       %{
        Con.T=5470.5; 
        Con.elev=-0.022; %in rad
        Con.ail=0;
        Con.rud=0;
       %}
%   3. Choose the simulation time to be
       % sim_time = 1000 % Simulink simulation time 1000s
%   4. Run the program f18full_DUopenloop_run1.m
%   5. Run the program F18full_DUopenloop_plot_run2.m to observe the
%      waveforms and the steady-state response
%   6. Rerun f18full_DUopenloop_run1.m with sim_time=30 
%   7. Get FlightGear ready for animation
%   8. Run the animation program, F18_Animation_run3.m
%      and observe the flight of the aircraft in real time

       
 
close all;clear all;clc;


% Reset enableFG and enableRT to 0 if FlightGear is not used
enableFG    = 1;  
enableRT    = 1;  
%enableFG    = 0;  
%enableRT    = 0; 


% Unit Conversion : Degree <--> Radian
d2r = pi/180;
r2d = 1/d2r;

h0=25000;
%h0=18000;% for flightgear only
%========================================================================== 
% F18 data
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
K=Ixx*Izz-Ixz^2;


%==========================================================================
% load aerodynamics coefficents
% the aerodynamic data is resulted from the Minnesotadata rev2.
load aerodynamics_coefficients_rev2

%==========================================================================
% Initialization
% the initial states/conditions are dramatic.

V       =  350;         % Airspeed , ft/s  
beta    =  20*d2r;       % Sideslip Angle, rad   
alpha   =  40*d2r;       % Angle-of-attack, rad   
 
p       =  10*d2r;       % Roll rate, rad/s   
q       =  0*d2r;       % Pitch rate, rad/s   
r       =  5*d2r;       % Yaw rate, rad/s   
 
phi     =  0*d2r;       % Roll Angle, rad   
theta   =  0*d2r;       % Pitch Angle, rad   
psi     =  0*d2r;       % Yaw Angle, rad 
 
pN      =  0;           % Position North,  ft  
pE      =  0;           % Position East,  ft   
h       =  h0;           % Altitude,  ft  

% Stack Initial Condition for State
x_init = [V;beta;alpha;p;q;r;phi;theta;psi;pN;pE;h];
x = x_init;  

%==========================================================================
% % Controlled input setup

Con.T=5470.5; 
Con.elev=-0.022; %in rad
Con.ail=0;
Con.rud=0;


%==========================================================================
% Using the m-file to run the simulink

sim_time = 200 % Simulink simulation time
%sim_time = 500 % Simulink simulation time

sim_options = simset('SrcWorkspace ', 'current',...
    'DstWorkspace ', 'current');
open('f18full_DUopenloop')
sim('f18full_DUopenloop', [0, sim_time], sim_options);  %[t,x,y] = sim(model,timespan,options,ut);


