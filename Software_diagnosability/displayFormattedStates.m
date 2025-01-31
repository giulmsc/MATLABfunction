% Function: displayFormattedStates
%
% Description:
% This function prints the states of a system in a readable format,
% adding a label to distinguish between normal ('N') and fault ('F') states.
% The state format is `(num,N)` or `(num,F)`, where:
%   - `num` represents the state identifier.
%   - `N` indicates a normal state.
%   - `F` indicates a fault state.
%
% Input:
% - states: Matrix of states where each line represents a state in the form:
%   - `[num1, num2]`:
%   - `num1`: State identifier.
%   - `num2`: Type of state (1 = N, 2 = F).
%
% Output:
% - No value returned. States are printed out in console in readable format.
%
% Operation:
% 1. Iterates on each row of the `states` array.
% 2.Converts the state to the form `(num,N)` or `(num,F)` using the `formatState` function.
% 3. Prints the formatted state.
%
% Auxiliary Function:
% - `formatState`: Converts the state to the readable form `(num,N)` or `(num,F)`.


function displayFormattedStates(states)
    % displayFormattedStates Stampa gli stati con (N/F) in base al secondo numero
    % states: matrice di stati [num1 num2], dove num2 determina se è N o F

    % Intestazione
    fprintf('States:\n');
    
    % Itera su tutti gli stati
    for i = 1:size(states, 1)
        % Ottieni lo stato corrente
        state = states(i, :);
        
        % Convertilo in formato (num,N) o (num,F)
        formattedState = formatState(state);
        
        % Stampa lo stato formattato
        fprintf('%s\n', formattedState);
    end
end

function formattedState = formatState(state)
    % formatState Converte lo stato in formato (num,N) o (num,F)
    % state: Stato nella forma [num1, num2]
    
    if state(2) == 1
        formattedState = sprintf('%8d,N', state(1));
    elseif state(2) == 2
        formattedState = sprintf('%8d,F', state(1));
    else
        error('Unexpected state format: %s', mat2str(state));
    end
end