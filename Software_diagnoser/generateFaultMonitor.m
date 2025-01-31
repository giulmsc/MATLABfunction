%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function: generateFaultMonitor
%
% Description:
% This function generates the **Fault Monitor** (a DFA - Deterministic Finite Automaton).
% from a G automaton. The Fault Monitor is used to detect and monitor possible
% faults in the system at discrete events. It is based on the observable and fault events
% defined in the G automaton to construct transitions that distinguish fault states
% ('F') from normal states ('N').
%
% Input:
% - G: Structure representing the input automaton, with the following fields:
% - G.states: States of G.
% - G.alphabet: Alphabet symbols (events).
% - G.transitions: System transitions (format: {state1, event, state2}).
% - G.fault_events: Fault events (set of symbols).
% - print: Boolean flag (1 or 0) to print information on the Fault Monitor:
% - Transitions in symbolic and numeric format.
% - Map of states.
%
% Output:
% - FaultMonitor: Structure representing the DFA of the Fault Monitor, with the following fields:
%   - FaultMonitor.states: Fault Monitor states ("N" and "F").
%   - FaultMonitor.alphabet: Alphabet symbols.
%   - FaultMonitor.transitions: Numerical transitions.
%   - FaultMonitor.celltransitions: Transitions in symbolic format (with the labels N and F).
%   - FaultMonitor.initialStates: Initial state ('N').
%   - FaultMonitor.finalStates: Final states ('N' and 'F').
%
% Operation:
% 1. **Definition of States**:
%   - The Fault Monitor has two states:
%   - 'N' -> Normal state (no fault detected).
%   - "F" -> Fault state (fault detected).
% 2. **Transition Generation**:
%   - For each symbol in the alphabet:
%   - If the symbol is a fault event, it generates transitions to "F".
%   - Otherwise, transitions remain in the current state.
% 3. **Sorting Transitions**:
%    - Sorts transitions by priority (first "N", then "F").
% 4. **Event Sorting**:
%    - Identifies events leading from 'N' to 'F'.
%   - Separately groups events which maintain states in 'N' or 'F'.
% 5. **Symbolic and Numerical Conversion**:
%    - Converts states and transitions to numeric format for DFA.
% 6. **Print (optional)**:
%   - Displays transitions, state map and event information.
%
% Usage:
% FaultMonitor = generateFaultMonitor(G, 1);
% % Generates the Fault Monitor and prints out details of transitions and events.

function FaultMonitor = generateFaultMonitor(G,print)
    % G: The input automaton with fields:
    % G.States - cell array of states
    % G.Alphabet - cell array of alphabet symbols
    % G.Transitions - transitions array (Nx2)
    % column 1: source state
    % column 2: symbol
    % column 3: destination state
    % Ef: set of fault events (cell array)
    %
    % FaultMonitor: structure containing the DFA of the Fault Monitor
    % Defining Fault Monitor States
    FaultMonitor.states = {'N', 'F'}; % N: No Fault, F: Fault detected
    FaultMonitor.alphabet = G.alphabet;
    FaultMonitor.initialStates = 'N';
    FaultMonitor.finalStates={'N','F'};
    FaultMonitor.celltransitions = [];
    %disp(['M alphabet:', FaultMonitor.alphabet]);
    % Generation of transitions
 
    for i = 1:length(FaultMonitor.alphabet)
        symbol = FaultMonitor.alphabet{i};
        
        if ismember(symbol, G.fault_events)
          
            % Fault event: transition to F
            FaultMonitor.celltransitions = [FaultMonitor.celltransitions; {'N', symbol, 'F'}];
            FaultMonitor.celltransitions = [FaultMonitor.celltransitions; {'F', symbol, 'F'}];
        else
            %Normal event: stay in N or stay in F
            FaultMonitor.celltransitions = [FaultMonitor.celltransitions; {'N', symbol, 'N'}];
            FaultMonitor.celltransitions = [FaultMonitor.celltransitions; {'F', symbol, 'F'}];
        end
    end
        % Sort the transitions considering N before F
        state_priority = containers.Map({'N', 'F'}, [1, 2]); % Priority: N (1), F (2)
        
        % Add temporary column for source state priority
        priority_column = cellfun(@(s) state_priority(s), FaultMonitor.celltransitions(:, 1));
        transitions_with_priority = [FaultMonitor.celltransitions, num2cell(priority_column)];
        
        % Sort by priority column (fourth column)
        sortedTransitions = sortrows(transitions_with_priority, 4);
        
        % Remove temporary column after sorting
        FaultMonitor.celltransitions = sortedTransitions(:, 1:3);
        
        disp('---------------------------');
        % Initialise Categories
        events_N_to_F = {};  % Events ranging from N to F
        events_N_to_N_F_to_F = struct('N_to_N', {{}}, 'F_to_F', {{}});
        
        % Process the matrix of transitions
        for i = 1:size(FaultMonitor.celltransitions, 1)
            state1 = FaultMonitor.celltransitions{i, 1};
            event = FaultMonitor.celltransitions{i, 2};
            state2 = FaultMonitor.celltransitions{i, 3};
        
            if strcmp(state1, 'N') && strcmp(state2, 'F')
                % Add events N to F
                events_N_to_F = [events_N_to_F; {event}];
            elseif strcmp(state1, 'N') && strcmp(state2, 'N')
                % Add events from N to N
                if ~isfield(events_N_to_N_F_to_F, 'N_to_N') || isempty(events_N_to_N_F_to_F)
                    events_N_to_N_F_to_F(1).N_to_N = {}; % Initialise the field
                end
                events_N_to_N_F_to_F(1).N_to_N = [events_N_to_N_F_to_F(1).N_to_N; {event}];
            elseif strcmp(state1, 'F') && strcmp(state2, 'F')
                % Add events from F to F
                if ~isfield(events_N_to_N_F_to_F, 'F_to_F') || isempty(events_N_to_N_F_to_F)
                    events_N_to_N_F_to_F(1).F_to_F = {}; % Initialise the field
                end
                events_N_to_N_F_to_F(1).F_to_F = [events_N_to_N_F_to_F(1).F_to_F; {event}];
            end
        end
        
        %show results
        disp(['Ef (fault events): [ ', strjoin(events_N_to_F,','),' ]']);
        %disp(events_N_to_F);
        disp('---------------------------');
        disp('All events:');
        if isfield(events_N_to_N_F_to_F, 'N_to_N')
            fprintf('E/Ef:[ %s ]\n', strjoin(events_N_to_N_F_to_F.N_to_N, ', '));
        end
        if isfield(events_N_to_N_F_to_F, 'F_to_F')
            fprintf('E:[ %s ]\n', strjoin(events_N_to_N_F_to_F.F_to_F, ', '));
        end
    disp('---------------------------');
    
    disp('Transitions:');
    fprintf('%-8s %-8s %-8s\n', 'State1', 'Event', 'State2'); % Intestazione
    for i = 1:size(FaultMonitor.celltransitions, 1)
         fprintf('%-8s %-8s %-8s\n', FaultMonitor.celltransitions{i, 1}, FaultMonitor.celltransitions{i, 2}, ...
                FaultMonitor.celltransitions{i, 3});
    end
    fprintf('\n');
    
   % State map for FaultMonitor
    state_map = containers.Map({'N', 'F'}, [1, 2]);
    keys_map = keys(state_map); 
    values_map = values(state_map); 
    %display state map
    if print==1
        for i = 1:length(keys_map)
            fprintf('%s = %d\n', keys_map{i}, values_map{i});
        end
    end
    FaultMonitor.states = cellfun(@(s) state_map(s), FaultMonitor.states, 'UniformOutput', false);
    FaultMonitor.initialStates = state_map(FaultMonitor.initialStates);
    FaultMonitor.finalStates = cell2mat(cellfun(@(s) state_map(s), FaultMonitor.finalStates, 'UniformOutput', false));
    num_symbols=length(FaultMonitor.alphabet);
    alphabet_map=containers.Map(FaultMonitor.alphabet, num2cell(1:num_symbols));
    FaultMonitor.transitions=convert_to_numeric_cells(FaultMonitor.celltransitions, state_map);
    fprintf('\n');
    % Output structure Fault Monitor
    %disp('Fault Monitor DFA generated:');
    %disp(FaultMonitor);
    if print==1
        disp('Numeric transitions:');
        fprintf('%-8s %-8s %-8s\n', 'State1', 'Event', 'State2'); % Intestazione
        for i = 1:size(FaultMonitor.transitions, 1)
             fprintf('%-8d %-8s %-8d\n', FaultMonitor.transitions{i, 1}, FaultMonitor.transitions{i, 2}, ...
                    FaultMonitor.transitions{i, 3});
        end
        %disp(FaultMonitor.transitions);
          disp('---------------------------');
    end
  
    
end


