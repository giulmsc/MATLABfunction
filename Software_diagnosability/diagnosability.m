%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Diagnosability problem
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% A system is diagnosable if, after the occurence of a fault the produced 
% observation can remain ambiguous only for finite number of steps. 
%
% A DFA G is diagnosable if its does not contain uncertain indeterminate 
% cycles. An uncertain cycle is called an indeterminate cycle if its
% refined sequence contains only states whose diagnosis values is U.
% So, a DFA G is diagnosable if and only if its diagnoser Diag(G) does not
% contain indetermiante cycles.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Function: diagnosability
%
% Description:
% This function verifies the **diagnosability** of a discrete event system.
% Uses information from the observer, transitions and diagnoses of states
% to detect any **uncertain cycles** (ambiguous cycles) and determine their
% diagnosability.
%
% Input:
% - filename: String containing the path and filename of the system file
%   (specified in a format compatible with the `diagnoser` function).
% - cycle_graph: Boolean flag (1 or 0):
%   - `1` -> Displays uncertain cycles found graphically.
%   - `0` -> Does not display cycle graphs.
%
% Output:
% - No value returned explicitly.
% - Displays on screen:
% - System diagnosis results.
% - Diagnosability status (diagnosable or non-diagnosable).
% - Optionally, generates uncertain cycle graphs if `cycle_graph` is active.
%
% Operation:
% 1. **Diagnoser generation**:
%   - Calls the `diagnoser` function to generate:
%   - `DIAG`: Structure with observer status information and transitions.
%   - `recG`: Structure with information about system states and transitions.
% 2. **Observer diagnosis**:
%   - Call `diagnose_observer` to determine the diagnosis of each state
%       of the observer (e.g. 'N', 'F', 'U').
% 3. **Cycle Search and Analysis**:
%   - Call `cycle_check` to detect any uncertain cycles and determine their
%       the diagnosability.
%   - Displays diagnosis results and, if required, graphs of uncertain cycles
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function diagnosability(filename, cycle_graph)

[DIAG, recG]=diagnoser(filename,0,0,0,0,0,0,0,1);

diagnosis=diagnose_observer(DIAG.observer_state_matrix, recG.state_map);

cycle_check(recG, DIAG, diagnosis,cycle_graph);

end 