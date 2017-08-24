function pdict = struct2pydict( S, suppress_warn )
% STRUCT2PYDICT Converts a structure to a Python dictionary or list of dicts
%   PDICT = STRUCT2PYDICT( S ) converts the Matlab structure S to a Python
%   dictionary, PDICT if S is a scalar structure. If S is not scalar, PDICT
%   will be a Python list of dictionaries. Because Python lists cannot be
%   multidimensional, a warning will be issued if S has 2 or more
%   non-singleton dimensions.
%
%   PDICT = STRUCT2PYDICT( S, false ) suppresses the warning issued if S
%   has 2 or more non-singletone dimensions.


if ~exist('suppress_warn', 'var')
    suppress_warn = false;
else
    if ~isscalar(suppress_warn) || ~islogical(suppress_warn) && ~isnumeric(suppress_warn)
        error('pyinterface:badinput','If given, SUPPRESS_WARN must be a scalar logical or numerical value')
    end
end


if ~isstruct(S)
    error('pyinterface:badinput','S must be a structure')
elseif ~isvector(S) && ~suppress_warn
    warning('S will be reshaped to a vector in the output list; any higher dimensional shape will be lost')
end

%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% MAIN FUNCTION %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%

if isscalar(S)
    pdict = convert_one_struct(S);
else
    pdict = py.list;
    for a=1:numel(S)
        pdict.append(convert_one_struct(S(a)));
    end
end

end

function pdict = convert_one_struct( S )

fns = fieldnames(S);
datacell = cell(2*numel(fns),1);
for a=1:numel(fns)
    nameind = (a-1)*2+1;
    fieldind = a*2;
    
    datacell{nameind} = fns{a};
    field = matlab2python(S.(fns{a}));
    datacell{fieldind} = field;
end

pdict = py.dict(pyargs(datacell{:}));

end
