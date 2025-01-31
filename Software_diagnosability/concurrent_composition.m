%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function: concurrent_composition 
% Description:
% This function calculates the **concurrent composition** of two finite-state automata.
% (G1 and G2). The concurrent composition combines the states and transitions of the two
% automata, producing a new DFA (Deterministic Finite Automaton) representing
% the combined behaviour of the two systems.
%
% Input:
% - G1: Structure representing the first automaton, with fields:
% - G1.states: states of G1.
% - G1.alphabet: Alphabet (event symbols) of G1.
% - G1.transitions: G1 transitions (format: {state1, event, state2}).
% - G1.initialStates: Initial states of G1.
% - G1.finalStates: Final states of G1.
% - G1.obs_events/unobs_events/fault_events: Observable, unobservable, failure events.
% - G2: Structure representing the second automaton, with fields similar to G1.
% - print: Boolean flag (1 or 0) to print composition information:
% - Global alphabet.
% - States and map of states.
% - Transitions in symbolic and numeric format.
%
% Output:
% - DFA: Structure representing the automaton resulting from the composition, with fields:
% - DFA.states: States of the combined DFA.
% - DFA.alphabet: Global alphabet.
% - DFA.transitions: Transitions in symbolic format ({state1, event, state2}).
% - DFA.D: Numerical matrix of transitions.
% - DFA.obs_events/unobs_events/fault_events: Observable, unobservable, failure events.
% - DFA.initialStates: Initial state of the composition.
% - DFA.finalStates: Final states of the combined DFA.
% - DFA.state_map: Map between symbolic states and numeric indices.
%
% Operation:
% 1. **Union of Alphabets**:
%   - Combines the alphabets of G1 and G2 into one global alphabet.
% 2. **Event Mapping**:
%    - Generates a numerical map for observable, unobservable and failure events.
% 3. **Composition of States**:
%    - Combines the initial and subsequent states of the two automata into pairs (state1, state2).
% 4. **Generation of Transitions**:
%   - Calculates the transitions for each symbol of the global alphabet, respecting the
% transitions of the two automata.
% 5. **Final States**:
%    - Defines final states as combinations of G1 and G2 final states.
% 6. **Numerical and Binary Matrix**:
%    - Converts states and transitions to numeric format.
% 7. **Print (optional)**:
%   - Displays states, transitions and state maps.
%
% Usage:
% DFA = concurrent_composition(G1, G2, 1);
% Combines G1 and G2, printing the composition details.
%
% this functions depend on the follows function:
% - merge_events: Combines observable/unobservable/fault events of G1 and G2.
% - update_transitions_with_global_map: Updates transitions using the global map.
% - generate_event_map: Generates a numeric map for observable or unobservable events.
% - compute_next_state: Calculates the next state during computation.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function DFA = concurrent_composition(G1, G2, print)

% DFA is a structure DFA is a structure in which the characteristics of 
% the obtained automaton are stored 
DFA = struct();
    DFA.states = [];
    DFA.alphabet = union(G1.alphabet, G2.alphabet); %Alphabet is the union of the two automata alphabet 
    DFA.alphabet_map=[];
    [obs_events, unobs_events,fault_events] = merge_events(G1,G2);          
    DFA.obs_events=obs_events;
    DFA.obs_map=[];
    DFA.unobs_events=unobs_events;
    DFA.unobs_map=[];
    DFA.fault_events=fault_events;
    DFA.transitions = {};
    DFA.D=[];
    DFA.initialStates = [G1.initialStates, G2.initialStates];
    DFA.finalStates = [];
    DFA.state_map=[];

    % global event mapping
    global_alphabet_map = containers.Map(DFA.alphabet, num2cell(1:length(DFA.alphabet)));
    disp('---------------------------');
    if print==1
        disp('global alphabet map:');
            keys_global_alphabet_map = keys(global_alphabet_map);
            for i = 1:length(keys_global_alphabet_map)
              simbolo = keys_global_alphabet_map{i};
              numero = global_alphabet_map(simbolo);
              fprintf('%-5s = %-5d\n', simbolo, numero);
            end
         disp('---------------------------');
    end
    DFA.alphabet_map=global_alphabet_map;
    DFA.obs_map=generate_event_map(DFA.obs_events,global_alphabet_map);
    DFA.unobs_map=generate_event_map(DFA.unobs_events,global_alphabet_map);
    alphabet1_global = cellfun(@(s) global_alphabet_map(s), G1.alphabet);
    alphabet2_global = cellfun(@(s) global_alphabet_map(s), G2.alphabet);
    % updated transitions with global event map
    transitions1_updated = update_transitions_with_global_map(G1.transitions, global_alphabet_map);
    transitions2_updated = update_transitions_with_global_map(G2.transitions, global_alphabet_map);

    % Initial state of DFA
    X_new = {DFA.initialStates};
    DFA.states = zeros(0, numel(DFA.initialStates));

    while ~isempty(X_new)
        % Select a state to explore
        x = X_new{1};
        X_new(1) = []; 

        % Add current status if not already present
        if ~ismember(x, DFA.states, 'rows')
            DFA.states = [DFA.states; x];
        end

        % for each event in the alphabet
        for e = DFA.alphabet
            e_num = global_alphabet_map(e{1});
            
            % compute next states
            x_next = compute_next_state(x, e_num, transitions1_updated, transitions2_updated, ...
                                        alphabet1_global, alphabet2_global);
            if iscell(x_next)
                x_next = cell2mat(x_next);
            end
            
            % add transitions if valid
            if ~isempty(x_next) && all(x_next ~= -1)
                % Label the compound state as ‘(state1, state2)’.
                label_current = sprintf('(%s,%s)', mat2str(x(1)), mat2str(x(2)));
                label_next = sprintf('(%s,%s)', mat2str(x_next(1)), mat2str(x_next(2)));
                
                % Add transition to structure
                DFA.transitions = [DFA.transitions; {label_current, e{1}, label_next}];
                
                % If the next state is not already explored, it is considered to be explored
                if ~ismember(x_next, DFA.states, 'rows') && ...
                   ~any(cellfun(@(y) isequal(y, x_next), X_new))
                    X_new{end + 1} = x_next;
                end
            end
        end
    end
    
    % final states
    for i = 1:size(DFA.states, 1)
        state = DFA.states(i, :);
        if ismember(state(1), G1.finalStates) && ismember(state(2), G2.finalStates)
            DFA.finalStates = [DFA.finalStates; state];
        end
    end

    % Remove invalid states (-1)
    DFA.states = DFA.states(all(DFA.states ~= -1, 2), :);
    transitions = DFA.transitions;
   
    %% numeric matrix transitions with labels
    % convert the states and create the mapping
    states = unique([transitions(:, 1); transitions(:, 3)]); % unique states
    state_map = containers.Map(states, 1:numel(states)); % states -> number mapping
    DFA.state_map=state_map;
    
    % Compute numeric matrix
    numeric_transitions = zeros(size(transitions, 1), 3); % initialise matrix
    for i = 1:size(transitions, 1)
        start_state = transitions{i, 1}; % Extract initial state
        event=transitions{i,2};
        end_state = transitions{i, 3};   % Extract final state
        numeric_transitions(i, :) = [
            state_map(start_state), ...     % numeric initial states
            global_alphabet_map(event), ...                       %  event
            state_map(end_state)             % numeric final states
        ];
    end
    % save numeric transition in the DFA
    DFA.D = numeric_transitions;

    %% binary matrix
    % 
    num_states = numel(state_map); % total states of state_map
    
    % compute binary matrix
    binary_matrix = zeros(size(transitions, 1), num_states); % initialise matrix
    
    % 
    for i = 1:size(transitions, 1)
        % Transition Destination State
        end_state = transitions{i, 3};
        
        % Get the numeric index of the target state
        state_index = state_map(end_state);
        
        % Mark 1 in the column corresponding to the destination state
        binary_matrix(i, state_index) = 1;
    end

    %% Display results
    % Save the matrix in the DFA
    DFA.D = numeric_transitions;
   

    % display states and transitions
    %disp(DFA);
    if print == 1
    disp('states:');
    disp(DFA.states);
    %display states map
    keys_states = keys(state_map); %Extracts keys (states)
    values_states = values(state_map); % Extracts values (numbers)
    
        disp('states map:');
        for i = 1:numel(keys_states)
            fprintf('%s = %d\n', keys_states{i}, values_states{i});
        end
   
    disp('---------------------------');
 
    disp('transitions:');
    fprintf('%-8s %-8s %-8s\n', 'State1', 'Event', 'State2'); % Intestazione
    for i = 1:size(DFA.transitions, 1)
         fprintf('%-8s %-8s %-8s\n', DFA.transitions{i, 1}, DFA.transitions{i, 2}, ...
                DFA.transitions{i, 3});
    end
    fprintf('\n');
        disp('---------------------------');
        disp('numeric transitions matrix:');
        fprintf('%-8s %-8s %-8s\n', 'State1', 'Event', 'State2'); % Intestazione
        for i = 1:size(numeric_transitions, 1)
             fprintf('%-8d %-8d %-8d\n', numeric_transitions(i, 1), numeric_transitions(i, 2), ...
                    numeric_transitions(i, 3));
        end
        disp('---------------------------');
    end
 
    %disp(numeric_transitions);
    % Output della matrice binaria
    %disp('binary matrix:');
    %disp(binary_matrix);
end

%% function to update transitions with numbers
function updated_transitions = update_transitions_with_global_map(transitions, global_map)
    updated_transitions = transitions; 
    %disp(transitions);
    for i = 1:size(transitions, 1)
        symbol = transitions{i, 2};
        %disp(['symbol:', symbol]);
        updated_transitions{i, 2} = global_map(symbol); % Replace with the number
    end
end

%% function to merge event of G1 and G2
function [obs_events, unobs_events, fault_events] = merge_events(G1, G2)
    % Union of observable events
    if isfield(G1, 'obs_events') && isfield(G2, 'obs_events')
        obs_events = union(G1.obs_events, G2.obs_events);
    elseif isfield(G1, 'obs_events')
        obs_events = G1.obs_events;
    elseif isfield(G2, 'obs_events')
        obs_events = G2.obs_events;
    else
        obs_events = {}; % Default if the field does not exist in either
    end

    %Union of unobservable events
    if isfield(G1, 'unobs_events') && isfield(G2, 'unobs_events')
        unobs_events = union(G1.unobs_events, G2.unobs_events);
    elseif isfield(G1, 'unobs_events')
        unobs_events = G1.unobs_events;
    elseif isfield(G2, 'unobs_events')
        unobs_events = G2.unobs_events;
    else
        unobs_events = {}; % Default
    end

    %Union of Fault Events
    if isfield(G1, 'fault_events') && isfield(G2, 'fault_events')
        fault_events = union(G1.fault_events, G2.fault_events);
    elseif isfield(G1, 'fault_events')
        fault_events = G1.fault_events;
    elseif isfield(G2, 'fault_events')
        fault_events = G2.fault_events;
    else
        fault_events = {}; % Default
    end
end

%% function to create a generic alphabet map

function event_map = generate_event_map(events, alphabet_map)
    % Generate a numerical map for events based on the alphabet map
    % events: cell array of event strings (e.g., observable or unobservable events)
    % alphabet_map: map of alphabet symbols to numerical indices
    % event_map: numerical array corresponding to the input events
    
    if isempty(events)
        event_map = []; % Return empty if no events are provided
        return;
    end
    
    event_map = zeros(1, numel(events)); % Preallocate the event map
    for i = 1:numel(events)
        event = events{i}; % Get the current event
        if isKey(alphabet_map, event) % Check if the event exists in the alphabet map
            event_map(i) = alphabet_map(event); % Map the event to its numerical index
        else
            error(['Event not found in the alphabet: ', event]);
        end
    end
end

function x_next = compute_next_state(x, e, transitions1, transitions2, alphabet1, alphabet2)
    % Calculates the next state for a state pair and a numeric symbol
   
    % current states
    x1 = x(1); % Current state for G1
    x2 = x(2); % Current state for G2
    %disp(['Current state x: [', num2str(x1), ',', num2str(x2), ']']);
    %disp(['symbol e (number): ', num2str(e)]);
    
    % Verifica appartenenza di e agli alfabeti
    in_E1 = ismember(e, alphabet1); % e ∈ E'
    in_E2 = ismember(e, alphabet2); % e ∈ E''
    %disp(['in_E1: ', num2str(in_E1), ', in_E2: ', num2str(in_E2)]);
    % Variable for next states
    x1_next = [];
    x2_next = [];
    transitions_c1=cell2mat(transitions1);
    transitions_c2=cell2mat(transitions2);
    

    % Case 1: e ∈ E' \ E'' (present only in E')
    if in_E1 && ~in_E2
        %disp('Case: e ∈ E1');
        idx1 = find(transitions_c1(:, 1) == x1 & transitions_c1(:, 2) == e, 1);
        if ~isempty(idx1)
            x1_next = transitions_c1(idx1, 3);
            %disp(['x1_next found: ', num2str(x1_next)]);
        else
           % disp('No transition found in G1.');
        end
        x_next = [x1_next, x2];

    % Case 2: e ∈ E'' \ E' (present only in E'')
    elseif ~in_E1 && in_E2
        %disp('Case: e ∈ E2');
        idx2 = find(transitions_c2(:, 1) == x2 & transitions_c2(:, 2) == e, 1);
        if ~isempty(idx2)
            x2_next = transitions_c2(idx2, 3);
           % disp(['x2_next found: ', num2str(x2_next)]);
        else
           % disp('No transition found in G2.');
        end
        % The status of G1 remains unchanged
        x_next = [x1, x2_next];

    % Case 3: e ∈ E' ∩ E'' (present in both alphabets)
    elseif in_E1 && in_E2
        %disp('Case: e ∈ E');
        idx1 = find(transitions_c1(:, 1) == x1 & transitions_c1(:, 2) == e, 1);
        idx2 = find(transitions_c2(:, 1) == x2 & transitions_c2(:, 2) == e, 1);

        if ~isempty(idx1)
            x1_next = transitions1(idx1, 3);
        else
           % disp('No transition found in G1 for e ∈ E');
        end
        if ~isempty(idx2)
            x2_next = transitions2(idx2, 3);
        else
           % disp('No transition found in G2 for e ∈ E');
        end

        if ~isempty(x1_next) && ~isempty(x2_next)
            x_next = [x1_next, x2_next];
        else
            x_next = []; % If one of the transitions is not defined
        end
        else
        % disp('Case: e does not belong to any of the alphabets.');
        x_next = [];
          
        end
    % --- Adding the final check ---
         if numel(x_next) ~= 2 % check whether the number of elements in x_next corresponds to the exact number 
            if isempty(x_next)
                x_next = []; % Return empty state if there are no valid transitions and x_next is empty
            else
                % If a value is missing from next_state, i.e. 
                % if the transition only starts from one state, complete with a placeholder (e.g. -1)
                x_next = [x_next, -1];
            end
        end
end