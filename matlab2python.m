function [ pyval ] = matlab2python( val )
%MATLAB2PYTHON Convert Matlab type into Python type.
%   PYVAL = MATLAB2PYTHON( VAL ) Converts the Matlab type VAL into a Python
%   type PYVAL. Calls the appropriate conversion function based on the type
%   of the input. Several of the other functions in this repo use this
%   recursively to convert nested cell arrays or structs.
%
%   Current type conversions are:
%       Scalar numbers -> scalar numbers (direct conversion)
%       Numeric arrays -> numpy ndarrays (matarray2numpyarray)
%       Strings -> strings (direct conversion)
%       Cell arrays -> lists (cell2pylist)
%       Structures -> dictionaries (struct2pydict)

if isnumeric(val)
    if ~isscalar(val)
        pyval = matarray2numpyarray(val);
    else
        % Scalar numeric values can be directly converted.
        pyval = val;
    end
elseif ischar(val)
    % strings can be directly converted
    pyval = val;
elseif iscell(val)
    pyval = cell2pylist(val);
elseif isstruct(val)
    pyval = struct2pydict(val);
else
    error('pyinterface:not_implemented','Unable to convert field of type "%s" into appropriate Python type', class(val));
end
end

