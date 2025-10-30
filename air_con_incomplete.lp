% components:
% there is a heater 'h', cooler 'c', switch 's', and valve 'v' component
comp(h).  type(h, heater).
% Declare remaining components
comp(c).  type(c, cooler).
comp(s).  type(s, switch).
comp(v).  type(v, valve).

% connections:
% we only need to model the connections for the air flow
% connections are according to the figure
conn(air_in, inp(s)).
conn(out1(s), inp(h)).
% Additional Conditions for connection modelling
conn(out2(s), inp(c)).
conn(out(h), inp1(v)).
conn(out(c), inp2(v)).
conn(out(v), air_out).

% propagation of values (air flow 'flow/2' and temperature 'temp/2'):
% temperature propagates from the input to the output and vice versa if air is flowing
% if air is not flowing, the temperature is the ambient one (ambient_temp(T))
% air flow always propagates from the input to the output and vice versa
flow(P2, F) :- conn(P1, P2), flow(P1, F).
flow(P1, F) :- conn(P1, P2), flow(P2, F).
% Additional Propagation rules for temperature management completion
temp(P2,T) :- conn(P1,P2), temp(P1,T), flow(P1,on).
temp(P1,T) :- conn(P1,P2), temp(P2,T), flow(P2,on).
temp(P,T) :- flow(P,off), ambient_temp(T).

% integrity constraints:
% we can't have different flows or temperatures at the same point
:- flow(P,F1), flow(P,F2), F1 != F2.
% Add one more integrity constraint to ensure that the temperature is the same at the same point
:- temp(P,T1), temp(P,T2), T1 != T2.

% heater:
% if air is flowing into the heater, air is flowing also out of the heater
% then, the temperature increases by the scale factor times 3
% if air is not flowing into the heater, air is not flowing out of the heater
flow(out(C), F) :- comp(C), type(C, heater), nab(C), flow(inp(C), F).
flow(inp(C), F) :- comp(C), type(C, heater), nab(C), flow(out(C), F).
temp(out(C), T + S*3) :- comp(C), type(C, heater), nab(C), temp(inp(C), T), flow(inp(C), on), scale_in(S).
temp(inp(C), T - S*3) :- comp(C), type(C, heater), nab(C), temp(out(C), T), flow(out(C), on), scale_in(S).
                              
% cooler:
% if air is flowing into the cooler, air is flowing also out of the cooler
% then, the temperature decreases by the scale factor times 3
% if air is not flowing into the cooler, air is not flowing out of the cooler
% Add more propagation rules for temperature cooler management completion
flow(out(C), F) :- comp(C), type(C,cooler), nab(C), flow(inp(C), F).
flow(inp(C), F) :- comp(C), type(C,cooler), nab(C), flow(out(C), F).
temp(out(C), T - S*3) :- comp(C), type(C, cooler), nab(C), temp(inp(C), T), flow(inp(C), on), scale_in(S).
temp(inp(C), T + S*3) :- comp(C), type(C, cooler), nab(C), temp(out(C), T), flow(out(C), on), scale_in(S).

% switch:
% if air is not flowing into the switch, air is not flowing out of the switch
% otherwise, air is flowing out of the switch depending on the threeway valve
% temperature is not changed by the switch
flow(out1(C), off) :- comp(C), type(C, switch), nab(C), threeway_in(off).
flow(out2(C), off) :- comp(C), type(C, switch), nab(C), threeway_in(off).
flow(out1(C), F)   :- comp(C), type(C, switch), nab(C), flow(inp(C), F), threeway_in(heat).
flow(out2(C), off) :- comp(C), type(C, switch), nab(C), flow(inp(C), F), threeway_in(heat).
temp(out1(C), T)   :- comp(C), type(C, switch), nab(C), temp(inp(C), T), flow(out1(C), on), threeway_in(heat).
flow(out2(C), F)   :- comp(C), type(C, switch), nab(C), flow(inp(C), F), threeway_in(cool).
flow(out1(C), off) :- comp(C), type(C, switch), nab(C), flow(inp(C), F), threeway_in(cool).
temp(out2(C), T)   :- comp(C), type(C, switch), nab(C), temp(inp(C), T), flow(out2(C), on), threeway_in(cool).
flow(inp(C), F) :- comp(C), type(C, switch), nab(C), flow(out1(C), F), threeway_in(heat).
flow(inp(C), F) :- comp(C), type(C, switch), nab(C), flow(out2(C), F), threeway_in(cool).
temp(inp(C), T) :- comp(C), type(C, switch), nab(C), temp(out1(C), T), flow(inp(C), on), threeway_in(heat).
temp(inp(C), T) :- comp(C), type(C, switch), nab(C), temp(out2(C), T), flow(inp(C), on), threeway_in(cool).

% valve:
% depending on threeway_in, the output is either off or the input from the heater or cooler is passed through
% Add the missing propagation rules for valve management completion
flow(out(C), off) :- comp(C), type(C, valve), nab(C), threeway_in(off).
flow(out(C), F) :- comp(C), type(C, valve), nab(C), flow(inp(C), F), threeway_in(heat).
flow(out(C), F) :- comp(C), type(C, valve), nab(C), flow(inp(C), F), threeway_in(cool).
temp(out(C), T) :- comp(C), type(C, valve), nab(C), temp(inp(C), T), flow(out(C), on), threeway_in(heat).
temp(out(C), T) :- comp(C), type(C, valve), nab(C), temp(inp(C), T), flow(out(C), on), threeway_in(cool).
flow(inp(C), F) :- comp(C), type(C, valve), nab(C), flow(out(C), F), threeway_in(heat).
flow(inp(C), F) :- comp(C), type(C, valve), nab(C), flow(out(C), F), threeway_in(cool).
temp(inp(C), T) :- comp(C), type(C, valve), nab(C), temp(out(C), T), flow(inp(C), on), threeway_in(heat).
temp(inp(C), T) :- comp(C), type(C, valve), nab(C), temp(out(C), T), flow(inp(C), on), threeway_in(cool).

% search for diagnoses of fixed size
#const n = 1.
{ ab(C); nab(C) } = 1 :- comp(C).
% Add one more constraint to ensure that the number of abnormal components is less than or equal to n
n { ab(C) : comp(C) } n.

% Setting first observations from Canvas
ambient_temp(25).
threeway_in(cool).
scale_in(2).
flow(air_in,on).
temp(air_in,27).
temp(air_out, 25).
flow(air_out, on).

% Display
% t_out(T) :- temp(air_out, T).
% #show t_out/1.
#show ab/1.