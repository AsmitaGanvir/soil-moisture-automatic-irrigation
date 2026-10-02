# soil-moisture-automatic-irrigation
Numerical analysis of soil moisture measurement and automatic irrigation using MATLAB.

# Soil Moisture Sensor Measurement and Automatic Irrigation

Project Overview:

This project focuses on soil moisture measurement and automatic irrigation using numerical methods and MATLAB.

The soil moisture sensor provides a raw sensor reading. Numerical methods are used to process and calibrate the sensor data to estimate soil moisture. Based on the estimated moisture level, the irrigation system determines whether the water pump should be turned ON or OFF.

MATLAB is used for dataset analysis, numerical calculations, visualization, and simulation of the irrigation control system.

Objectives:

- To analyze soil moisture sensor data.
- To process raw sensor readings using numerical methods.
- To estimate soil moisture percentage.
- To classify soil conditions as Dry, Medium, or Wet.
- To simulate automatic irrigation control.
- To visualize sensor readings and irrigation results using MATLAB.

Proposed Hardware:

The proposed system consists of:

- Arduino UNO
- Capacitive Soil Moisture Sensor
- Relay Module
- DC Water Pump
- LCD Display
- External Power Supply

The hardware is proposed for the automatic irrigation system, while the main data analysis and numerical implementation are performed in MATLAB.

Dataset:

The project uses a soil moisture dataset obtained from a publicly available GitHub repository.

The dataset contains soil moisture sensor measurements that are analyzed using MATLAB.

Numerical Method:

The sensor data is processed using numerical data scaling/calibration techniques.

The general moisture estimation is represented as:

M = ((1023 - Sensor Reading) / 1023) × 100

where:

- M = estimated moisture percentage
- Sensor Reading = raw sensor value
- 1023 = maximum 10-bit ADC value

The processed data is then used for soil-condition classification and irrigation control.

MATLAB Implementation:

MATLAB is used to:

1. Import the soil moisture dataset.
2. Extract sensor readings.
3. Remove invalid data.
4. Calculate moisture values.
5. Classify soil conditions.
6. Simulate pump ON/OFF control.
7. Generate graphs for analysis.

Results:

The MATLAB implementation produces:

- Soil moisture sensor reading graph
- Calculated moisture percentage graph
- Automatic irrigation/pump status graph

The generated results are available in the `Results` folder.

Project Structure:

```text
soil-moisture-automatic-irrigation
│
├── Dataset
│   └── soillog.csv
│
├── MATLAB
│   └── soil_moisture_analysis.m
│
├── Results
│   ├── sensor_reading.png
│   ├── moisture_percentage.png
│   └── pump_status.png
│
└── README.md
