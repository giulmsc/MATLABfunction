function numeric_transitions = convert_states_to_numeric_cells(transitions, state_map)
    % Converte solo gli stati in numeri, mantenendo i simboli invariati
    % transitions: cell array delle transizioni
    % state_map: mappa per la conversione degli stati

    numeric_transitions = cell(size(transitions)); % Mantiene il formato cell array
    for i = 1:size(transitions, 1)
        from_state = transitions{i, 1}; % Stato di partenza
        event = transitions{i, 2};      % Evento (lasciato invariato)
        to_state = transitions{i, 3};   % Stato di arrivo

        % Converti gli stati in numeri
        if isKey(state_map, from_state)
            numeric_transitions{i, 1} = state_map(from_state);
        else
            error('State not found in mapping: %s', from_state);
        end

        % Mantieni i simboli invariati
        numeric_transitions{i, 2} = event;

        if isKey(state_map, to_state)
            numeric_transitions{i, 3} = state_map(to_state);
        else
            error('State not found in mapping: %s', to_state);
        end
    end
end