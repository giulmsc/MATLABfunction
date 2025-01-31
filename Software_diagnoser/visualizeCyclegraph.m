%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function: visualiseCyclegraph
%
% Description:
% This function graphically displays a refined cycle of an observer as
% a directed graph. The cycle includes information on the α and β states and their
% diagnosis ('N', 'F', 'U') within the nodes.
%
% Input:
% - cycle_info: Structure containing cycle information, with the following fields:
% - cycle_info.steps: Array of structures describing each step of the cycle, with:
%           - `alpha_states`: α-states of the current step.
%           - `beta_states`: β-states of the current step.
%           - `alpha_diagnosis`: Diagnosis of α-states.
%           - `beta_diagnosis`: Diagnosis of β-states.
%           - `event`: Observable event associated with the step.
% - cycle_info.initial_state: Initial state of the cycle.
% - cycle_info.initial_diagnosis: Diagnosis of the initial state.
% - cycle_number: Cycle number to be displayed in the graph title.
%
% Output:
% - No value returned. The graph is displayed graphically.
%
% Operation:
% 1. **Initialisation of Nodes and Arcs**:
%   - Creates nodes for the initial state, α and β states of each step.
%    - Creates arcs labelled with the events connecting the nodes.
% 2. **State Formatting**:
%   - Converts states to readable `(num,N)` or `(num,F)` format using
% the auxiliary function `format_states_numeric`.
% 3. **Creating the Graph**:
%   - Constructs the directed graph with the defined nodes and arcs.
% 4. **Graph Display**:
%   - Adds custom labels to nodes with information on α/β states and diagnostics.
%   - Adds a title including cycle number.
%
% Auxiliary Functions:
% - `format_states_numeric`: Formats states as `(num,N)` or `(num,F)` based
%   their second number.
%
% Usage:
% visualizeCyclegraph(cycle_info, cycle_number);
% Displays the refined cycle as a graph with information about the states and diagnostics.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function visualizeCyclegraph(cycle_info,cycle_number)
    
% Initialisation of nodes and arcs
    num_steps = length(cycle_info.steps);
    s = {}; % source nodes
    t = {}; % target nodes
    labels = {}; % edges' labels
    node_labels = containers.Map; % nodes' labels

   % initial node with internal states and diagnosis
    initial_node = 'y_0';
    formatted_initial_states = format_states_numeric(cycle_info.initial_state);
    if ischar(cycle_info.initial_diagnosis) || isstring(cycle_info.initial_diagnosis)
        initial_content = sprintf('y_0\n%s\n(%s)', formatted_initial_states, cycle_info.initial_diagnosis);
    else
        initial_content = sprintf('y_0\n%s\n(%s)', formatted_initial_states, strjoin(string(cycle_info.initial_diagnosis), ', '));
    end
    node_labels(initial_node) = initial_content;

    % Construction of nodes and arcs for each step alpha and beta
    for i = 1:num_steps
        step = cycle_info.steps{i};
        
       % alpha and beta states
        alpha_node = sprintf('α_%d', i);
        beta_node = sprintf('β_%d', i);
        
        % Format the alpha and beta states
        formatted_alpha_states = format_states_numeric(step.alpha_states);
        formatted_beta_states = format_states_numeric(step.beta_states);
        
        alpha_content = sprintf('%s\n%s\n(%s)', alpha_node, formatted_alpha_states, step.alpha_diagnosis);
        beta_content = sprintf('%s\n%s\n(%s)', beta_node, formatted_beta_states, step.beta_diagnosis);
        
        % Assigns labels to nodes
        node_labels(alpha_node) = alpha_content;
        node_labels(beta_node) = beta_content;

        % Addition of bows
        s{end+1} = initial_node; t{end+1} = alpha_node; labels{end+1} = step.event;
        s{end+1} = alpha_node;   t{end+1} = beta_node;  labels{end+1} = sprintf('𝜀', step.event);
        
        % Update the initial node
        initial_node = beta_node;
    end

    % Final arc added to close the loop
    s{end+1} = initial_node;
    t{end+1} = 'y_0';
    labels{end+1} = ' ';

    % Graph creation
    G = digraph(s, t);

    % Graph visualisation
    figure;
    hold on;
    h1 =plot(G, 'Layout', 'force', 'NodeFontSize', 5, 'EdgeFontSize', 5, 'EdgeLabel', {});
    h1.Marker='none';
    h1.MarkerSize=82;
    h1.NodeColor='k';
    h1.LineWidth=2;
    h1.EdgeColor='k';
    h2 = plot(G, 'Layout', 'force', 'NodeFontSize', 15, 'EdgeFontSize', 15, 'EdgeLabel', labels);
    h2.Marker='none';
    h2.MarkerSize = 80;
    h2.NodeColor = 'white';
    h2.LineWidth = 2;
    h2.EdgeColor='k';

    % Manually adding labels to nodes using text
    num_nodes = length(h2.XData); % number of nodes
    for i = 1:num_nodes
        x = h2.XData(i); 
        y = h2.YData(i); 
        
        % Extract the corresponding label
        if isKey(node_labels, G.Nodes.Name{i})
            node_label = node_labels(G.Nodes.Name{i}); % Customised node content
        else
            node_label = G.Nodes.Name{i}; %Default node name
        end
        
        % Add text to node with customised content
        text(x, y, node_label, ...
            'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', ...
            'FontSize', 15, 'BackgroundColor', 'w', 'EdgeColor', 'k');
    end

    % Title
    title(sprintf('Refined Observer Cycle %d ', cycle_number));
    set(gca, 'XColor', 'none', 'YColor', 'none'); 
    hold off;
end

function formatted_states = format_states_numeric(state_list)
    % Function to format states as (1,N) or (2,F)
    state_texts = {}; % Initialise list of formatted states
    
    for i = 1:numel(state_list)
        nums = sscanf(state_list{i}, '(%d,%d)'); % Extracts pair of numbers
        first_num = nums(1);
        second_num = nums(2);
        if second_num == 1
            state_texts{end+1} = sprintf('(%d,N)', first_num);
        elseif second_num == 2
            state_texts{end+1} = sprintf('(%d,F)', first_num);
        end
    end
    formatted_states = strjoin(state_texts, ', '); 
end