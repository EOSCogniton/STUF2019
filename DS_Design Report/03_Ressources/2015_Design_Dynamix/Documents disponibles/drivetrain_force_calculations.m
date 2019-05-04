clear all

%% Parameters %%

%Power
engine_torque=60; %Nm
final_drive=20; %optimal one
%final_drive= 76/36*32/12*45/12; %used one
rear_sprocket_radius=100e-3; %m

chain_force=engine_torque*final_drive/rear_sprocket_radius

%geometric parameters
l_chain_left_bearing_carrier=46e-3; %m
l_chain_right_bearing_carrier=206e-3; %m
l_differential_axis_upper_tabs=69e-3; %m
l_differential_axis_lower_tabs=115e-3; %m

%% Calculations for designing bearing carriers %%

left_bearing_carrier_force=l_chain_right_bearing_carrier/(l_chain_right_bearing_carrier-l_chain_left_bearing_carrier)*chain_force

right_bearing_carrier_force=-l_chain_left_bearing_carrier/(l_chain_right_bearing_carrier-l_chain_left_bearing_carrier)*chain_force

%% Calculations for designing drivetrain tabs %%

left_upper_tab_force= l_differential_axis_lower_tabs/(l_differential_axis_lower_tabs+l_differential_axis_upper_tabs)*left_bearing_carrier_force
left_lower_tab_force= -l_differential_axis_upper_tabs/(l_differential_axis_lower_tabs+l_differential_axis_upper_tabs)*left_bearing_carrier_force

right_upper_tab_force= l_differential_axis_lower_tabs/(l_differential_axis_lower_tabs+l_differential_axis_upper_tabs)*right_bearing_carrier_force
right_lower_tab_force= -l_differential_axis_upper_tabs/(l_differential_axis_lower_tabs+l_differential_axis_upper_tabs)*right_bearing_carrier_force
