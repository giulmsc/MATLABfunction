%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function: cycle_check
%
% Description:
% This function identifies and analyses any **uncertain cycles** within a
% discrete event system. Uncertain cycles are formed by states with an
% indeterminate ('U'). The function checks whether the system is **diagnosable**, i.e.
% if it contains cycles that make it impossible to distinguish between normal and fault states.
%
% Input:
%   - recG: Structure with information on system transitions and mappings.
%       - recG.state_map: Map associating numerical states with symbolic labels.
%   - DIAG: Structure with diagnostic information:
%       - DIAG.trans_matrix: Matrix of observable transitions.
%       - DIAG.observer_state_matrix: Matrix of observer states.
%   - diagnosis: Cell with the diagnosis of each state ('N' = normal, 'F' = fault, 'U' = undetermined).
%   - cycle_graph: Boolean flag (1 or 0) to display uncertain cycles found graphically.
%
% Output:
%   - No value returned explicitly.
%   - Display on screen:
%   - Information about the uncertain cycles found and their diagnostic status.
%    - A message indicating whether the system is **diagnosable** or not.
%    - Optionally, if `cycle_graph` is active, displays each uncertain cycle graphically.
%
% Operation:
%   1. **Identifies uncertain states**: Finds states with diagnosis 'U'.
%   2. **Identifies uncertain transitions**: Filters transitions involving only uncertain states.
%   3. **Identifies cycles**:
%       - Uses an oriented graph to find cycles formed by uncertain states.
%   4. **analyses each cycle**:
%       - For each cycle found:
%       - Calls `refine_cycle` to analyse α and β states and determine the diagnosis.
%       - Call `cycle_diagnosis` to check if the cycle is diagnosable.
%       - Displays results with `displaydiagnosability`.
%       - Displays the cycle graph if required (`cycle_graph` = 1).
%   5. **Determines system diagnosability**:
%       - If at least one cycle is not diagnosable, the system is not diagnosable.
%       - If no cycle is undiagnosable, the system is diagnosable
% 
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function cycle_check(recG, DIAG, diagnosis, cycle_graph)
   
    trans_matrix=DIAG.trans_matrix;
    obs_matrix=DIAG.observer_state_matrix;
% Identifies uncertain states
    uncertain_states = find(strcmp(diagnosis, 'U'));
    state_map_inverse = containers.Map(values(recG.state_map), keys(recG.state_map));
    % Find transitions between uncertain states
    uncertain_transitions = trans_matrix(ismember(trans_matrix(:, 1), uncertain_states) & ...
                                         ismember(trans_matrix(:, 3), uncertain_states), :);

    %Check for uncertain cycles
    obs = digraph(uncertain_transitions(:, 1), uncertain_transitions(:, 3));
    cycles = allcycles(obs);
    if ~isempty(cycles)
        %disp('Uncertain cycles found.');
        for i = 1:length(cycles)
            % Extract the current cycle
            cycle_states = cycles{i};
            cycle_number=i;
           
            % Filter transitions of the current cycle
            cycle_transitions = trans_matrix(ismember(trans_matrix(:, 1), cycle_states) & ...
                                              ismember(trans_matrix(:, 3), cycle_states), :);
          
            %analysis and diagnosis of uncertain cycle found
            [cyclo_info, all_diagnoses, ~]=refine_cycle(obs_matrix, state_map_inverse, recG, ...
                                                        cycle_states, cycle_transitions);
            

            % cycle_diagnosis returns the diagnosis of all cycle
            is_diagnosable=cycle_diagnosis(all_diagnoses);

            % display the results of the analysis
            displaydiagnosability(cycle_states, cyclo_info, is_diagnosable);

            % view graph
            if cycle_graph ==1
                visualizeCyclegraph(cyclo_info, cycle_number);
            end
           
        end
             if is_diagnosable % if is diagnosable is true the system does not contain 
                 % indeterminate cycle and it is diagnosable
                disp('---------------------------');
                disp('The system G is DIAGNOSABLE.');
             else % if is_diagnosable is false the system contains indeterminate cycle and i
                 % t is not diagnosable
                disp('---------------------------');
                disp('The system G is NOT DIAGNOSABLE.');
            end
               
    else
        %if no uncertain cycle are found G is certainly diagnosable
        disp('---------------------------');
        disp('No uncertain cycle found, G is DIAGNOSABLE');
    end
    
end
 







