function numeric_transitions = convert_to_numeric(transitions, state_map, event_map)
    % Converte transizioni con stati stringa in transizioni numeriche
    % transitions: cell array delle transizioni
    % state_map: mappa per la conversione degli stati (contenente nomi e numeri)
    % event_map: mappa per la conversione degli eventi (stringhe -> numeri)

    numeric_transitions = [];
    for i = 1:size(transitions, 1)
        from_state = transitions{i, 1};
        event = transitions{i, 2};
        to_state = transitions{i, 3};

        % Controlla se gli stati sono nella mappa
        if isKey(state_map, from_state) && isKey(state_map, to_state)
            % Se l'evento è una cella, estrai il contenuto
            if iscell(event)
                event = event{1};
            end

            % Mappa l'evento se è una stringa
            if ischar(event) || isstring(event)
                if isKey(event_map, event)
                    event = event_map(event);
                else
                    error('Event not found in mapping: %s', event);
                end
            end

            % Verifica che l'evento sia numerico
            if isnumeric(event)
                numeric_transitions = [numeric_transitions; ...
                                       state_map(from_state), event, state_map(to_state)];
            else
                error('Event must be numeric or mapped to a number, but got: %s', class(event));
            end
        else
            error('State not found in mapping: %s or %s', from_state, to_state);
        end
    end
end