function [ fl ] = fiReadFluorophore( fName, varargin )
% Read fluorophore spectral properties from a Matlab (.mat) file fName.
%
% Synopsis
%   fl = fiReadFluorophore( fName, varargin)
%
% Brief
%
%  The fName (Fluorescent file) should have been saved using
%  fiSaveFluorophore. 
%
% Inputs:
%   fName - path to the fluorescence data file
%
% key/val  parameters
%   'wave' - a vector of waveband samples. Defaults to file data.
%   'qe'   - fluorophore quantum efficiency (default = 1).
%
% Output:
%   fl - the fiToolbox fluorophore structure
%
% See also
%  fluorophoreGet, fluorophosreSet fiSaveFluorophore

% Examples:
%{
  files = dir(fullfile(fiToolboxRootPath,'data','LifeTechnologies','*.mat'));
  thisF = fiReadFluorophore(files(3).name)
%}

%% File name, wave sampling, quantum efficiency
p = inputParser;
p.addRequired('fName',@ischar);
p.addParameter('wave',[],@isvector);
p.addParameter('qe',1,@isscalar);

p.parse(fName,varargin{:});
inputs = p.Results;

%% Load the file, which is a struct
data = load(inputs.fName);

% Create the fluorophore struct, with the wavelength in the file
fl = fluorophoreCreate('type','custom',...
                       'wave',data.wave,...
                       'name',data.name,...
                       'solvent',data.solvent,...
                       'excitation',data.excitation,...
                       'emission',data.emission);

if isfield(data,'comment')
    fl = fluorophoreSet(fl,'comment',data.comment);
end

% Set the qe
fl = fluorophoreSet(fl,'qe',inputs.qe);

% Change to a specified wavelength, if passed in.
if ~isempty(inputs.wave)
    fl = fluorophoreSet(fl,'wave',inputs.wave);
end

end

