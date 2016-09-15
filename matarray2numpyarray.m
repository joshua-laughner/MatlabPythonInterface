function [ N ] = matarray2numpyarray( A, dimorder )
%MATARRAY2NUMPYARRAY Convert a Matlab array into a Python numpy array
%   N = MATARRAY2NUMPYARRAY( A ) Converts the Matlab array, A, into a Numpy
%   array N. Dimension order is treated so that N[:,0,0] == A(:,1,1).
%
%   N = MATARRAY2NUMPYARRAY( A, 'match' ) behaves the same as the first
%   method.
%
%   N = MATARRAY2NUMPYARRAY( A, 'native' ) Retains the native Python
%   dimension order in A, such that N[0,0,:] == A(:,1,1).


%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% INPUT CHECKING %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%

E = JLLErrors;
if ~isnumeric(A)
    E.badinput('A should be a numeric array')
end

if ~exist('dimorder','var')
    dimorder = 'match';
else
    allowed_orders = {'match', 'native'};
    if ~any(strcmpi(dimorder, allowed_orders))
        E.badinput('DIMORDER (if given) must be one of %s', strjoin(allowed_orders, ', '));
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% MAIN FUNCTION %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%

% To create a Python Numpy array, we need to create a set of nested Python
% lists.  The inner-most lists will be slices along the first dimension in
% Matlab, the list of those lists makes up the second dimension and so on:
%
% py.numpy.array([[1, 3], [2, 4]]) == [1 2; 3 4]
%
% This will use a recursive function that breaks up an array into these
% individual lists.
%
% Python's native ordering of dimensions is reversed from Matlab's, so if
% the 'match' dimorder is chosen, we should be able to get the dimension
% ordering to behave the same by reversing the order of the dimension of
% the Matlab array first.

if strcmpi(dimorder, 'match')
    permvec = ndims(A):-1:1;
    A = permute(A, permvec);
end

l = list_recursion(A, py.list);
N = py.numpy.array(l);

end

function l = list_recursion(A, l)
% This recursive function will test if 

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
        l.append(list_recursion(Aslice, py.list));
    end
end

end

