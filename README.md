# MatlabPythonInterface
Collection of Matlab functions that extend the conversion of Matlab to Python types and vice versa

## Setup
Add the top directory and the `Utils` subdirectory to your Matlab path.

## Usage
Each function in this repo has a doctring, use the Matlab `help` function to see it. In general, you can use the `matlab2python` function to 
convert any Matlab type to a Python type and the `python2matlab` function for the reverse.

This does not handle configuring your Matlab installation to call Python functions. See the 
[MathWorks documentation](https://www.mathworks.com/help/matlab/call-python-libraries.html)
for help with general setup.
