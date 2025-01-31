%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function: visualiseFaultMonitor
%
% Description:
% This function graphically displays the Fault Monitor of a finite-state system
% as a directed graph. The nodes represent the states of the Fault Monitor (e.g. `N` and `F`),
% while the arcs indicate the transitions between the states, labelled with the symbols
% associated events.
%
% Input:
% - FaultMonitor: Structure representing the Fault Monitor, with the following fields:
% - FaultMonitor.celltransitions: List of transitions in the format `{State1, Event, State2}`:
% - `State1`: Source state.
% - `Event`: Event symbol (e.g. 'a', 'b').
% - `State2`: Destination state.
%
% Output:
% - No value returned. The Fault Monitor is displayed as a graph.
%
% Operation:
% 1. **Creation of Arcs**:
%   - Extracts the source (`State1`) and destination (`State2`) states for each transition.
%   - Labels arcs with associated event symbols.
% 2. **Grouping Duplicate Arcs**:
%   - Combines event labels for arcs that share the same states.
%     Source and Destination.
% 3. **Graph Creation**:
%   - Constructs a directed graph using unique nodes and arcs.
% 4. **Displaying the Graph**:
%   - Displays the graph with:
%   - Nodes `N` and `F` highlighted in green and red respectively.
%   - Arc labels containing event symbols.
%   - Applies a circular layout for the nodes.
%
% Usage:
% visualiseFaultMonitor(FaultMonitor);
% % Displays the Fault Monitor as a graph with labelled states and transitions.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function visualizeFaultMonitor(FaultMonitor)
   % Display the Fault Monitor as a graph
    % FaultMonitor: structure generated with the updated function

    % Creation of the list of arcs (edges)
    edges = {};
    labels = {};
    for i = 1:size(FaultMonitor.celltransitions, 1)
        fromState = FaultMonitor.celltransitions{i, 1};
        toState = FaultMonitor.celltransitions{i, 3};
        symbol = FaultMonitor.celltransitions{i, 2};

        % Add arc to graph
        edges = [edges; {fromState, toState}];
        labels = [labels; symbol]; %Arc labels (symbols)
    end

    % Identifica archi unici
    [uniqueEdges, ~, ic] = unique(cell2table(edges), 'rows'); % Use table for multi-column comparison
    uniqueEdges = table2cell(uniqueEdges); % Back to cell array
    uniqueLabels = cell(size(uniqueEdges, 1), 1);

    % Group the labels for each unique arc
    for i = 1:size(uniqueEdges, 1)
        idx = find(ic == i); % Find occurrences of the single arch
        if ~isempty(idx)
            uniqueLabels{i} = strjoin(labels(idx), ', '); % Combine symbols into a single string
        end
    end

    % Graph creation
    G = digraph(uniqueEdges(:, 1), uniqueEdges(:, 2));

    % View graph
    figure;
    hold on;
    h = plot(G, 'Layout', 'circle', 'EdgeLabel', uniqueLabels); % Etichette dirette
    h.Marker='o';
    h.MarkerSize=60;
    h.NodeFontSize=15;
    h.NodeLabelColor='k';
    h.EdgeFontSize=12;
    h.LineWidth=2;
    h.EdgeColor='k';
    title('Fault Monitor');
    highlight(h, findnode(G, 'N'), 'NodeColor','green'); 
    highlight(h, findnode(G, 'F'),'NodeColor','red');
    hold off;
end