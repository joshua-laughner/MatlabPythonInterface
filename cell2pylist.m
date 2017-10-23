function [ L ] = cell2pylist( C, dimorder, force_array )
%CELL2PYLIST Convert a Matlab cell into a Python list-of-lists
%   N = CELL2PYLIST( C ) Converts the Matlab array, A, into a Numpy
%   array N. Dimension order is treated so that L[:][0][0] == A(:,1,1).
%
%   N = CELL2PYLIST( C, 'match' ) behaves the same as the first
%   method.
%
%   N = CELL2PYLIST( C, 'native' ) Retains the native Python
%   dimension order in A, such that N[0][0][:] == A(:,1,1).

%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% INPUT CHECKING %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~iscell(C)
    error('pyinterface:badinput','C should be a cell array')
end

if ~exist('dimorder','var') || isempty(dimorder)
    dimorder = 'match';
else
    allowed_orders = {'match', 'native'};
    if ~any(strcmpi(dimorder, allowed_orders))
        error('pyinterface:badinput','DIMORDER (if given) must be one of %s', strjoin(allowed_orders, ', '));
    end
end

if ~strcmpi(force_array, 'scalar')
    warning('pyinterface:force_array', 'FORCE_ARRAY is not implemented for cell2pylist yet');
end

%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% MAIN FUNCTION %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%

% A multi-dimensional cell array in Matlab is best represented as nested
% lists in Python.  By default, the inner-most lists will be slices along
% the first dimension in Matlab, the list of those lists makes up the
% second dimension and so on:
%
% {'apple', 1; 'banana'; 2} == [['apple', 1], ['banana', 2]]
%
% This will use a recursive function that breaks up an array into these
% individual lists.
%
% Python's native ordering of dimensions is reversed from Matlab's, so if
% the 'match' dimorder is chosen, we should be able to get the dimension
% ordering to behave the same by reversing the order of the dimension of
% the Matlab array first.

if strcmpi(dimorder, 'match')
    permvec = ndims(C):-1:1;
    C = permute(C, permvec);
end

L = list_recursion(C);

end



