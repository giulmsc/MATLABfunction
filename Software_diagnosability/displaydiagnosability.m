%% function to display the results
function displaydiagnosability(cycle_states, cycle_info, is_diagnosable)
    % Funzione per formattare gli stati come "(x, N)" o "(x, F)"
    formatted_state = @(states) cellfun(@(s) char(format_states(s)), states, 'UniformOutput', false);
    % Funzione interna per sostituire 1 -> N e 2 -> F
    function formatted_state = format_states(state)
            % Verifica se lo stato è una stringa o un array numerico
            if iscell(state)
                state=state{1};
            end
            if isnumeric(state) && length(state) == 2
                x1 = state(1);
                x2 = state(2);
            elseif ischar(state) || isstring(state) % Se è una stringa, estrai i valori
                tokens = sscanf(state, '(%d,%d)');
                x1 = tokens(1);
                x2 = tokens(2);
            else
                formatted_state = '(?,?)';
                return;
            end
            
            % Converte il secondo valore (y) in N o F
            if x2 == 1
                y_str = 'N';
            elseif x2 == 2
                y_str = 'F';
            else
                y_str = '?';
            end
            
            % Restituisce lo stato formattato
            formatted_state = sprintf('(%d,%s)', x1, y_str);
        end

     % Ciclo leggibile
    readable_cycle = sprintf('%d', cycle_states(1));
    for j = 2:length(cycle_states)
        readable_cycle = [readable_cycle, sprintf(' <-> %d', cycle_states(j))];
    end

    % Intestazione ciclo
    disp('===========================');
    disp(['Uncertain Cycle: ', readable_cycle]);
    disp('---------------------------');
    
    % Stato iniziale
    disp('Initial State of the Cycle:');
    formatted_initial_state = formatted_state(cycle_info.initial_state); % Formatta lo stato iniziale
    disp(['  ', strjoin(formatted_initial_state, ', ')]);
    disp(['Diagnosis: ', cycle_info.initial_diagnosis]);
    disp('---------------------------');
    
    % Stati α e β
    for i = 1:length(cycle_info.steps)
        step = cycle_info.steps{i};

        % Formattazione degli stati α
        formatted_alpha_states = formatted_state(step.alpha_states);
        disp(['Alpha States reached with event "', step.event, '":']);
        disp(['  ', strjoin(formatted_alpha_states, ', ')]);
        disp(['Diagnosis: ', step.alpha_diagnosis]);
        disp('---------------------------');

        % Formattazione degli stati β
        formatted_beta_states = formatted_state(step.beta_states);
       disp('Beta States reached with unobservable event:');
        disp(['  ', strjoin(formatted_beta_states, ', ')]);
        disp(['Diagnosis: ', step.beta_diagnosis]);
        disp('---------------------------');
    end
    
    % Conclusione ciclo
    disp('Cycle Conclusion:');
    if is_diagnosable
        disp('  At least one state is NOT U.');
        disp('  The cycle is determined.');
    else
        disp('  All states are U.');
        disp('  The cycle is indeterminate.');
    end
    disp('===========================');
end