% F18_Animation.m
% Run animations with logged data

h_ref=0;
enableRT = 1 %1;
simpace = 200;

sim_options = simset('SrcWorkspace ', 'current',...
    'DstWorkspace ', 'current');

% % Frames per Second
fps = 30;
speedRT = 1;  %1 0

clear temp
t = [0 : (speedRT/fps) : max(u_t.time)]';

temp = resample( timeseries(u_t.signals.values,u_t.time), t);
u = temp.Data;

temp = resample( timeseries(y.signals.values,y.time), t);
y = temp.Data;
clear temp

open('F18_Sim_animateFG4')
sim('F18_Sim_animateFG4', [min(t), max(t)], sim_options);


