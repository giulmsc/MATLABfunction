function formattedTransitions = convert_transitions_to_symbols(transitions, num_to_symbol_map)
    % Converte una matrice di transizioni numeriche in formato simbolico
    formattedTransitions = {}; % Inizializza il cell array delle transizioni
    for i = 1:size(transitions, 1)
        stato_iniziale = transitions(i, 1:2); % Stato iniziale
        evento = num_to_symbol_map(transitions(i, 3)); % Converti il numero in simbolo
        stato_finale = transitions(i, 4:5); % Stato finale

        % Aggiungi la transizione
        formattedTransitions = [formattedTransitions; {stato_iniziale, evento, stato_finale}];
    end
end