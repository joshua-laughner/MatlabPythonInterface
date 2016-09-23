function [ S ] = pydict2struct( pdict )
%PYDICT2STRUCT Convert a Python dictionary or list of dicts to a Matlab structure
%   S = PYDICT2STRUCT ( PDICT ) Converts PDICT to a Matlab structure, S. If
%   PDICT is a list of dictionaries, then S will be a multi-element
%   structure. Fields that are Python types are converted to corresponding
%   Matlab types if possible:
%       py.str --> char
%       py.list --> cell (not recursive currently)
%       py.numpy.ndarray --> numeric array
%       py.dict --> struct

E = JLLErrors;

if isa(pdict, 'py.list')
    pcell = cell(pdict);
    dict_test = true(1, numel(pcell));
    for a = 1:numel(pcell)
        dict_test = isa(pcell{a}, 'py.dict')
    end
    if ~all(dict_test)
        E.badinput('PDICT must be of type PY.LIST or PY.DICT. If is a PY.LIST, it must be a list of dictionaries.')
    end
elseif isa(pdict, 'py.dict')
    pcell = {pdict};
else
    E.badinput('PDICT must be of type PY.LIST or PY.DICT');
end

S = repmat(struct, 1, numel(pcell));

for a = 1:numel(pcell)
    stemp = struct(pcell{a});
    fns = fieldnames(stemp);
    for b = 1:numel(fns)
        val = stemp.(fns{b});
        if isnumeric(val)
            S(a).(fns{b}) = val;
        elseif isa(val, 'py.str')
            S(a).(fns{b}) = char(val);
        elseif isa(val,'py.list')
            S(a).(fns{b}) = cell(val);
        elseif isa(val, 'py.numpy.ndarray')
            S(a).(fns{b}) = numpyarray2matarray(val);
        elseif isa(val, 'py.dict')
            S(a).(fns{b}) = pydict2struct(val);
        else
            E.notimplemented('Cannot convert field of type %s', class(val));
        end
    end
end

end
