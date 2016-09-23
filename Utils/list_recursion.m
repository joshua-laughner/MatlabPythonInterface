function l = list_recursion(A)
% LIST_RECURSION Turns a multidimension array into nested Python lists
%   L = LIST_RECURSION(A) Takes a Matlab array, A, and converts it into
%   nested Python lists. Each slice along the first dimension will be the
%   inner-most lists, and successive dimensions will be the next level out.
%
%   Examples:
%       list_recursion([1 2; 3 4])
%       = [[1.0, 3.0], [2.0, 4.0]]
%
%       A = cat(3, [1 2 3; 4 5 6], [10 20 30; 40 50 60])
%       list_recursion(A)
%       = [[[1.0, 4.0], [2.0, 5.0], [3.0, 6.0]], 
%          [[10.0, 40.0], [20.0, 50.0], [30.0, 60.0]]]

l = py.list;

if isvector(A)
    if ~isrow(A); 
        % Python requires that A be 1-by-N, i.e. a row vector
        A = A';
    end
    l=(py.list(A));
else
    sz = size(A);
    A2 = reshape(A, prod(sz(1:end-1)), sz(end));
    for a=1:size(A, ndims(A))
        % ismatrix is true if ndims(A) <= 2
        % Test A not A2 because A2 will always be a matrix
        if ~ismatrix(A) 
            Aslice = reshape(A2(:,a), sz(1:end-1));
        else
            Aslice = A2(:,a);
        end
        l.append(list_recursion(Aslice));
    end
end

end