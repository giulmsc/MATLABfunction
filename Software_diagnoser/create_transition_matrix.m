function transition_matrix = create_transition_matrix(transitions, alphabet_map)
    % Mappatura dell'alfabeto ai numeri
    %num_symbols = length(transitions.alphabet);
    %alphabet_map = containers.Map(transitions.alphabet, num2cell(1:num_symbols));

    
    % Prealloca la matrice delle transizioni
    num_transitions = size(transitions, 1);
    transition_matrix = [];

    % Riempi la matrice delle transizioni
    for i = 1:num_transitions
        stato1 = transitions{i, 1};
        simbolo = transitions{i, 2};
        stato2 = transitions{i, 3};
        
        if iscell(simbolo)
            simbolo = simbolo{1}; % Estrai il valore effettivo dalla cella
        end
        % Ottieni l'indice numerico del simbolo
        simbolo_idx = alphabet_map(simbolo);

        % Aggiungi la transizione alla matrice
        transition_matrix(i,:)=[stato1, simbolo_idx, stato2];
    end
end