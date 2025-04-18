function [fBASIS,wave] = fiLoadBasis(flNames,varargin)
% Load emission spectra from a cell array of fluorophore names
%
% Input
%   flNames - Cell array of legitimate fluorophore names
%
% Key/val arguments
%   wave      - Wavelength vector
%   normalize - Default is normalize to 1.  False to turn off
%
% Return
%   fBASIS - Matrix with columns of emissions
%   wave   - Wavelengths used
%
% See also
%  fluorophoreGet, fiReadFluorophore

% Example:
%{
flNames = {'CollagenWuQu','elastin_webfluor.mat'};
[fBasis,wave] = fiLoadBasis(flNames);
% ieNewGraphWin; plot(wave,fBasis);
%}
%{
wave = 400:10:700;
[fBasis,wave] = fiLoadBasis({'collagen1-smooth'},'wave',wave,'normalize',false);
ieNewGraphWin; plot(wave,fBasis);
%}

%% Parse
p = inputParser;
p.addRequired('flNames',@iscell);
p.addParameter('wave',350:750,@isvector);
p.addParameter('normalize',true,@islogical);

p.parse(flNames,varargin{:});

normalize = p.Results.normalize;
wave = p.Results.wave;

%% Check they exist
fBASIS = zeros(numel(wave),numel(flNames));

for ff = 1:numel(flNames)
    [~,name,~] = fileparts(flNames{ff});
    if ~exist([name,'.mat'],'file')
        error('Missing %s\n',flNames{ff});
    else
        tst = fiReadFluorophore(flNames{ff});
        if normalize
            fBASIS(:,ff) = fluorophoreGet(tst,'normalized emission','wave',wave);
        else
            fBASIS(:,ff) = fluorophoreGet(tst,'emission','wave',wave);
        end

    end
end

end

