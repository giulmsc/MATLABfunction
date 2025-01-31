%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function: diagnose_observer
%
% Description:
% This function determines the diagnosis of each observer state
% in a discrete event system. The diagnosis is based on the **state pairs**
% mapped in the observer and indicates whether the state is:
%   - 'N' (No-Fault) -> The state represents normal behaviour.
%   - "F" (Fault) -> The state represents a fault.
%   - "U" (Unknown) -> The state is ambiguous and may represent either normal or faulty behaviour.
%       normal and faults.
%
% Input:
% - observer_matrix: Binary matrix of observer states.
%   Each row represents an observer state and the columns
%   indicate which active states of the system are represented.
% - state_map: Map associating numeric indices with the actual states of the system
%   as symbolic state pairs in the format '(x,y)', where:
%       - `x`: State identifier.
%       - `y`: Type of state (1 = N, 2 = F).
%
% Output:
% - diagnosis: Array of strings with the diagnosis for each state
%   of the observer:
%                   - "N" -> Normal state (No-Fault).
%                   - "F" -> Fault state (Fault).
%                   - "U" -> Uncertain state (Unknown).
%
% Operation:
% 1. Invert the `state_map` to quickly access symbolic pairs
%    of the actual states from their numeric index.
% 2. For each observer state:
%   - Identifies the active states in the corresponding row of the matrix.
%   - Analyses the second value of the active pairs:
%       - `1` -> Normal state (No-Fault, "N").
%       - `2` -> Fault state (Fault, "F").
%       - Determines the diagnosis according to the combination of the active states:
%       - `N` only -> Diagnosis `N`.
%       - Only "F" -> Diagnosis "F".
%       - Both -> Diagnosis "U".
function diagnosis = diagnose_observer(observer_matrix, state_map)
   
    
    % Invert state_map to access pairs from an index
    state_map_inverse = containers.Map(values(state_map), keys(state_map));
    
    num_states = size(observer_matrix, 1); % Number of observer states
    diagnosis = strings(num_states, 1);   % Diagnosis of states (N, F, U)

    for i = 1:num_states
        % Active states in current row
        active_states = find(observer_matrix(i, :) == 1);

        % Initialise flags for No-Fault (N) and Fault (F)
        has_no_fault = false;
        has_fault = false;

        % Analizza ciascuno stato attivo
        for state_index = active_states
            % Finds the pair associated with the state index
            pair = state_map_inverse(state_index); % Get the pair "(x,y)"
            pair_values = str2num(pair(2:end-1)); % Converte "(x,y)" in [x, y]

            % Determines whether the status is N or F
            if pair_values(2) == 1 % The second element is 'N'
                has_no_fault = true;
            elseif pair_values(2) == 2 % The second element is 'F'.
                has_fault = true;
            end
        end

        % Determines the diagnosis of the observer's state
        if has_no_fault && ~has_fault
            diagnosis(i) = "N"; % No-Fault states only
        elseif has_fault && ~has_no_fault
            diagnosis(i) = "F"; %Fault states only
        else
            diagnosis(i) = "U"; % Both No-Fault and Fault states
        end
    end
end