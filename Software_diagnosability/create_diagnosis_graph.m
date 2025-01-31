function create_diagnosis_graph(cycle_info)
    % Crea un grafo diretto basato su stati e transizioni (Alpha -> Beta)
    
    % Inizializza lista nodi e archi
    nodes = {}; % Nodi del grafo
    edges = []; % Archi del grafo
    edge_labels = {}; % Etichette degli archi

    % Funzione per formattare stati nel formato (x, N) o (x, F)
    function state_str = format_states(states)
        state_str = strjoin(cellfun(@(s) sprintf('(%d,%s)', s(1), replace_value(s(2))), states, 'UniformOutput', false), ', ');
    end

    % Funzione per convertire il valore 1->N e 2->F
    function result = replace_value(value)
        if value == 1
            result = 'N';
        elseif value == 2
            result = 'F';
        else
            result = '?';
        end
    end

    % Nodo iniziale
    initial_state = format_states(cycle_info.initial_state);
    nodes{end+1} = initial_state;

    % Itera su ciascun passo del ciclo (Alpha -> Beta)
    for i = 1:length(cycle_info.steps)
        step = cycle_info.steps{i};

        % Formatta Alpha e Beta States
        alpha_state = format_states(step.alpha_states);
        beta_state = format_states(step.beta_states);

        % Aggiungi Alpha State come nodo
        if ~ismember(alpha_state, nodes)
            nodes{end+1} = alpha_state;
        end

        % Aggiungi Beta State come nodo
        if ~ismember(beta_state, nodes)
            nodes{end+1} = beta_state;
        end

        % Aggiungi arco Alpha -> Beta
        edges = [edges; find(strcmp(nodes, alpha_state)), find(strcmp(nodes, beta_state))];
        edge_labels{end+1} = sprintf('Step %d', i);
    end

    % Creazione del grafo
    G = digraph(edges(:,1), edges(:,2));
    
    % Visualizzazione del grafo
    figure;
    h = plot(G, 'Layout', 'layered', 'NodeLabel', nodes);
    title('Diagnosis State Graph with Transitions');

    % Aggiunta etichette agli archi
    for i = 1:numel(edge_labels)
        highlight(h, 'Edges', i, 'EdgeLabel', edge_labels{i});
    end

    % Evidenzia il nodo iniziale
    highlight(h, 1, 'NodeColor', 'r', 'MarkerSize', 8);
end