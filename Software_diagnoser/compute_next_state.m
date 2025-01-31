function x_next = compute_next_state(x, e, transitions1, transitions2, alphabet1, alphabet2)
    % Calculates the next state for a state pair and a numeric symbol
   
    % current states
    x1 = x(1); % Current state for G1
    x2 = x(2); % Current state for G2
    %disp(['Current state x: [', num2str(x1), ',', num2str(x2), ']']);
    %disp(['symbol e (number): ', num2str(e)]);
    
    % Verifica appartenenza di e agli alfabeti
    in_E1 = ismember(e, alphabet1); % e ∈ E'
    in_E2 = ismember(e, alphabet2); % e ∈ E''
    %disp(['in_E1: ', num2str(in_E1), ', in_E2: ', num2str(in_E2)]);
    % Variable for next states
    x1_next = [];
    x2_next = [];
    transitions_c1=cell2mat(transitions1);
    transitions_c2=cell2mat(transitions2);
    

    % Case 1: e ∈ E' \ E'' (present only in E')
    if in_E1 && ~in_E2
        %disp('Case: e ∈ E1');
        idx1 = find(transitions_c1(:, 1) == x1 & transitions_c1(:, 2) == e, 1);
        if ~isempty(idx1)
            x1_next = transitions_c1(idx1, 3);
            %disp(['x1_next found: ', num2str(x1_next)]);
        else
           % disp('No transition found in G1.');
        end
        x_next = [x1_next, x2];

    % Case 2: e ∈ E'' \ E' (present only in E'')
    elseif ~in_E1 && in_E2
        %disp('Case: e ∈ E2');
        idx2 = find(transitions_c2(:, 1) == x2 & transitions_c2(:, 2) == e, 1);
        if ~isempty(idx2)
            x2_next = transitions_c2(idx2, 3);
           % disp(['x2_next found: ', num2str(x2_next)]);
        else
           % disp('No transition found in G2.');
        end
        % The status of G1 remains unchanged
        x_next = [x1, x2_next];

    % Case 3: e ∈ E' ∩ E'' (present in both alphabets)
    elseif in_E1 && in_E2
        %disp('Case: e ∈ E');
        idx1 = find(transitions_c1(:, 1) == x1 & transitions_c1(:, 2) == e, 1);
        idx2 = find(transitions_c2(:, 1) == x2 & transitions_c2(:, 2) == e, 1);

        if ~isempty(idx1)
            x1_next = transitions1(idx1, 3);
        else
           % disp('No transition found in G1 for e ∈ E');
        end
        if ~isempty(idx2)
            x2_next = transitions2(idx2, 3);
        else
           % disp('No transition found in G2 for e ∈ E');
        end

        if ~isempty(x1_next) && ~isempty(x2_next)
            x_next = [x1_next, x2_next];
        else
            x_next = []; % If one of the transitions is not defined
        end
        else
        % disp('Case: e does not belong to any of the alphabets.');
        x_next = [];
          
        end
    % --- Adding the final check ---
         if numel(x_next) ~= 2 % check whether the number of elements in x_next corresponds to the exact number 
            if isempty(x_next)
                x_next = []; % Return empty state if there are no valid transitions and x_next is empty
            else
                % If a value is missing from next_state, i.e. 
                % if the transition only starts from one state, complete with a placeholder (e.g. -1)
                x_next = [x_next, -1];
            end
        end
end