%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function: cycle_diagnosis
%
% Description:
% This function verifies the "diagnosability" of an uncertain cycle in a discrete-event system.
% discrete events, based on the diagnoses collected for the cycle states.
% A cycle is considered **non-diagnosable** if all states have 'U' diagnoses
% (indeterminate), otherwise it is "diagnosable".
%
% Input:
% - all_diagnoses: A cell containing the diagnoses of all states in the cycle.
% Each element can be:
%                       - 'N' -> Normal state.
%                       - 'F' -> Fault state.
%                       - 'U' -> Undefined state.
%
% Output:
% - is_diagnosable: Boolean value indicating whether the cycle is diagnosable:
%               - `true` -> At least one state of the loop is diagnosable (not 'U').
%               - `false` -> All cycle states are undetermined ('U').
%
% Operation:
% 1. Checks whether all elements of `all_diagnoses` are equal to 'U'.
% 2. If yes, returns `false` indicating that the loop is not diagnosable.
% 3. Otherwise, returns `true` indicating the loop is diagnosable.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function is_diagnosable = cycle_diagnosis(all_diagnoses)
    % Checking the diagnosability of the cycle
    if all(strcmp(all_diagnoses, 'U'))
        is_diagnosable = false; % G non è diagnosable
        %disp('All states of the cycle are U, the cycle is indeterminate. G is NOT DIAGNOSABLE.');
    else
        is_diagnosable = true; % G è diagnosable
        %disp('At least one state of the cycle is NOT U, the cycle is determined. G is DIAGNOSABLE.');
    end
end