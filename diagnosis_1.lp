% Diagnosis Test Case from first diagnosis section in Canva
% Initial Observations
threeway_in(cool).
scale_in(2).
ambient_temp(25).
temp(air_in, 27).
flow(air_in, on).

% Actual Observation (conflicts with expected behavior)
% Expected: temp(air_out, 21) - should be 27 - 2*3 = 21
% Actual: temp(air_out, 25) - no cooling occurred
temp(air_out, 25).
flow(air_out, on).

% This observation constraint will force the diagnosis system
% to find which component(s) are abnormal to explain why
% the temperature is 25°C instead of the expected 21°C