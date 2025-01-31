%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% function to refine the cycle  
% Description:
% This function analyses and refines an uncertain cycle (ambiguous cycle) identified
% in the observer of a discrete event system. It calculates the observable states
% (α-states) and unobservable (β-states) attainable by the cycle, determining
% the diagnosis associated with each of them (e.g. 'N' for normal, 'F' for fault). 
%
% 
% INPUT:
    % observer_matrix - Matrix of observer states
    % state_map - State map (associates observer states with system states)
    % recG - structure containing transition information
    % states_to_analyze - observer states to be analysed
    % cycle_transitions - cycle transitions (observer)

   % OUTPUT:
    % cycle_info: information of the uncertain cycle like as the content of alfa and beta
    %               states, the diagnosis of this states and the initial
    %               state of the cycle. 
    % refined_states - New refined observer states with α, β, diagnosable
    %               states, observable transitions and unobservable transitions
    % is_diagnosable - Boolean: true if G is diagnosable, false otherwise
%
% Operation:
% 1. Identifies initial states and their diagnosis.
% 2. Analyses observable events and transitions to determine α-states.
% 3. Propagates unobservable transitions from α-states to identify β-states.
% 4. Saves intermediate results and verifies whether the cycle is closed.
% 5. Returns the detailed cycle structure with diagnostic information.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [cycle_info, all_diagnoses, refined_states]=refine_cycle(observer_matrix, state_map, recG, ...
                                          states_to_analyze, cycle_transitions)
   

    % Reverse alphabetical map for events
    alphabet_map_inv = containers.Map(values(recG.alphabet_map), keys(recG.alphabet_map));
    
    % Sort cycle events
    ordered_events_numeric = unique(cycle_transitions(:, 2), 'stable');
    ordered_events = cellfun(@(key) alphabet_map_inv(key), num2cell(ordered_events_numeric), ...
        'UniformOutput', false);
    
    % Prepare relevant transitions
    numeric_events = cellfun(@(e) recG.alphabet_map(e), recG.transitions(:, 2));
    relevant_transitions = [...
        recG.transitions(ismember(numeric_events, unique(cycle_transitions(:, 2))), :); ...
        recG.transitions(ismember(recG.transitions(:, 2), recG.unobs_events), :) ...
    ];

    % Data structures for refined states and monitoring
    refined_states = containers.Map('KeyType', 'char', 'ValueType', 'any');
    visited_state_event = containers.Map('KeyType', 'char', 'ValueType', 'logical');
    processed_state = containers.Map('KeyType', 'char', 'ValueType', 'logical');
    all_diagnoses = {}; % Raccolta delle diagnosi di tutti gli stati del ciclo
    
    for state_idx = states_to_analyze
        % Internal states of the initial state
        
        internal_states = arrayfun(@(idx) state_map(idx), find(observer_matrix(state_idx, :) == 1), ...
                                                                            'UniformOutput', false);

        % Determine initial cycle state
        if state_idx == states_to_analyze(1)
            initial_pair = internal_states(:);
            %disp(['Initial state of the cycle found:', strjoin(initial_pair, ',')]);
            %disp(initial_pair);
            initial_diagnosis = determine_diagnosis(initial_pair);
            %disp(['Diagnosis initial state: ', initial_diagnosis]);
            all_diagnoses{end+1} = initial_diagnosis; % Add initial diagnosis
        end
        
        cycle_info = struct();
        cycle_info.cycle_states = strjoin(arrayfun(@(x) num2str(x), cycle_transitions(:, 1:2)', ...
                                                                'UniformOutput', false), ' <-> ');
        cycle_info.initial_state = initial_pair;
        cycle_info.initial_diagnosis = initial_diagnosis;
        
        % Inizializza la lista dei passi
        cycle_info.steps = {};
        % Initialise current states
        current_states = internal_states;
        first_iteration = true;

        % Cycle for analysis
        while true
            state_key = strjoin(sort(current_states), ',');

            % Skip already processed
            if ~first_iteration && isKey(processed_state, state_key)
                break; %Exit the loop if the status has already been processed
            end
            processed_state(state_key) = true;

            % Analyses ordered events of the cycle
            for event_idx = 1:length(ordered_events)
                current_event = ordered_events{event_idx};
                %disp(['current_event:', current_event]);
                event_key = [state_key, '_', current_event];

                % Skip already visited events
                if isKey(visited_state_event, event_key)
                    continue;
                end
                visited_state_event(event_key) = true;

                % Observable transitions
                observable_transitions = [];
                for i = 1:length(current_states)
                    state = current_states{i};
                    new_transitions = relevant_transitions(strcmp(relevant_transitions(:, 1), state) & ...
                                                           strcmp(relevant_transitions(:, 2), current_event), :);
                    observable_transitions = [observable_transitions; new_transitions];
                end

                % alpha states
                if ~isempty(observable_transitions)
                    alpha_states = unique(observable_transitions(:, 3));
                    alpha_diagnosis = determine_diagnosis(alpha_states);
                    %disp(['alpha states: ', strjoin(alpha_states, ', '), ' Diagnosis: ', alpha_diagnosis]);
                    all_diagnoses{end+1} = alpha_diagnosis; % Add alpha diagnosis 
                else
                    alpha_states = {}; 
                    alpha_diagnosis = 'U';
                end

                % Unobservable transitions
                unobservable_transitions = [];
                for i = 1:length(alpha_states)
                    state = alpha_states{i};
                    new_transitions = relevant_transitions(strcmp(relevant_transitions(:, 1), state) & ...
                                                           ismember(relevant_transitions(:, 2), recG.unobs_events), :);
                    unobservable_transitions = [unobservable_transitions; new_transitions];
                end

                % beta states
                if ~isempty(unobservable_transitions)
                    unobs_states = unique(unobservable_transitions(:, 3));
                else
                    unobs_states = {}; 
                end
                beta_states = unique([alpha_states; unobs_states]);
                beta_diagnosis = determine_diagnosis(beta_states);
                %disp(['beta states: ',  strjoin(beta_states, ', '), ' Diagnosis: ', beta_diagnosis]);
                all_diagnoses{end+1} = beta_diagnosis; % add beta diagnosis
                % Aggiungi il passo alla struttura
                cycle_info.steps{end + 1} = struct( ...
                    'event' , current_event, ...
                    'alpha_states', {alpha_states}, ...
                    'alpha_diagnosis', alpha_diagnosis, ...
                    'beta_states', {beta_states}, ...
                    'beta_diagnosis', beta_diagnosis ...
                    );
                
                % Save the refined state with diagnosis
                refined_states(state_key) = struct( ...
                    'InitialStates', {initial_pair}, ...
                    'AlphaStates', {ensure_cell(alpha_states)}, ...
                    'AlphaDiagnosis', alpha_diagnosis, ...
                    'BetaStates', {ensure_cell(beta_states)}, ...
                    'BetaDiagnosis', beta_diagnosis, ...
                    'ObservableTransitions', {ensure_cell(observable_transitions)}, ...
                    'UnobservableTransitions', {ensure_cell(unobservable_transitions)});
            
                %disp('all_diagnoses:');
                %disp(all_diagnoses);
                % Compare beta with initial state
                if isequal(sort(beta_states), sort(initial_pair))
                   % disp('closed cycle (beta equal to initial state)');
                    return;
                end

                % Update current statuses for the next event
                current_states = beta_states;
               
            end
            first_iteration = false;

            % Ends the cycle if there are no more events to analyse
            if isempty(current_states)
                break;
            end
        end
    end
end