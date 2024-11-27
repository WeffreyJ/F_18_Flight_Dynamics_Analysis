% Create a new Simulink model
modelName = 'RocketBoosterSimscapeModel12';
open_system(new_system(modelName));

% Set up simulation time
set_param(modelName, 'StopTime', '100');

% Add Simulink-PS Converter for unit conversion to apply thrust as a force
add_block('simscape/Utilities/Simulink-PS Converter', [modelName, '/Simulink-PS Converter']);

% Add a Simscape Solver Configuration block
add_block('simscape/Foundation/Utilities/Solver Configuration', [modelName, '/Solver Configuration']);

% Add a World Frame for reference in Simscape Multibody
add_block('sm_lib/Frames and Transforms/World Frame', [modelName, '/World Frame']);

% Create the Rocket Body as a rigid body in Simscape Multibody
add_block('sm_lib/Body Elements/Brick Solid', [modelName, '/Rocket Body']);
set_param([modelName, '/Rocket Body'], 'Dimensions', '[0.5 0.5 3]'); % Rough dimensions for a rocket booster

% Connect Rocket Body to World Frame with a Rigid Transform block
add_block('sm_lib/Frames and Transforms/Rigid Transform', [modelName, '/Transform']);
add_line(modelName, 'World Frame/RConn1', 'Transform/LConn1');
add_line(modelName, 'Transform/RConn1', 'Rocket Body/RConn1');

% Add a Thrust Force block (using a constant Simulink input for thrust)
add_block('sm_lib/Forces and Torques/External Force and Torque', [modelName, '/Thrust Force']);
add_block('simulink/Commonly Used Blocks/Constant', [modelName, '/Thrust Input']);
set_param([modelName, '/Thrust Input'], 'Value', '5000'); % Initial thrust in N

% Connect the thrust force input to the thrust block
add_line(modelName, 'Thrust Input/1', 'Simulink-PS Converter/1');
add_line(modelName, 'Simulink-PS Converter/1', 'Thrust Force/F');

% Connect Thrust Force to Rocket Body
add_line(modelName, 'Rocket Body/RConn1', 'Thrust Force/RConn1');

% Add a Gravity block from Simscape for constant gravitational pull
add_block('simscape/Foundation/Forces/Gravitational Field', [modelName, '/Gravity']);
set_param([modelName, '/Gravity'], 'GravitationalAcceleration', '9.81'); % Gravity in m/s^2

% Connect Gravity to the Rocket Body
add_line(modelName, 'World Frame/RConn1', 'Gravity/LConn1');
add_line(modelName, 'Gravity/RConn1', 'Rocket Body/RConn1');

% Add a Scope to view altitude over time
add_block('simulink/Commonly Used Blocks/Scope', [modelName, '/Altitude Scope']);

% Add PS-Simulink Converter to bring Simscape data back to Simulink
add_block('simscape/Utilities/PS-Simulink Converter', [modelName, '/PS-Simulink Converter']);

% Extract the Z-axis position (altitude) from the Rocket Body for visualization
add_block('simscape/Multibody/Interfaces/Transform Sensor', [modelName, '/Position Sensor']);
set_param([modelName, '/Position Sensor'], 'OutputPosition', 'On'); % Enable position output

% Connect Position Sensor to Rocket Body and World Frame
add_line(modelName, 'Rocket Body/RConn1', 'Position Sensor/RConn1');
add_line(modelName, 'World Frame/RConn1', 'Position Sensor/LConn1');

% Connect Z-position from Position Sensor to PS-Simulink Converter
add_line(modelName, 'Position Sensor/Pos', 'PS-Simulink Converter/1');

% Connect the PS-Simulink Converter output to the Scope to visualize altitude
add_line(modelName, 'PS-Simulink Converter/1', 'Altitude Scope/1');

% Final model adjustments
% Connect Solver Configuration block to the World Frame to complete the physical network
add_line(modelName, 'Solver Configuration/RConn1', 'World Frame/LConn1');

% Run the simulation and open the 3D visualization viewer
sim(modelName);
open_system([modelName, '/Altitude Scope']);
smopen([modelName, '/Rocket Body']); % Open 3D visualization viewer
