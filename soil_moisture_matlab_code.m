clc;
clear;
close all;

%% Read GitHub Dataset
data = readtable('soillog.csv');

%% Sensor Data
sensor_data = data.DFRobot1_Raw;

%% Remove invalid values
sensor_data = sensor_data(~isnan(sensor_data));

%% Numerical Method: Linear Interpolation / Scaling
% Same principle as Arduino:
% M = ((1023 - sensor_data) / 1023) * 100

M = ((1023 - sensor_data) / 1023) * 100;

%% Display Results
fprintf('Soil Moisture Measurement\n');
fprintf('-------------------------\n');

for i = 1:length(sensor_data)

    fprintf('Sensor Value: %d | M = %.1f %%\n', ...
        sensor_data(i), M(i));

    %% Soil Condition and Pump Control

    if sensor_data(i) > 950

        fprintf('No moisture, Soil is dry\n');
        fprintf('Motor ON\n\n');

        pump(i) = 1;
        condition{i} = 'Dry';

    elseif sensor_data(i) >= 400 && sensor_data(i) <= 950

        fprintf('There is some moisture, Soil is medium\n');
        fprintf('Motor OFF\n\n');

        pump(i) = 0;
        condition{i} = 'Medium';

    elseif sensor_data(i) < 400

        fprintf('Soil is wet\n');
        fprintf('Motor OFF\n\n');

        pump(i) = 0;
        condition{i} = 'Wet';

    end

end

%% Plot 1: Sensor Reading
figure;

plot(sensor_data, 'LineWidth', 1.5);

xlabel('Sample Number');
ylabel('Sensor Value');
title('Soil Moisture Sensor Reading');

grid on;

%% Plot 2: Calculated Moisture
figure;

plot(M, 'LineWidth', 1.5);

xlabel('Sample Number');
ylabel('Moisture (%)');
title('Calculated Soil Moisture');

grid on;

%% Plot 3: Pump Status
figure;

stairs(pump, 'LineWidth', 1.5);

xlabel('Sample Number');
ylabel('Pump Status');
title('Automatic Irrigation Control');

yticks([0 1]);
yticklabels({'Motor OFF','Motor ON'});

grid on;

%% Display Final Summary

fprintf('\n============================\n');
fprintf('       FINAL RESULT\n');
fprintf('============================\n');

fprintf('Total Samples = %d\n', length(sensor_data));
fprintf('Motor ON      = %d samples\n', sum(pump == 1));
fprintf('Motor OFF     = %d samples\n', sum(pump == 0));