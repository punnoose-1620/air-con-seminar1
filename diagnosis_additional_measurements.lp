% Base observations
threeway_in(cool).
scale_in(2).
ambient_temp(25).
temp(air_in, 27).
flow(air_in, on).

% Actual observation contradicting expected 21C at air_out
temp(air_out, 25).
flow(air_out, on).

% Additional Measurement 2: input to valve
flow(inp(v), on).
temp(inp(v), 25).

% Additional Measurement 3: switch out2 is passing through correctly
flow(out2(s), on).
temp(out2(s), 27).