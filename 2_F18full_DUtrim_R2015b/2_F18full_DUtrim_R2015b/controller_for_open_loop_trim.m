%% Trimmed States and Inputs
disp('Trimmed States (x_trim):');
disp(x_trim);
disp('Trimmed Inputs (u_trim):');
disp(u_trim);

% Summarize trimmed values
fprintf('Trimmed Airspeed (V): %.2f ft/s\n', x_trim(1));
fprintf('Trimmed Alpha (Angle of Attack): %.2f deg\n', rad2deg(x_trim(3)));
fprintf('Trimmed Theta (Pitch Angle): %.2f deg\n', rad2deg(x_trim(8)));
fprintf('Trimmed Altitude (h): %.2f ft\n', x_trim(10));
fprintf('Trimmed Thrust: %.2f lbf\n', u_trim(4));
fprintf('Trimmed Stabilator Deflection: %.2f deg\n', rad2deg(u_trim(3)));

%% Controller Design for Longitudinal Modes
% Verify dimensions of A_longltrl
n_long = size(A_longltrl, 1); % Number of states in longitudinal mode

% Adjust desired eigenvalues to match the system size
desired_eigen_long = linspace(-1, -n_long, n_long); % Example: evenly spaced negative values

% Assert size matches
assert(length(desired_eigen_long) == n_long, ...
    'Mismatch: Number of desired longitudinal eigenvalues must equal %d', n_long);

% Compute state-feedback gain matrix
K_long = place(A_longltrl, B_longltrl, desired_eigen_long);

% New closed-loop dynamics for longitudinal modes
A_long_cl = A_longltrl - B_longltrl * K_long;

% Display new eigenvalues
disp('New Longitudinal Eigenvalues:');
disp(eig(A_long_cl));

%% Controller Design for Lateral Modes
% Verify dimensions of A_y
n_lat = size(A_y, 1); % Number of states in lateral mode

% Adjust desired eigenvalues to match the system size
desired_eigen_lat = linspace(-1, -n_lat, n_lat); % Example: evenly spaced negative values

% Assert size matches
assert(length(desired_eigen_lat) == n_lat, ...
    'Mismatch: Number of desired lateral eigenvalues must equal %d', n_lat);

% Compute state-feedback gain matrix
K_lat = place(A_y, B_y, desired_eigen_lat);

% New closed-loop dynamics for lateral modes
A_lat_cl = A_y - B_y * K_lat;

% Display new eigenvalues
disp('New Lateral Eigenvalues:');
disp(eig(A_lat_cl));

%% Step Response Visualization
% Define state-space systems
sys_long_open = ss(A_longltrl, B_longltrl, C_longltrl, D_longltrl);
sys_long_closed = ss(A_long_cl, B_longltrl, C_longltrl, D_longltrl);

sys_lat_open = ss(A_y, B_y, C_longltrl(5:8, 5:8), D_longltrl(5:8, 3:4));
sys_lat_closed = ss(A_lat_cl, B_y, C_longltrl(5:8, 5:8), D_longltrl(5:8, 3:4));

% Step response comparison
figure;

subplot(2, 1, 1);
step(sys_long_open, 'r', sys_long_closed, 'b');
title('Longitudinal Mode Step Response');
legend('Open Loop', 'Closed Loop');
grid on;

subplot(2, 1, 2);
step(sys_lat_open, 'r', sys_lat_closed, 'b');
title('Lateral Mode Step Response');
legend('Open Loop', 'Closed Loop');
grid on;

%% Evaluate Controller Performance
disp('Longitudinal Mode Step Response and Eigenvalues Adjusted.');
disp('Lateral Mode Step Response and Eigenvalues Adjusted.');



%% Eigenvalue Visualization: Complex Plane
figure;

% Longitudinal Eigenvalues
subplot(2, 1, 1);
hold on;
plot(real(eig(A_longltrl)), imag(eig(A_longltrl)), 'ro', 'MarkerSize', 8, 'DisplayName', 'Open-Loop');
plot(real(eig(A_long_cl)), imag(eig(A_long_cl)), 'bx', 'MarkerSize', 8, 'DisplayName', 'Closed-Loop');
xlabel('Real Part');
ylabel('Imaginary Part');
title('Longitudinal Mode Eigenvalues');
legend show;
grid on;

% Lateral Eigenvalues
subplot(2, 1, 2);
hold on;
plot(real(eig(A_y)), imag(eig(A_y)), 'ro', 'MarkerSize', 8, 'DisplayName', 'Open-Loop');
plot(real(eig(A_lat_cl)), imag(eig(A_lat_cl)), 'bx', 'MarkerSize', 8, 'DisplayName', 'Closed-Loop');
xlabel('Real Part');
ylabel('Imaginary Part');
title('Lateral Mode Eigenvalues');
legend show;
grid on;

%% Frequency and Time Period Analysis
% Longitudinal Mode
eigen_long = eig(A_long_cl);
omega_long = imag(eigen_long(eigen_long ~= real(eigen_long))); % Imaginary parts for oscillatory modes
freq_long = omega_long / (2 * pi); % Frequency in Hz
period_long = 1 ./ freq_long;      % Period in seconds

fprintf('Longitudinal Mode:\n');

fprintf('Frequencies (Hz): %.2f\n', freq_long);
disp(freq_long);
fprintf('Periods (s): %.2f\n', period_long);
disp(period_long);
% Lateral Mode
eigen_lat = eig(A_lat_cl);
omega_lat = imag(eigen_lat(eigen_lat ~= real(eigen_lat)));
freq_lat = omega_lat / (2 * pi);
period_lat = 1 ./ freq_lat;

fprintf('Lateral Mode:\n');
fprintf('Frequencies (Hz): %.2f\n', freq_lat);
disp(freq_lat);
fprintf('Periods (s): %.2f\n', period_lat);
disp(period_lat)
%% Mode Isolation
% Isolate specific longitudinal mode
mode_index = 1; % Adjust for the mode you want to isolate
A_isolated = A_longltrl - diag(diag(A_longltrl)); % Zero out other modes
A_isolated(mode_index, mode_index) = A_longltrl(mode_index, mode_index);

sys_isolated = ss(A_isolated, B_longltrl, C_longltrl, D_longltrl);
figure;
step(sys_isolated);
title(sprintf('Isolated Mode Step Response (Mode %d)', mode_index));
grid on;

