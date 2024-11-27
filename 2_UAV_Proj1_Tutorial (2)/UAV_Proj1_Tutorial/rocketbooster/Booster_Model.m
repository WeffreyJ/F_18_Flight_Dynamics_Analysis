% Create a new Simulink model
modelName = 'RocketBoosterModel';
open_system(new_system(modelName));

% Set simulation time
set_param(modelName, 'StopTime', '100');

% Add blocks for thrust, mass reduction, gravity, drag, and integration
add_block('simulink/Commonly Used Blocks/Constant', [modelName, '/Thrust']);
set_param([modelName, '/Thrust'], 'Value', '5000'); % Thrust force (N)

add_block('simulink/Commonly Used Blocks/Constant', [modelName, '/Mass']);
set_param([modelName, '/Mass'], 'Value', '100'); % Initial mass (kg)

add_block('simulink/Math Operations/Divide', [modelName, '/Thrust per Mass']);
add_line(modelName, 'Thrust/1', 'Thrust per Mass/1');
add_line(modelName, 'Mass/1', 'Thrust per Mass/2');

% Gravity constant block
add_block('simulink/Commonly Used Blocks/Constant', [modelName, '/Gravity']);
set_param([modelName, '/Gravity'], 'Value', '-9.81'); % Gravity (m/s^2)

% Add summation block for net acceleration
add_block('simulink/Math Operations/Add', [modelName, '/Net Acceleration']);
set_param([modelName, '/Net Acceleration'], 'Inputs', '|+-');

% Connect thrust per mass and gravity to net acceleration
add_line(modelName, 'Thrust per Mass/1', 'Net Acceleration/1');
add_line(modelName, 'Gravity/1', 'Net Acceleration/2');

% Integrate acceleration to obtain velocity
add_block('simulink/Continuous/Integrator', [modelName, '/Velocity']);
add_line(modelName, 'Net Acceleration/1', 'Velocity/1');

% Integrate velocity to obtain position
add_block('simulink/Continuous/Integrator', [modelName, '/Position']);
add_line(modelName, 'Velocity/1', 'Position/1');

% Add scope to view results
add_block('simulink/Commonly Used Blocks/Scope', [modelName, '/Scope']);
set_param([modelName, '/Scope'], 'NumInputPorts', '2');
add_line(modelName, 'Velocity/1', 'Scope/1'); % Velocity to scope
add_line(modelName, 'Position/1', 'Scope/2'); % Position to scope

% Run the simulation
sim(modelName);

% Open the scope to view results
open_system([modelName, '/Scope']);

