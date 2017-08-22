function [ N ] = matarray2numpyarray( A, dimorder, dtype )
%MATARRAY2NUMPYARRAY Convert a Matlab array into a Python numpy array
%   N = MATARRAY2NUMPYARRAY( A ) Converts the Matlab array, A, into a Numpy
%   array N. Dimension order is treated so that N[:,0,0] == A(:,1,1).
%
%   N = MATARRAY2NUMPYARRAY( A, 'match' ) behaves the same as the first
%   method.
%
%   N = MATARRAY2NUMPYARRAY( A, 'native' ) Retains the native Python
%   dimension order in A, such that N[0,0,:] == A(:,1,1).
%
%   N = MATARRAY2NUMPYARRAY( A, ___, DTYPE ) allows you to specify the data
%   type as a string (e.g. 'bool', 'float', 'int64'). The dimension order
%   must be specified ('match' or 'native') but if you pass an empty
%   string or, the default is used, i.e. MATARRARY2NUMPYARRAY( A, [],
%   'bool'). Note that this will be overridden if A is a Matlab logical
%   array.


%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% INPUT CHECKING %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%

E = JLLErrors;
if ~isnumeric(A) && ~islogical(A)
    E.badinput('A should be a numeric or logical array')
end

if ~exist('dimorder','var') || isempty(dimorder)
    dimorder = 'match';
else
    allowed_orders = {'match', 'native'};
    if ~any(strcmpi(dimorder, allowed_orders))
        E.badinput('DIMORDER (if given) must be one of %s', strjoin(allowed_orders, ', '));
    end
end

% Python via Matlab does not support logical arrays, however, if we convert
% it to a numerical array, but set the numpy data type to 'bool' we get the
% desired effect.
if islogical(A)
    A = double(A);
    dtype = 'bool';
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

l = list_recursion(A);
if ~exist('dtype', 'var')
    N = py.numpy.array(l);
else
    N = py.numpy.array(l, pyargs('dtype', dtype));
end

end
