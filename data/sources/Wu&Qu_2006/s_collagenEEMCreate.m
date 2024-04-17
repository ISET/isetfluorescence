%% Create the EEM from the Wu and Qu data
%
ieInit;
datadir = fullfile(fiToolboxRootPath,'data','sources','Wu&Qu_2006');
chdir(datadir);

%% These are the emissions (photons, arbitrary units) when excited by different wavelengths

% The excitation wavelength is in the file name.  The emission spectra
% are in the files.
filePath355 = which('collagen_355nm.mat');
filePath375 = which('collagen_375nm.mat');
filePath405 = which('collagen_405nm.mat');
filePath435 = which('collagen_435nm.mat');
filePath457 = which('collagen_457nm.mat');
filePath473 = which('collagen_473nm.mat');

wave = 365:5:705;

% These scaling factors are provided by the might Wu and Gu This make the
% relative scaling for different excitation wavelengths correct, but not
% the absolute units.
mag = [1 1.2 1.8 3.2 4.8 5.8];

% The data here are in energy units.  Maybe we should convert to photons
% here?
collagen355 = ieReadSpectra(filePath355, wave) / mag(1);
collagen375 = ieReadSpectra(filePath375, wave) / mag(2);
collagen405 = ieReadSpectra(filePath405, wave) / mag(3);
collagen435 = ieReadSpectra(filePath435, wave) / mag(4);
collagen457 = ieReadSpectra(filePath457, wave) / mag(5);
collagen473 = ieReadSpectra(filePath473, wave) / mag(6);

% Make the matrix, but note that the wavelengths are not evenly spaced.
collagenE = cat(2, collagen355, collagen375, collagen405, collagen435, collagen457,...
    collagen473);

collagenQ = Energy2Quanta(wave,collagenE);

% These are the wavelengths
oldWave = [355, 375, 405, 435, 457, 473];
collagenEEM = fiEEMInterp(collagenQ, 'old wave', oldWave,...
    'new wave', wave,...
    'dimension', 'excitation');

%%
comment = 'Created in s_collagenEEMCreate.  Special case.  See script';
savedir = fullfile(fiToolboxRootPath,'data','Wu&Qu_2006');

save(fullfile(savedir,'collagenEEM.mat'),'wave','collagenEEM','comment');

%%
ieNewGraphWin;

% imagesc(flip(collagenEEM',1));
% imagesc(wave,wave,collagenEEM');
imagesc(wave,wave,flipdim(collagenEEM',1));
set(gca,'yticklabels',[700 650 600 550 500 450 400]);

xlabel('Emission wavelength');
ylabel('Excitation wavelength');

%%
emission415 = interp2(wave,wave,collagenEEM,415,wave);
ieNewGraphWin;
plotRadiance(wave,emission415);

%%
%{
%% Collagen in energy units
%
% ISET uses photons
%

% They call this the magnification.  So we assume that to get back to
% real relative units we should divide by this factor
mag = [1 1.2 1.8 3.2 4.8 5.8];

exWave = [355 375 405 435 457 473];
wave = 300:5:700;

datadir = fullfile(fiToolboxRootPath,'data','WuQu2006');
files = dir([datadir,filesep,'collagen*.mat']);

% We think these are energy units
eem = zeros(numel(wave),numel(files));
for ii=1:numel(files)
    [thisEmission,thisWave] = ieReadSpectra(files(ii).name);
    eem(:,ii) = interp1(thisWave,thisEmission,wave)' / sFactor(ii);
end
eem     = eem/max(eem(:));
eem(isnan(eem)) = 0;
eem = eem';

ieNewGraphWin; 
mesh(wave,exWave,eem);


%% The fluorophore model only uses ex and em vectors
% Here, we have the full matrix.
% At some point we need to update the fluorophore model.
% For now, we are just storing the whole matrix, after interpolating
% and normalizing

newEEM = interp2(exWave,wave,eem,wave,wave);

%%

%}
