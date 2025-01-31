%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function: visualise_observer
%
% Description:
% This function graphically displays the observer of a finite state system.
% The observer is represented as a directed graph, where:
% - Nodes represent the states of the observer.
% - Arcs represent transitions between states, labelled with events.
% - Each node includes information about the contained physical states, formatted as
% `(num,N)` for normal states and `(num,F)` for fault states.
%
% Input:
% - observer_matrix: Binary matrix of observer states, where:
% - Each row represents an observer state.
% - Each column indicates whether a particular state is contained in the state
%   of the observer (1 = contained, 0 = not contained).
% - trans_matrix: Matrix of transitions, where each row is in the format:
%   - `[InitialState, Event, FinalState]`.
% - events_map: Map associating event numbers with their symbolic labels.
% - states_map: Map associating numeric indices with physical states in the format `(num,num)`.
%
% Output:
% - No value returned. The graph is displayed graphically.
%
% Operation:
% 1. **Observer States**:
%    - For each observer state (row of `observer_matrix`):
%    - Identifies the contained physical states.
%    - Converts the physical states to the readable format `(num,N)` or `(num,F)`.
%    - Assigns a label to the node with the contained physical states.
% 2. **Transitions**:
%   - For each transition in `trans_matrix`:
%   - Converts the event number to its symbolic label.
%   - Groups event labels for duplicate arcs.
% 3. **Viewing the Graph**:
%   - Creates the graph using the `digraph` library.
%   - Places and lays out nodes and arcs.
%   - Adds dynamic labels for each node, including contained states.
%
% Usage:
% visualize_observer(observer_matrix, trans_matrix, events_map, states_map);
% Displays the observer graph with labelled states and transitions.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function visualize_observer(observer_matrix, trans_matrix, events_map, states_map)
    %Displays the observer as a graph
    % observer_matrix: Matrix of observer states
    % trans_matrix: Matrix of transitions (initial_state, event, final_state)
    % events_map: Map of events (numeric -> symbolic)
    states_map_inverse=containers.Map(values(states_map), keys(states_map));
    events_map_inv=containers.Map(values(events_map),keys(events_map));
      % Define states for legend
    num_nodes = size(observer_matrix, 1);
    legend_labels = cell(num_nodes, 1);
   
    % Calcolo automatico degli stati contenuti nei nodi
    for i = 1:num_nodes
        contained_states = find(observer_matrix(i, :) == 1); % Stati contenuti nel nodo
        state_texts = {};
        for j = 1:numel(contained_states)
            original_state = states_map_inverse(contained_states(j));
            nums = sscanf(original_state, '(%d,%d)');
            first_num = nums(1);
            second_num = nums(2);
            % Formattazione dello stato come (1,N) o (2,F)
            if second_num == 1
                state_texts{end+1} = sprintf('(%d,N)', first_num);
            elseif second_num == 2
                state_texts{end+1} = sprintf('(%d,F)', first_num);
            end
        end
        node_labels{i} = strjoin(state_texts, ', '); % Unisce gli stati con virgole
    end
    % Define nods
    num_states = size(observer_matrix, 1); % states's number 
    nodes = arrayfun(@(i) sprintf('%d', i), 1:num_states, 'UniformOutput', false); 

    % Define arcs
    edges = trans_matrix(:, [1, 3]); % Columns 1 (initial state) and 3 (final state)
  
    % Converti le etichette degli archi in cell array di caratteri
    labels = cell(size(trans_matrix, 1), 1);
    for i = 1:size(trans_matrix, 1)
        labels{i} = char(events_map_inv(trans_matrix(i, 2))); % Convert to character
    end
   

    % Group labels for duplicate arcs
    edgeTable = table(edges(:, 1), edges(:, 2), labels, 'VariableNames', {'Source', 'Target', 'Label'});
    [uniqueEdges, ~, idx] = unique(edgeTable(:, 1:2), 'rows'); % Identifies unique arcs
    combinedLabels = accumarray(idx, 1:numel(labels), [], @(x) {strjoin(labels(x), ', ')});
    % Create the graph
    G = digraph(uniqueEdges.Source, uniqueEdges.Target);
    numEdges = numedges(G);
    if length(combinedLabels) ~= numEdges
        error(' The number of labels does not correspond to the number of arcs in the graph.');
    end
    
    % Crea un grafico temporaneo per ottenere le coordinate dei nodi
    temp_plot = plot(G, 'Layout', 'layered', 'NodeLabel', {}, 'EdgeLabel', {});
    node_positions = [temp_plot.XData', temp_plot.YData'];
    delete(temp_plot); % Cancella il grafico temporaneo
    % View graph
     
    % Coordinates for placing the graph in an orderly manner 
    %x = [1, 3, 1, 5]; 
    %y = [5, 5, 3, 5]; 
  
    hold on;
    %h1=plot(G, 'XData', x, 'YData', y, 'NodeLabel', {}, 'EdgeLabel', {});
    h1=plot(G,'Layout','auto','Nodelabel', {}, 'EdgeLabel',{});
    
    h1.Marker=".";
    h1.LineWidth=1.5;
    h1.EdgeColor='w';
    h1.MarkerSize=53;
    h1.NodeColor='k';

    %h2 =plot(G, 'XData', x, 'YData', y, 'NodeLabel', nodes);
    h2=plot(G, 'Layout', 'auto', 'NodeLabel', nodes);
    h2.Marker='.';
    h2.MarkerSize=50;
    h2.NodeColor="w";
    h2.NodeFontSize=12;
    h2.EdgeLabel = combinedLabels; % Assign labels
    h2.EdgeFontSize=14;
    h2.LineWidth=1.5;
    h2.EdgeColor='k';
    h2.EdgeLabelColor='k';
 
    % Title
    title('Observer');
    % Add the dynamic legends

    for i = 1:num_nodes
        x = h2.XData(i); % Coordinate X del nodo i
        y = h2.YData(i); % Coordinate Y del nodo i
        % Aggiungi il testo al nodo
        text(x, y, {['state ' num2str(i)], node_labels{i}}, ...
            'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', ...
            'FontSize', 10, 'BackgroundColor', 'w', 'EdgeColor', 'k');
    end
    hold off;
end