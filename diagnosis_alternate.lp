% Measurements at the cooler
flow(inp(c), on).
temp(inp(c), 27).
flow(out(c), on).
temp(out(c), 25).

% Expected under normal behavior: out(c) should be 21 (27 - 2*3)
% With n = 1 in the main model, this should diagnose ab(c).