%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function: displayFormattedTransitions
%
% Description:
% This function prints the transitions of an automaton in a readable format,
% where the source and target states are represented as `(num,N)` or `(num,F)`.
% The format distinguishes between normal ('N') and fault ('F') states based on the second
% element of the state.
%
% Input:
% - transitions: Cell with transitions in the format `{State1, Event, State2}`, where:
%   - `State1`: Source state (array `[num1, num2]` or string `'(num1,num2)'`).
%   - `Event`: Event associated with the transition (string).
%   - `State2`: Destination state (array `[num1, num2]` or string `'(num1,num2)'`).
%
% Output:
% - No value returned. Transitions are printed to the console in the format:
%   `State1 Event State2`
%
% Operation:
% 1. Print a header with the column names (`State1`, `Event`, `State2`).
% 2. Iterates over all transitions provided in `transitions`.
% 3. Converts the source and target states to readable `(num,N)` or `(num,F)` format
%   using the `formatState` function.
% 4. Prints each formatted transition in one line.
%
% Auxiliary Function:
% - `formatState`: Converts a state in the form `[num1, num2]` or `'(num1,num2)'`.
% into the readable format `(num,N)` or `(num,F)`.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function transitions_matrix=displayFormattedTransitions(transitions)
    
    transitions_matrix={};
    fprintf('Transitions:\n');
    fprintf('%-10s %-10s %-10s\n', 'State1', 'Event', 'State2');
    
    % Itera on all transitions
    for i = 1:size(transitions, 1)
        % Source status
        state1 = transitions{i, 1};
        state1_formatted = formatState(state1);
        
        % Destination status
        state2 = transitions{i, 3};
        state2_formatted = formatState(state2);

        % Event
        event = transitions{i, 2};
        transitions_matrix={transitions_matrix, state1_formatted, event, state2_formatted};
        %Print formatted transition
        fprintf('%-10s %-10s %-10s\n', state1_formatted, event, state2_formatted);
    end
end

function formattedState = formatState(state)
    % formatState Converts state to format (num,N) or (num,F)
    % state: State in the form [num,1], [num,2], or string '(num,num)'.
    
    % If the status is a string, parse it
    if ischar(state) || isstring(state)
        %Remove parentheses and divide into components
        state = sscanf(state, '(%d,%d)')';
    end

    % Check the second element of the status
    if state(2) == 1
        formattedState = sprintf('(%d,N)', state(1));
    elseif state(2) == 2
        formattedState = sprintf('(%d,F)', state(1));
    else
        error('Unexpected state format: %s', mat2str(state));
    end
end