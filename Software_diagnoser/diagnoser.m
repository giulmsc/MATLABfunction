
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% diagnoser construction
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Algorithm
% INPUT: Plant G
% OUTPUT: diagnoser Diag(G)
% STEP1: 
%           constract fault monitor 
%           M = (states, alphabet, transitions, final state)
% STEP2: 
%           constract faul recognizer rec(G)=G||M 
% STEP3: 
%           constract the diagnoser which is the observer of Rec(G)
%           diag(G)=obs(rec(G))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% diagnosis is based on the rec(G) observer
% if the observer state contains N (non-fault) states: 
%       the diagnosis will be N = non-fault
% if the observer state contains F ( fault) states: 
%       the diagnosis will be F = fault
%if the observer state contains both N ( non-fault) and F ( fault) states:  
%       the diagnosis will be U = uncertain

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Description:
% This function constructs a **diagnoser** for a discrete event system
% described by a G automaton. The diagnoser determines the diagnostic status
% of the system, identifying any faults and analysing transitions and states
% observable states of the system.
%
% Input:
% - filename: Name of the file containing the description of the G automaton.
% - boolean flags:
%       - print_G: Boolean flag (1 or 0) to print G on the screen.
%       - print_M: Boolean flag (1 or 0) to print Fault Monitor M on screen.
%       - print_recG: Boolean flag (1 or 0) to print the system representation
%           compound G and M (rec(G)).
%       - print_obs: Boolean flag (1 or 0) to print the status details of the observer.
%       - print_obs_trans: Boolean flag (1 or 0) to print observer transitions.
%       - FM_graph: Boolean flag (1 or 0) to display the Fault Monitor graphically.
%       - obs_graph: Boolean flag (1 or 0) to display the observer graphically.
%
% Output:
% - DIAG: Structure representing the system observer (diagnoser).
% - recG: Structure of the compound system G and M (rec(G)).

%
% Operation:
% 1. **Read the G automaton**:
%   - Use `read_nfa` to read the representation of G from the `filename` file.
%   - If `print_G = 1`, prints the details of G.
% 2. **Generate Fault Monitor**:
%   - Call `generateFaultMonitor` to build the Fault Monitor M from G.
%   - If `FM_graph = 1`, graphically display M with `visualizeFaultMonitor`.
% 3. **Competitor Composition**:
%   - Combine G and M using `concurrent_composition` to generate rec(G).
%   - If `print_recG = 1`, print the states and transitions of rec(G).
% 4. **Calculate Observer**:
%   - Use `observer_2` to generate the system observer.
%   - If `print_obs = 1`, print the observer states.
%   - If `print_obs_trans = 1`, prints the observer transitions.
% 5. **Display Graphs**:
%   - If `FM_graph = 1`, displays the Fault Monitor.
%   - If `obs_graph = 1`, displays the observer.
%
% Usage:
% [DIAG, recG] = diagnoser('system_file.txt', 1, 1, 1, 1, 1);
% Constructs and displays all components of the diagnoser.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [DIAG, recG] = diagnoser(filename, print_G, print_M, print_recG,recG_graph, ...
                            print_obs, print_obs_trans,FM_graph,obs_graph)

    % read the automata G
    G=read_nfa(filename, print_G);
    
    % generate the fault monitor 
    disp('Fault Monitor:');
    M=generateFaultMonitor(G, print_M);
    
    %display the Fault Monitor
    if FM_graph==1
        visualizeFaultMonitor(M);
    end
    disp('===========================');
    
    
    % compute rec(G) by the concurrent composition of G and M
    disp('Rec(G):');
    recG=concurrent_composition(G,M,print_recG);

    displayFormattedStates(recG.states);
    disp('---------------------------');
    transitions=displayFormattedTransitions(recG.transitions);
    if recG_graph==1
       VisualizeRecG(recG);
    end
    disp('===========================');
    
     %compute the observer of rec(G)
    
    disp('Diag(G):');
    DIAG=observer_2(recG, print_obs);
    displayObserverStates(DIAG.observer_state_matrix, recG.state_map,0);
        if print_obs_trans==1
           displayTransitionMatrix(DIAG.trans_matrix,recG.alphabet_map);
        end
    
    %display observer

    if obs_graph==1
        figure;
        visualize_observer(DIAG.observer_state_matrix, DIAG.trans_matrix, recG.alphabet_map, recG.state_map);
    end
end


