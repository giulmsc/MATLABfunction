%% Function Observer 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function: observer_2
%
% Description:
% This function calculates the observer of a finite state system represented
% by an automaton. The observer is a derived automaton that keeps track of the states
% achievable through observable and unobservable transitions.
%
% Input:
% - G: Structure representing the input automaton, with the following fields:
%
% Output:
% - obs: Structure containing:
% - obs.trans_matrix: Matrix of observer transitions (state1, event, state2).
% - obs.observer_state_matrix: Matrix of observer states.
% - obs.num_states: Total number of states in the original automaton.
% - obs.marked_states: End states of the original automaton.
%
% Operation:
% 1. **Reachability Not Observable**:
%   - Calculates reachable states through unobservable transitions.
% 2. **Observable Transitions**:
%   - Creates a map of transitions for each observable event.
% 3. **Observer Initial State**:
%   - Defines the observer's initial state by combining the initial states
%   of the automaton and their attainable states via unobservable transitions.
% 4. **Calculation of Observer States**:
%   - Iteratively calculates successive states and transitions of the observer
%   using the functions **alpha** and **beta**:
%   - `alpha`: Calculates the states reachable from a current state via
% an observable event.
%   - `beta`: Calculates states reachable from **alpha** states via
%      unobservable transitions.
% 5. **Observer transitions**:
%    - Constructs a matrix of transitions that associates each observer state
%      to a subsequent state via an observable event.
% 6. **Print (optional)**:
%   - Displays the matrix of observer states and transitions.
%
% Usage:
% obs = observer_2(G, 1);
% Calculates the observer and prints the results.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function obs = observer_2(G,print_obs)
         % Takes in input a file that contains the structure of the
         % automaton

 % Calls the function to extract the structure from the file
 % automaton = insert_automaton_s(G);
   
% Extracting information from automa
    initial_states = G.initialStates;
    num_states = length(G.states);
   
    D = G.D;
    not_obs_E = G.unobs_map;
    obs_E = G.obs_map;
    marked_states = G.finalStates;
    
    
% Matrix initialization for Unobservable reach
    T_not_obs = zeros(num_states);
    
   

 % Unobservable reach
 for i = 1:size(D, 1)                       % Loop trough all the rows of matrix D
    if ismember(D(i, 2), not_obs_E)         % Checks if the event in second column of D is unobservable
        T_not_obs(D(i, 1), D(i, 3)) = 1;    % If the condition is verified, the state is marked as reachable
        
        % Loop to check for consecutive non-observable transitions
        new_states_found = true;            % Flag to track new states
        current_state = D(i, 3);            % Starting state for the transition
        
        while new_states_found
            new_states_found = false;                                       % Flag set as false at the beginning
            for j = 1:size(D, 1)                                            % Loop on all the rows to check the presence of consecutive non-observable transitions
                if D(j, 1) == current_state && ismember(D(j, 2), not_obs_E) % If there's an unobservable transition from the current state
                    if T_not_obs(D(i, 1), D(j, 3)) == 0                     % And the new state has not marked as reachable yet
                        T_not_obs(D(i, 1), D(j, 3)) = 1;                    % Here is set as reachable
                        current_state = D(j, 3);                            % Current state is updated with the new state
                        new_states_found = true;                            % Flag to say new states were found
                    end
                end
            end
        end
    end
    
    T_not_obs(D(i, 1), D(i, 1)) = 1;        % Marks the current state reachable with a 0-lenght unobservable transition
end


% Display the Unoberservable reach
    % disp('Unobservable reach:');
     % disp(T_not_obs);
    
% Transitions for Observable events CHECK HOW THIS SIIS REPEATED
    T_obs = containers.Map('KeyType', 'double', 'ValueType', 'any'); % Creates an associative array (dictionary) where 
                                                                     % numeric keys (of type double) can be used to store values of any type.
    for event = obs_E                                                % Loops for each observable event
        T_event = zeros(num_states);                                 % Create matrix of each obs event
        for i = 1:size(D, 1)                                         % Loop on all the rows of D
            if D(i,2) == event
                T_event(D(i, 1), D(i, 3)) = 1;                       % If the events match, the index in column 3 is set to 1
            end
            
           
        end
        
        T_obs(event) = T_event;
       % fprintf('States reachable with event: %d\n', event);
       % disp(T_obs(event));
        
    end
    
 % Inizialization of the Observer states matrix
    observer_state_matrix = [];

 % % Definition of the first state of the observer
 % for i = 1 : length(initial_states)
 %    initial_reachable_states = find(T_not_obs(initial_states, :) > 0);      % controlla tutte le colonne della riga per vedere se 
 %                                                                           % ci sono valori > 0, che corrispondono agli stati
 %                                                                           % raggiungibili dallo stato iniziale
 %    if isempty(initial_reachable_states)                                   % controlla se ci sono stati raggiungibili dallo stato iniziale
 %        initial_reachable_states = initial_states;                          % se non ci sono, si rimane nello stato iniziale
 %    end
 % 
 %    y1 = zeros(1, num_states);
 %    y1(initial_reachable_states) = 1;
 %    observer_state_matrix = [observer_state_matrix; y1];  % Adds the initial state as the first row of the observer
 
   % Definition of the first state of the observer, considering initial_states as a vector
y1 = zeros(1, num_states);  % Initializing the state vector

for i = 1:length(initial_states)
    current_state = initial_states(i);  % Get the current initial state from the vector

    % Find reachable states from the current initial state
    reachable_states = find(T_not_obs(current_state, :) > 0);

    % If no reachable states are found, stay in the current initial state
    if isempty(reachable_states)
        reachable_states = current_state;
    end

    % Update y1 for each reachable state
    y1(reachable_states) = 1;
end
%disp('stato iniziale:');
%disp(y1);
% Add the initial state as the first row of the observer state matrix
observer_state_matrix = [observer_state_matrix; y1];

  
 % Function to compute Alpha
    function alpha_states = alpha(current_states, event)
        T_event = T_obs(event);                                 % Considers the transitions corresponding to the event that is been considered
        alpha_states = zeros(1, num_states);                    % Alpha array initialized to 0
        for state = find(current_states)                        % Take the index of the current state
            reachable_states = T_event(state, :) > 0;           % Check reachable states
            alpha_states(reachable_states) = 1;                 % The indexes of the reachable states are set to 1
        end
    end

% Compute function Beta 
function beta_states = beta(current_states)
    beta_states = current_states; % Initialize with the current state
    new_states_found = true;      % Flag to track new states

    % Loop to check for reachable states
    while new_states_found
        new_states_found = false;                                   % Set the flag 'false' at the start of every interaction
        for state = find(beta_states)                               % Loop through the states
            reachable_states = T_not_obs(state, :) > 0;             % Find the reachable states
            new_reachable_states = reachable_states & ~beta_states; % Check if the states are new

            if any(new_reachable_states)                            % If new states are found
                beta_states(new_reachable_states) = 1;              % Add the new states
                new_states_found = true;                            % Flag set 'true' if new states are found
            end
        end
    end
    
end


 % Iterations through states and events
    trans_matrix=[];
    state_index = 1;                                        % Starts from the first state
    
    while state_index <= size(observer_state_matrix, 1)     % Loop until the state index reaches the size of the matrix
                                                            % so that the
                                                            % matrix can
                                                            % grow
                                                            % dynamically
                                                   
        current_states = observer_state_matrix(state_index, :);
        
        for event = obs_E                                 % Considered event
           % Compute Alpha for the current event
            alpha_result = alpha(current_states, event); 

            % Display Alpha
            % fprintf('Alpha for event : %d\n', event);
            % disp(alpha_result);
            
            % Compute Beta starting from the result of Alpha
            beta_result = beta(alpha_result);      

            % Display Beta
            % fprintf('Beta for event : %d\n', event);
            % disp(beta_result);
            
            % Check if the new state is already present in the observer
            % state matrix
            if any(beta_result)
            if ~ismember(beta_result, observer_state_matrix, 'rows') %&& any(beta_result)
                observer_state_matrix = [observer_state_matrix; beta_result];
            end
        

        
        % To compute the transition matrix of the observer, the indexes 
        % of the states correspon to the indexes of the rows
        
        [found, index] = ismember(beta_result, observer_state_matrix, 'rows');
        if found
            if isempty(trans_matrix) || ~ismember([state_index event index], trans_matrix, 'rows')
            trans_matrix = [trans_matrix; state_index event index];
            end
        end
            end
        end

        % Go to the next state to examine
        state_index = state_index + 1;
    end

    
    % Final matrix that contains the states of the observer
    if print_obs == 1
    disp('---------------------------');
    disp('Final Observer State Matrix:');
    disp(observer_state_matrix);
    disp('---------------------------');
    % observer transition 
    disp('Observer transitions:');
    fprintf('%-8s %-8s %-8s\n', 'State1', 'Event', 'State2'); % Intestazione
    for i = 1:size(trans_matrix, 1)
         fprintf('%-8d %-8d %-8d\n', trans_matrix(i, 1), trans_matrix(i, 2), ...
                trans_matrix(i, 3));
    end
    end
    disp('---------------------------');
    %disp('Tipo di state:');
    %disp(class(state));
    
    %disp('Tipo di trans_matrix(:, 1):');
    %disp(class(trans_matrix(:, 1)));
    
    %disp('Valore di state:');
    %disp(state);
    
    %disp('Valori di trans_matrix(:, 1):');
    %disp(trans_matrix(:, 1));

    %% Output of the observer's state matrix
    obs.trans_matrix=trans_matrix;
    obs.observer_state_matrix = observer_state_matrix;
    obs.num_states = num_states;
    obs.marked_states = marked_states;
    %disp(obs);
    
end
