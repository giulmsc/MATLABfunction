%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function: displayObserverStates
%
% Description:
% This function displays the physical states contained in each observer state.
% States are displayed in the format `(num,N)` or `(num,F)`, where:
% - `num` is the state identifier.
% - `N` indicates a normal state.
% - `F` indicates a fault state.
% In addition, the function shows the diagnosis associated with each observer state
% (e.g. `N`, `F`, `U`).
%
% Input:
% - observer_matrix: Binary matrix of observer states, where:
% - Each row represents an observer state.
% - Each column indicates whether a particular state is contained in the state
%   of the observer (1 = contained, 0 = not contained).
% - states_map: Map associating numeric indices to physical states in the format `(num,num)`.
% - print: Boolean flag (1 or 0) to print the inverse map of states:
% - `1` -> Print reverse map.
% - `0` -> Print nothing.
%
% Output:
% - No value returned. States and diagnostics are printed in the console.
%
% Operation:
% 1. **Inverting the States Map**:
%   - The `states_map` is inverted to obtain physical states from
%     from the numeric indices.
% 2. **Identification of Contained States**:
%   - For each observer state, identify the contained physical states
%     by analysing the corresponding row of the `observer_matrix`.
% 3. **State Formatting**:
%   - Converts each physical state to `(num,N)` or `(num,F)` format based on the
%     second associated number.
% 4. **Diagnosis of States**:
%   - Calls the `diagnose_observer` function to calculate the diagnosis ("N", "F", "U")
%     of each observer state.
% 5. **Diagnose**:
%   - Prints the contained physical states and diagnosis for each observer state.
%
% Utilisation:
% displayObserverStates(observer_matrix, states_map, 1);
% Displays the observer's states and diagnoses, also printing the reverse map.
%
% Dependencies:
% - diagnose_observer: Function to calculate the diagnosis of the observer states.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function displayObserverStates(observer_matrix, states_map, print)
% Estrarre gli stati contenuti in ciascuno stato osservatore
% Estrarre gli stati contenuti in ciascuno stato osservatore
num_observer_states = size(observer_matrix, 1);
observer_states = cell(num_observer_states, 1);

states_map_inverse=containers.Map(values(states_map), keys(states_map));
if print ==1 
    keys_states = keys(states_map_inverse); %Extracts keys (states)
    values_states = values(states_map_inverse); % Extracts values (numbers)
    disp('states map inverse:');
        for i = 1:numel(keys_states)
            fprintf('%d = %s\n', keys_states{i}, values_states{i});
        end
end
% Trasformare la mappa degli stati in un vettore lineare
for i = 1:num_observer_states
    % Trova gli indici degli stati contenuti
    contained_states = find(observer_matrix(i, :) == 1);
    % Recupera e converte gli stati fisici
    observer_states{i} = cell(1, numel(contained_states));
    for j = 1:numel(contained_states)
        original_state = states_map_inverse(contained_states(j));
        
        % Estrai i numeri dagli stati
        nums = sscanf(original_state, '(%d,%d)'); % Estrae [1; 1], [1; 2], ecc.
        first_num = nums(1);
        second_num = nums(2);
        
        % Converti il secondo numero in N o F
        if second_num == 1
            new_state = sprintf('(%d,N)', first_num);
        elseif second_num == 2
            new_state = sprintf('(%d,F)', first_num);
        else
            error('Stato non riconosciuto: %s', original_state);
        end
        
        % Salva lo stato convertito
        observer_states{i}{j} = new_state;
    end
end

diagnosis=diagnose_observer(observer_matrix, states_map);
% Visualizzazione del risultato
%fprintf('%-8s %-12s', 'Observer states', 'Diagnosis');
%fprintf('\n');
fprintf('Observer states and diagnosis:');
fprintf('\n');
disp('---------------------------');
for i = 1:num_observer_states
    fprintf('Observer State %d: ', i);
    if isempty(observer_states{i})
        fprintf('No contained states\n');
    else
        fprintf('%s ', observer_states{i}{:}, diagnosis{i});
        fprintf('\n');
    end
end
end