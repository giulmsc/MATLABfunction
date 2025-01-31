%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function: displayTransitionMatrix
%
% Description:
% This function creates a readable representation of the transition matrix
% of an observer. Transitions are described in the format `{State1, Event, State2}`:
%    - `State1`: Source state.
%   - `Event`: Event label (e.g. 'a', 'b', ...).
%   - `State2`: Destination State.
%
% Input:
%   - observer_transitions: Numerical matrix of transitions, where each line is in the format:
%   - `[State1, Event, State2]`.
%   - alphabet_map: Map associating event numbers with their symbolic labels
%       (e.g. 1 -> 'a', 2 -> 'b').
%
% Output:
%   - No value returned. The transition matrix is printed to the console
%   in readable format:
%       `State1 Event State2`
%
% Operation:
% 1. **Inverting the Event Map**:
%   - The `alphabet_map` is inverted to get the symbolic labels
%       (e.g. 1 -> 'a') from the event numbers.
% 2. **Creation of the Transition Matrix**:
%   - For each row of `observer_transitions`, map the event number to its
%     symbolic label.
%   - Saves the source, event and destination states in a readable cell.
% 3. **Print**:
%   - Displays the formatted transitions matrix with readable header and rows.
%
% Usage:
% displayTransitionMatrix(observer_transitions, alphabet_map);
% Displays the readable transitions matrix.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function displayTransitionMatrix(observer_transitions, alphabet_map)
    % Crea una matrice di transizione leggibile partendo dalle transizioni osservatore
    % e dalla mappa degli stati.

    % Inizializza una cella per contenere la matrice di transizione
    transition_matrix = cell(size(observer_transitions, 1), 3);

    for i = 1:size(observer_transitions, 1)
        % Estrai stato1, evento e stato2 dalla transizione
        state1 = observer_transitions(i, 1);
        event = observer_transitions(i, 2);
        state2 = observer_transitions(i, 3);
    
        event_map=containers.Map(values(alphabet_map),keys(alphabet_map));
        event_label = event_map(event); % Mappa evento in un'etichetta (es. 'a', 'b', ...)

        % Salva nella matrice
        transition_matrix{i, 1} = state1;
        transition_matrix{i, 2} = event_label;
        transition_matrix{i, 3} = state2;
    end
    fprintf('--------------------------------');
    fprintf('\n')
    fprintf('Observer transitions:')
    fprintf('\n')
    fprintf('%-8s %-8s %-8s\n', 'State1', 'Event', 'State2'); % Intestazione
    for i = 1:size(transition_matrix, 1)
         fprintf('%-8d %-8s %-8d\n', transition_matrix{i,1}, transition_matrix{i,2}, ...
                transition_matrix{i,3});
    end
    fprintf('\n')
end

