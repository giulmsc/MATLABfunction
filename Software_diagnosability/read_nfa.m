%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function: read_nfa
%
% Description:
% This function reads a file describing a non-deterministic finite state automaton
% (NFA, Non-deterministic Finite Automaton) and converts it into a MATLAB structure.
% The automaton can contain states, observable/unobservable events, failure events,
% transitions, initial states and final states. The function also constructs a
% events and a transition matrix.
%
% Input:
% - file_name: Name of the file containing the description of the automaton.
% - print: Boolean flag (1 or 0) to print the automaton details:
% - states and transitions.
% - Transition matrix `D`.
%
% Output:
% - G: Structure representing the automaton, with the following fields:
% - G.states: Total number of states.
% - G.alphabet: Alphabet symbols (events).
% - G.obs_events: Observable events.
% - G.obs_map: Map between observable events and numeric indices.
% - G.unobs_events: Unobservable events.
% - G.unobs_map: Map between unobservable events and numeric indices.
% - G.fault_events: Fault events.
% - G.transitions: List of transitions in the format `{state1, symbol, state2}`.
% - G.D: Automaton transition matrix.
% - G.initialStates: Initial States.
% - G.finalStates: Final States.
%
% Operation:
% 1. Reads the file specified by `file_name` line by line.
% 2. Processes the following sections:
%    - Number of states.
%   - Alphabet (event symbols).
%   - Observable and unobservable events.
%   - Fault events.
%   - Transitions (format: `state1 symbol state2`).
%    - Initial and final states.
% 3. Creates a map (`alphabet_map`) to associate event symbols with numeric indices.
% 4. Constructs a transition matrix `D` using the read transitions.
% 5. Returns the structure `G` representing the automaton.
%
% Usage:
% G = read_nfa('example.nfa', 1);
% Reads the automaton from the file `example.nfa` and prints out the details.
%

function G = read_nfa(file_name, print)
    % Open the file
    fileID = fopen(file_name, 'r');
    if fileID == -1
        error('cannot open the file: %s', file_name);
    end

    % Initialize structure
    G = struct();
    G.states = [];
    G.alphabet = '';
    G.obs_events = [];
    G.obs_map=[];
    G.unobs_events = [];
    G.unobs_map=[];
    G.fault_events = [];
    G.transitions = {};
    G.D=[];
    G.initialStates = [];
    G.finalStates = [];

    % Read the file line by line
    while ~feof(fileID)
        line = strtrim(fgetl(fileID)); % Read one line and remove spaces

        % Skip blank lines or comments
        if isempty(line) || startsWith(line, '%')
            continue;
        end

        % States number
        if isempty(G.states)
            G.states = str2double(line);
            continue;
        end

        % Alphabet
        if isempty(G.alphabet)
            G.alphabet = strsplit(line, ' ');
            continue;
        end

        % Observable events
        if isempty(G.obs_events)
            G.obs_events = strsplit(line, ' ');
            continue;
        end

        % Unobservable events
        if isempty(G.unobs_events)
            if strcmp(line, '-')
                G.unobs_events = 0; % No unobservable events
                check_unobs_events=0;
            else
                G.unobs_events = strsplit(line, ' ');
                check_unobs_events=1;
            end
            continue;
        end

        %Fault events
        if isempty(G.fault_events)
            if strcmp(line, '-')
                G.fault_events = 0; % No fault events
            else
                G.fault_events = strsplit(line, ' ');
            end
            continue;
        end
        
        % Matrice di transizione
        if isempty(G.transitions)
            transitions = {};
            %read the first line of the matrix
            % Split the line into start state, symbol, and end state
                parts = strsplit(line, ' ');

                % Check if the number of parts is correct
               if length(parts) >= 3
                    
                stato1 = str2double(parts{1});
                if stato1 > G.states || stato1 < 1 
                    error(['Error in start state of the trasition matrix, line: ', line]);
                end

                simbolo = parts{2};
                stato2 = str2double(parts{3});
                if stato2 > G.states || stato2 < 1 
                    error(['Error in start state of the trasition matrix, line: ', line]);
                end
                % Append the new transition to the transition matrix
                  transitions = [transitions; {stato1, simbolo, stato2}];
               elseif isempty(parts{1}) || strcmp(parts{1}, '-')
                % Skip invalid or empty lines (e.g., '-')
                 continue;
               else 
                    error('Invalid transition line: "%s". Expected format: "initial state symbol final state" ', line);
               end
            %read next lines
            while ~feof(fileID)
                line = strtrim(fgetl(fileID));
                
                if startsWith(line, '% Initial state') || isempty(line) % Signal to stop reading transitions
                    break;
                end

                % Split the line into start state, symbol, and end state
                parts = strsplit(line, ' ');

                % Check if the number of parts is correct
               if length(parts) >= 3
                    
                stato1 = str2double(parts{1});
                if stato1 > G.states || stato1 < 1 
                    error(['Error in start state of the trasition matrix, line: ', line]);
                end

                simbolo = parts{2};
                stato2 = str2double(parts{3});
                if stato2 > G.states || stato2 < 1 
                    error(['Error in start state of the trasition matrix, line: ', line]);
                end
                % Append the new transition to the transition matrix
                  transitions = [transitions; {stato1, simbolo, stato2}];
                  
               else 
                    error('Invalid transition line: "%s". Expected format: "initial state symbol final state" ', line);
               end
              
            end
            G.transitions = transitions;
            continue;
        end
        
        
        % Initial states
        if isempty(G.initialStates)
            G.initialStates = str2double(strsplit(line, ' '));
            continue;
        end

        % Final states
        if isempty(G.finalStates)
            if strcmp(line, '-')
                G.finalStates = 0; % No final states 
            else
                G.finalStates = str2double(strsplit(line, ' '));
            end
            continue;
        end
    end
    % Close the file

    fclose(fileID);

    %alphabet map 
    num_symbols = length(G.alphabet);
    alphabet_map = containers.Map(G.alphabet, num2cell(1:num_symbols));
    G.D=create_transition_matrix(transitions,alphabet_map);
    % Map observable events 
       G.obs_map = zeros(1, numel(G.obs_events));
            for i = 1:numel(G.obs_events)
                event = G.obs_events{i}; % Ottieni l'evento osservabile
                if isKey(alphabet_map, event) % Controlla se l'evento è presente nella mappa
                    G.obs_map(i) = alphabet_map(event); % Usa direttamente l'evento come chiave
                else
                     error(['Observable event not found in the alphabet: ', G.obs_events{i}]);
                end
            end

    % Map unobservable events (if present)
    if check_unobs_events ~= 0
        %disp('No Unobservable event present')
    %else
        G.unobs_map = zeros(1, numel(G.unobs_events));
             for i = 1:numel(G.unobs_events)
                 event = G.unobs_events{i}; % Ottieni l'evento osservabile
                if isKey(alphabet_map, event) % Controlla se l'evento è presente nella mappa
                    G.unobs_map(i) = alphabet_map(event); % Usa direttamente l'evento come chiave
                else
                     error(['Unobservable event not found in the alphabet: ', G.unobs_events{i}]);   
                end
            end
    end
    disp(G);
    
    if print==1
        % Stampa delle transizioni
        fprintf('  transitions:\n');
        for i = 1:size(G.transitions, 1)
            fprintf('    %d %s %d\n', G.transitions{i, :});
        end
        
        % Stampa della matrice D
        fprintf('  D:\n');
        for i = 1:size(G.D, 1)
            fprintf('    [%s]\n', num2str(G.D(i, :), '%d '));
        end
    end
    
end