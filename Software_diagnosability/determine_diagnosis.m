%%  Determines state diagnosis ('F', 'N', 'U')
function diagnosis = determine_diagnosis(states)
    % Determines state diagnosis ('F', 'N', 'U')
    fault_states = false;
    no_fault_states = false;

    for i = 1:length(states)
        state = states{i};
        second_element = str2double(state(4));  % Assumes state in the form '(x,y)'.
        if second_element == 2
            fault_states = true;
        elseif second_element == 1
            no_fault_states = true;
        end
    end

    if fault_states && no_fault_states
        diagnosis = 'U';
    elseif fault_states
        diagnosis = 'F';
    elseif no_fault_states
        diagnosis = 'N';
    else
        diagnosis = 'U'; % Default
    end
end