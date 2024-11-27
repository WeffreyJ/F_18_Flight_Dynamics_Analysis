% Filename: F18_Sim_plot_2by2.m
%
%==========================================================================
% Plot Results
d2r = pi/180;
r2d = 1/d2r;
disp('Final state values')
Final_State_Value=[ya(end,1) ;ya(end,2)*r2d;ya(end,3)*r2d;ya(end,4)*r2d;ya(end,5)*r2d;ya(end,6)*r2d;ya(end,7)*r2d;ya(end,8)*r2d;ya(end,9)*r2d;ya(end,10);ya(end,11);ya(end,12)];
% % 
% tsim=1821 ; % t=200s 
% Final_State_Value=[ya(tsim,1);ya(tsim,2)*r2d;ya(tsim,3)*r2d;ya(tsim,4)*r2d;ya(tsim,5)*r2d;ya(tsim,6)*r2d;ya(tsim,7)*r2d;ya(tsim,8)*r2d;ya(tsim,9)*r2d;ya(tsim,10);ya(tsim,11);ya(tsim,12)];

State_Unit=  {'ft/s';'deg';'deg';'deg/s';'deg/s';'deg/s';'deg';'deg';'deg';'ft';'ft';'ft'};
State_Names={'V';'beta';'alpha';'p';'q';'r';'phi';'theta';'psi';'pN';'pE';'Altitute'};
FinalState=table(Final_State_Value,State_Unit,'RowNames',State_Names)  % make table

disp('Final input values')
Final_Input_Value=[ua(end,1)*r2d;ua(end,2)*r2d;ua(end,3)*r2d;ua(end,4)];
State_Unit1=  {'deg';'deg';'deg';'lbf'};
State_Names1={'Aileron';'Rudder';'Elevator'; 'Thrust' };
FinalInput=table(Final_Input_Value,State_Unit1,'RowNames',State_Names1)  % make table

% disp('Final input values')
% Final_Input_Value=[ua_command(tsim,1)*r2d;ua_command(tsim,2)*r2d;ua_command(tsim,3)*r2d;ua_command(tsim,4)];
% State_Unit1=  {'deg';'deg';'deg';'lbf'};
% State_Names1={'Aileron';'Rudder';'Elevator'; 'Thrust' };
% FinalInput=table(Final_Input_Value,State_Unit1,'RowNames',State_Names1)  % make table

%%
pr=1:size(ta)/1;  %print size

figure (2)

subplot(2,2,1)
plot (ta(pr),(180/pi)*ya(pr,3),'b-',ta(pr),(180/pi)*ya(pr,2),'r-',ta(pr),ya(pr,18)*r2d,'k-','LineWidth',1)
grid on, grid minor 
%xlabel ('Time (sec)')
ylabel ('\alpha,\beta,\gamma [deg]')
legend ('\alpha','\beta','\gamma')
hold on

subplot(2,2,2)
plot (ta(pr),(180/pi)*ya(pr,7),'r-',ta(pr),(180/pi)*ya(pr,8),'k-','LineWidth',1)
grid on, grid minor  
%xlabel ('Time (sec)')
ylabel ('\phi,\theta (deg)')
legend ('\phi','\theta')
hold on

subplot(2,2,3)
plot (ta(pr), ya(pr,1),'k','LineWidth',1)
grid on, grid minor  
%xlabel ('Time (sec)')
ylabel ('V (ft/s)')
hold on

subplot(2,2,4)
plot (ta(pr), ya(pr,12),'k-','LineWidth',1)
grid on, grid minor  
%xlabel ('Time (sec)')
ylabel ('Altitude (ft)')
hold on


