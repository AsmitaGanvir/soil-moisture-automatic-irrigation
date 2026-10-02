clc;
clear;
close all;

%% =========================================================
% SOIL MOISTURE SENSOR MEASUREMENT AND AUTOMATIC IRRIGATION
% Numerical Method: Polynomial Curve Fitting
% Method: Least Squares
% ==========================================================


%% 1. READ DATASET
data = readtable('soillog.csv');


%% 2. EXTRACT SENSOR AND REFERENCE DATA
% DFRobot1_Raw  -> Raw sensor reading
% VWC           -> Reference soil moisture

sensor_raw = data.DFRobot1_Raw;
reference_moisture = data.VWC;


%% 3. REMOVE INVALID DATA
valid = ~isnan(sensor_raw) & ~isnan(reference_moisture);

sensor_raw = sensor_raw(valid);
reference_moisture = reference_moisture(valid);


%% 4. BASIC DATA INFORMATION
fprintf('\n============================================\n');
fprintf('       SOIL MOISTURE SENSOR PROJECT\n');
fprintf('============================================\n');

fprintf('Number of valid samples = %d\n', length(sensor_raw));

fprintf('Raw sensor range       = %.2f to %.2f\n', ...
    min(sensor_raw), max(sensor_raw));

fprintf('Reference VWC range     = %.2f to %.2f %%\n', ...
    min(reference_moisture), max(reference_moisture));


%% =========================================================
% 5. LINEAR CALIBRATION
% ==========================================================

% First-order polynomial:
% M = a1*S + a0

linear_coeff = polyfit(sensor_raw, reference_moisture, 1);

linear_moisture = polyval(linear_coeff, sensor_raw);


%% =========================================================
% 6. NONLINEAR CALIBRATION
%    QUADRATIC POLYNOMIAL
% ==========================================================

% Second-order polynomial:
%
% M = a2*S^2 + a1*S + a0
%
% Coefficients are calculated using Least Squares Method.

quadratic_coeff = polyfit(sensor_raw, reference_moisture, 2);

compensated_moisture = polyval(quadratic_coeff, sensor_raw);


%% =========================================================
% 7. ERROR CALCULATION
% ==========================================================

% ---------- Linear Model Error ----------

linear_error = reference_moisture - linear_moisture;

linear_absolute_error = abs(linear_error);

linear_percentage_error = ...
    (linear_absolute_error ./ abs(reference_moisture)) * 100;


% ---------- Nonlinear Model Error ----------

nonlinear_error = reference_moisture - compensated_moisture;

nonlinear_absolute_error = abs(nonlinear_error);

nonlinear_percentage_error = ...
    (nonlinear_absolute_error ./ abs(reference_moisture)) * 100;


%% =========================================================
% 8. MAPE
% ==========================================================

linear_MAPE = mean(linear_percentage_error);

nonlinear_MAPE = mean(nonlinear_percentage_error);


%% =========================================================
% 9. RMSE
% ==========================================================

linear_RMSE = sqrt(mean(linear_error.^2));

nonlinear_RMSE = sqrt(mean(nonlinear_error.^2));


%% =========================================================
% 10. R-SQUARED
% ==========================================================

SS_total = sum((reference_moisture - ...
    mean(reference_moisture)).^2);

linear_R2 = 1 - ...
    sum(linear_error.^2) / SS_total;

nonlinear_R2 = 1 - ...
    sum(nonlinear_error.^2) / SS_total;


%% =========================================================
% 11. DISPLAY CALIBRATION EQUATIONS
% ==========================================================

fprintf('\n--------------------------------------------\n');
fprintf('           CALIBRATION EQUATIONS\n');
fprintf('--------------------------------------------\n');

fprintf('\nLinear Calibration:\n');

fprintf('M = %.8f*S + %.8f\n', ...
    linear_coeff(1), linear_coeff(2));


fprintf('\nNonlinear Quadratic Calibration:\n');

fprintf('M = %.10f*S^2 + %.8f*S + %.8f\n', ...
    quadratic_coeff(1), ...
    quadratic_coeff(2), ...
    quadratic_coeff(3));


%% =========================================================
% 12. DISPLAY ERROR RESULTS
% ==========================================================

fprintf('\n--------------------------------------------\n');
fprintf('             ERROR ANALYSIS\n');
fprintf('--------------------------------------------\n');

fprintf('\nLINEAR CALIBRATION\n');
fprintf('MAPE = %.4f %%\n', linear_MAPE);
fprintf('RMSE = %.4f %% VWC\n', linear_RMSE);
fprintf('R^2  = %.4f\n', linear_R2);


fprintf('\nNONLINEAR CALIBRATION\n');
fprintf('MAPE = %.4f %%\n', nonlinear_MAPE);
fprintf('RMSE = %.4f %% VWC\n', nonlinear_RMSE);
fprintf('R^2  = %.4f\n', nonlinear_R2);


%% =========================================================
% 13. SAMPLE-WISE RESULTS
% ==========================================================

fprintf('\n--------------------------------------------\n');
fprintf('       SAMPLE-WISE MOISTURE RESULTS\n');
fprintf('--------------------------------------------\n');

fprintf('\nSample\tRaw\tReference\tLinear\tNonlinear\tError(%%)\n');

number_of_samples_to_display = ...
    min(10, length(sensor_raw));

for i = 1:number_of_samples_to_display

    fprintf('%d\t%.2f\t%.2f\t\t%.2f\t%.2f\t\t%.2f\n', ...
        i, ...
        sensor_raw(i), ...
        reference_moisture(i), ...
        linear_moisture(i), ...
        compensated_moisture(i), ...
        nonlinear_percentage_error(i));

end


%% =========================================================
% 14. GRAPH 1
% RAW SENSOR VS REFERENCE MOISTURE
% ==========================================================

figure;

scatter(sensor_raw, reference_moisture, 25, 'filled');

xlabel('DFRobot1 Raw Sensor Reading');
ylabel('Reference Moisture VWC (%)');

title('Raw Sensor Reading vs Reference Moisture');

grid on;


%% =========================================================
% 15. GRAPH 2
% LINEAR VS NONLINEAR CALIBRATION
% ==========================================================

figure;

scatter(sensor_raw, reference_moisture, 25, 'filled');

hold on;

x_fit = linspace(min(sensor_raw), ...
                 max(sensor_raw), 200);

linear_fit = polyval(linear_coeff, x_fit);

quadratic_fit = polyval(quadratic_coeff, x_fit);

plot(x_fit, linear_fit, 'LineWidth', 2);

plot(x_fit, quadratic_fit, 'LineWidth', 2);

xlabel('Raw Sensor Reading');

ylabel('Moisture VWC (%)');

title('Linear and Nonlinear Sensor Calibration');

legend('Reference Data', ...
       'Linear Fit', ...
       'Quadratic Fit', ...
       'Location', 'best');

grid on;

hold off;


%% =========================================================
% 16. GRAPH 3
% REFERENCE VS COMPENSATED MOISTURE
% ==========================================================

figure;

plot(reference_moisture, 'LineWidth', 1.5);

hold on;

plot(compensated_moisture, 'LineWidth', 1.5);

xlabel('Sample Number');

ylabel('Moisture VWC (%)');

title('Reference vs Nonlinearly Compensated Moisture');

legend('Reference VWC', ...
       'Compensated Moisture', ...
       'Location', 'best');

grid on;

hold off;


%% =========================================================
% 17. GRAPH 4
% NONLINEAR PERCENTAGE ERROR
% ==========================================================

figure;

plot(nonlinear_percentage_error, 'LineWidth', 1.5);

xlabel('Sample Number');

ylabel('Percentage Error (%)');

title('Nonlinear Calibration Percentage Error');

grid on;


%% =========================================================
% 18. AUTOMATIC IRRIGATION
% ==========================================================

% These are PROJECT DESIGN THRESHOLDS.
%
% Below 11%  -> Dry    -> Pump ON
% 11% to 12% -> Medium -> Pump OFF
% Above 12%  -> Wet    -> Pump OFF

dry_threshold = 11;
wet_threshold = 12;


pump = zeros(length(compensated_moisture), 1);

condition = strings(length(compensated_moisture), 1);


for i = 1:length(compensated_moisture)

    if compensated_moisture(i) < dry_threshold

        % Soil is dry
        pump(i) = 1;
        condition(i) = "Dry";

    elseif compensated_moisture(i) < wet_threshold

        % Soil has medium moisture
        pump(i) = 0;
        condition(i) = "Medium";

    else

        % Soil is wet
        pump(i) = 0;
        condition(i) = "Wet";

    end

end


%% =========================================================
% 19. DISPLAY IRRIGATION RESULTS
% ==========================================================

fprintf('\n============================================\n');
fprintf('       AUTOMATIC IRRIGATION RESULTS\n');
fprintf('============================================\n');

fprintf('Dry threshold    = %.2f %%\n', dry_threshold);
fprintf('Wet threshold    = %.2f %%\n', wet_threshold);

fprintf('\nPump ON samples  = %d\n', sum(pump == 1));

fprintf('Pump OFF samples = %d\n', sum(pump == 0));


%% =========================================================
% 20. GRAPH 5
% PUMP STATUS
% ==========================================================

figure;

stairs(pump, 'LineWidth', 1.5);

xlabel('Sample Number');

ylabel('Pump Status');

title('Automatic Irrigation Control');

yticks([0 1]);

yticklabels({'Pump OFF', 'Pump ON'});

ylim([-0.2 1.2]);

grid on;


%% =========================================================
% 21. GRAPH 6
% SOIL CONDITION
% ==========================================================

figure;

plot(compensated_moisture, 'LineWidth', 1.5);

hold on;

yline(dry_threshold, '--', 'Dry Threshold');

yline(wet_threshold, '--', 'Wet Threshold');

xlabel('Sample Number');

ylabel('Compensated Moisture (%)');

title('Soil Moisture and Irrigation Thresholds');

legend('Compensated Moisture', ...
       'Dry Threshold', ...
       'Wet Threshold', ...
       'Location', 'best');

grid on;

hold off;


%% =========================================================
% 22. FINAL PROJECT SUMMARY
% ==========================================================

fprintf('\n============================================\n');
fprintf('             FINAL SUMMARY\n');
fprintf('============================================\n');

fprintf('Total valid samples = %d\n', length(sensor_raw));

fprintf('\n--- Linear Calibration ---\n');
fprintf('MAPE = %.4f %%\n', linear_MAPE);
fprintf('RMSE = %.4f %% VWC\n', linear_RMSE);
fprintf('R^2  = %.4f\n', linear_R2);

fprintf('\n--- Nonlinear Calibration ---\n');
fprintf('MAPE = %.4f %%\n', nonlinear_MAPE);
fprintf('RMSE = %.4f %% VWC\n', nonlinear_RMSE);
fprintf('R^2  = %.4f\n', nonlinear_R2);

fprintf('\n--- Irrigation ---\n');
fprintf('Pump ON  = %d samples\n', sum(pump == 1));
fprintf('Pump OFF = %d samples\n', sum(pump == 0));

fprintf('\n============================================\n');
fprintf(' Nonlinear Soil Moisture Compensation\n');
fprintf(' and Automatic Irrigation Completed\n');
fprintf('============================================\n');

