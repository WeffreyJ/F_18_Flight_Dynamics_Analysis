% Trimmed States and Inputs
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

% Perturb the first 8 states and recompute linearized matrices
delta_x = 0.01 * x_trim(1:8); % 1% perturbation
perturbed_x_trim = x_trim(1:8) + delta_x;
[A_pert, B_pert, C_pert, D_pert] = linmod('f18full_DUtrim', perturbed_x_trim, u_trim);

% Display Perturbed Matrices
disp('Perturbed A Matrix:'); disp(A_pert);
disp('Perturbed B Matrix:'); disp(B_pert);
disp('Perturbed C Matrix:'); disp(C_pert);
disp('Perturbed D Matrix:'); disp(D_pert);

% Extract and Display Reduced Perturbed Matrices
A_pert_reduced = A_pert(1:8, 1:8);
B_pert_reduced = B_pert(1:8, :);
disp('Perturbed A Matrix Reduced:'); disp(A_pert_reduced);
disp('Perturbed B Matrix Reduced:'); disp(B_pert_reduced);

% Compute and Display Norm Differences
fprintf('Norm of Delta A: %.4f\n', norm(A_pert_reduced - A_longltrl));
fprintf('Norm of Delta B: %.4f\n', norm(B_pert_reduced - B_longltrl));

% Eigenvalue Analysis
eig_values_long = eig(A_longltrl); % Longitudinal eigenvalues
eig_values_lat = eig(A_y); % Lateral eigenvalues

% Extract Damping Ratios and Natural Frequencies
[eig_long, damp_long, freq_long] = damp(ss(A_longltrl, B_longltrl, C_longltrl, D_longltrl));
[eig_lat, damp_lat, freq_lat] = damp(ss(A_y, B_y, C_longltrl(5:8, 5:8), D_longltrl(5:8, 3:4)));

% Display Modes in Table Format
long_table = table(eig_values_long, damp_long, freq_long, ...
    'VariableNames', {'Eigenvalue', 'Damping_Ratio', 'Frequency_rad_s'});
lat_table = table(eig_values_lat, damp_lat, freq_lat, ...
    'VariableNames', {'Eigenvalue', 'Damping_Ratio', 'Frequency_rad_s'});
disp('Longitudinal Modes:'); disp(long_table);
disp('Lateral Modes:'); disp(lat_table);

% Visualize Eigenvalues
figure;
hold on;
for i = 1:length(eig_values_long)
    plot([0, real(eig_values_long(i))], [0, imag(eig_values_long(i))], '-r', 'LineWidth', 1.5); % Arrow body
    scatter(real(eig_values_long(i)), imag(eig_values_long(i)), 50, 'r', 'filled'); % Eigenvalue point
end
for i = 1:length(eig_values_lat)
    plot([0, real(eig_values_lat(i))], [0, imag(eig_values_lat(i))], '-b', 'LineWidth', 1.5); % Arrow body
    scatter(real(eig_values_lat(i)), imag(eig_values_lat(i)), 50, 'b', 'filled'); % Eigenvalue point
end
plot([-10, 2], [0, 0], '--k', 'LineWidth', 1.5); % Real axis
plot([0, 0], [-10, 10], '--k', 'LineWidth', 1.5); % Imaginary axis
xlabel('Real Part'); ylabel('Imaginary Part');
title('Eigenvalue Visualization with Stability Indicators');
legend('Longitudinal', 'Lateral', 'Location', 'best');
grid on; axis([-10 2 -5 5]);

% Compute Periods and Damped Frequencies
omega_d_long = freq_long .* sqrt(1 - damp_long.^2); % Damped frequency
period_long = 2 * pi ./ omega_d_long; % Oscillation period
omega_d_lat = freq_lat .* sqrt(1 - damp_lat.^2); % Damped frequency
period_lat = 2 * pi ./ omega_d_lat; % Oscillation period

% Display Longitudinal and Lateral Periods
long_table_period = table(freq_long, damp_long, omega_d_long, period_long, ...
    'VariableNames', {'Nat_Freq_rad_s', 'Damping_Ratio', 'Damped_Freq_rad_s', 'Period_s'});
lat_table_period = table(freq_lat, damp_lat, omega_d_lat, period_lat, ...
    'VariableNames', {'Nat_Freq_rad_s', 'Damping_Ratio', 'Damped_Freq_rad_s', 'Period_s'});
disp('Longitudinal Modes with Periods:'); disp(long_table_period);
disp('Lateral Modes with Periods:'); disp(lat_table_period);

% Overlay Input Characteristics
input_freqs = [0.1, 0.5, 1.0]; % Example input frequencies
figure;
scatter(freq_long, damp_long, 100, 'r', 'filled', 'DisplayName', 'Longitudinal Modes');
scatter(freq_lat, damp_lat, 100, 'b', 'filled', 'DisplayName', 'Lateral Modes');
for i = 1:length(input_freqs)
    plot(input_freqs(i), 0, 'kx', 'MarkerSize', 10, 'LineWidth', 1.5, ...
        'DisplayName', sprintf('Input %.2f rad/s', input_freqs(i)));
end
xlabel('Frequency (rad/s)'); ylabel('Damping Ratio');
title('Comparison of System Modes and Inputs'); legend('show'); grid on;
