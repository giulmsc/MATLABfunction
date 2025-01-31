%% function that converts data into cells
function cell_array = ensure_cell(data)
    % Converts data to a cell, if not already
    if ~iscell(data)
        cell_array = num2cell(data, 1); % Converts numbers to cells
    else
        cell_array = data;
    end
end