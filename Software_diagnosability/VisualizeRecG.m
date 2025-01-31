%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% VisualizeRecG - Displays graphically the graph `recG` resulting from the concurrent composition.
%This function is used to graphically represent a finite-state automaton, called `recG`,
% which is the result of the concurrent composition of two automata. The resulting graph shows the
% states, transitions and associated events in a clear and customisable visual form.
%
% INPUT:
% - recG: Data structure containing:
% - `states`: Matrix of automaton states, where each line represents a state
% described by a numeric identifier and a type (e.g. normal or fault).
% - `transitions`: Cell array of transitions, where each row represents:
% {source_state, event, destination_state}.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function VisualizeRecG(recG)
    % Graphically display the `recG` graph (automata resulting from the composition)
    % Input:
    % - recG: Structure containing states and transitions
    
    % Extracting states and transitions
    states = recG.states;
    transitions = recG.transitions;

    %Creating a list of nodes (state labels)
    state_labels = cell(size(states, 1), 1);
    for i = 1:size(states, 1)
        % Formatta lo stato (num,N) o (num,F)
        state_labels{i} = formatState(states(i, :));
    end

    % Creating a list of arcs (transitions)
    edges = {}; % List of pairs (state1, state2) for arcs
    edge_labels = {}; % Arch Labels (associated events)
    
    for i = 1:size(transitions, 1)
        % Source states
        source_state = transitions{i, 1};
        % target states
        target_state = transitions{i, 3};
        % Event
        event = transitions{i, 2};
        
        % Format source and destination states
        source_state_formatted = formatStateString(source_state);
        target_state_formatted = formatStateString(target_state);

        % Add arch
        edges = [edges; {source_state_formatted, target_state_formatted}];
        % Add bow label
        edge_labels = [edge_labels; {event}];
    end
   
    edge_sources = edges(:, 1); 
    edge_targets = edges(:, 2); 
    % Creating a direct graph object
    G = digraph(edge_sources, edge_targets);

    % View the graph
    figure;
    hold on;

    h1=plot(G,'Layout', 'auto', 'EdgeLabel', {}, 'NodeLabel', {});
    h1.Marker="o";
    h1.LineWidth=1.5;
    h1.EdgeColor='w';
    h1.MarkerSize=53;
    h1.NodeColor='k';
    h2 = plot(G, 'Layout', 'auto', 'EdgeLabel', edge_labels, 'NodeLabel', state_labels);
    h2.Marker='o';
    h2.MarkerSize=50;
    h2.NodeColor="w";
    h2.NodeFontSize=12;
    h2.EdgeFontSize=14;
    h2.LineWidth=1.5;
    h2.EdgeColor='k';
    h2.EdgeLabelColor='k';
    h2.NodeLabel = {};

    % Adding node labels manually within circles
    x = h2.XData; 
    y = h2.YData; 
    for i = 1:numel(state_labels)
        text(x(i), y(i), state_labels{i}, 'HorizontalAlignment', 'center', ...
            'VerticalAlignment', 'middle', 'FontSize', 10, 'FontWeight', 'bold');
    end

    title('recG');
   
end

function formattedState = formatState(state)
    
    if state(2) == 1
        formattedState = sprintf('(%d,N)', state(1));
    elseif state(2) == 2
        formattedState = sprintf('(%d,F)', state(1));
    else
        error('Invalid status format: %s', mat2str(state));
    end
end

function formattedStateString = formatStateString(state)
    % Converts a status to string format
    if ischar(state) || isstring(state)
        formattedStateString = state; 
    else
        formattedStateString = formatState(state); 
    end
end