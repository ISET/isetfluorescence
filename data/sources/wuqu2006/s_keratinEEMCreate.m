%% s_keratinEMMCreate
%
% Create the keratin fluorophore based on the might Wu and Qu
%

%% 
ieInit;

%% These are the emissions (photons, arbitrary units) when excited by different wavelengths

filePath355 = which('Keratin_355nm.mat');
filePath375 = which('Keratin_375nm.mat');
filePath405 = which('Keratin_405nm.mat');
filePath435 = which('Keratin_435nm.mat');
filePath457 = which('Keratin_457nm.mat');
filePath473 = which('Keratin_473nm.mat');

%% Read spectra and normalize them

wave = 365:5:705;

% These scaling factors are provided by the might Wu and Qu This make the
% relative scaling for different excitation wavelengths correct, but not
% the absolute units.
mag = [1, 1.4, 2.1, 3.5, 5, 5.6];

% The data here are in energy units.  Maybe we should convert to photons
% here?
keratin355 = ieReadSpectra(filePath355, wave) / mag(1);
keratin375 = ieReadSpectra(filePath375, wave) / mag(2);
keratin405 = ieReadSpectra(filePath405, wave) / mag(3);
keratin435 = ieReadSpectra(filePath435, wave) / mag(4);
keratin457 = ieReadSpectra(filePath457, wave) / mag(5);
keratin473 = ieReadSpectra(filePath473, wave) / mag(6);

% Make the matrix, but note that the wavelengths are not evenly spaced.
keratin = cat(2, keratin355, keratin375, keratin405, keratin435, keratin457,...
    keratin473);

%{
% The authors used long pass filters to make the measurements. So the
% emissions start a little above the excitation matrix.  Notice that the
% emission curves form two groups.  The first two fall off the same way but
% the last four fall off together in a different pattern.
ieNewGraphWin; plot(wave,keratin);
%}

% These are the excitation wavelengths
oldWave = [355, 375, 405, 435, 457, 473];

%% Interpolate to a better wavelength sampling

keratinEEM = fiEEMInterp(keratin, 'old wave', oldWave,...
    'new wave', wave,...
    'dimension', 'excitation');


%% Use parafac to estimate excitation emission N=1
% To get the actual eem at a wavelength, use
%   fluorophorePlot(fl,'eem wave','excitation wave',val)
%
nFluorophores = 1;
spectra = parafac(keratinEEM,nFluorophores);
% ieNewGraphWin; plot(wave,spectra{1},'k-',wave,spectra{2},'r-');

%% Create the fluorophore
keratinF = fluorophoreCreate('type','custom',...
    'name','keratin',...
    'solvent','none', ...
    'wave', wave, ...
    'excitation',spectra{2},...
    'emission',spectra{1}); 

% Adds the EEM that was used to derive the ex and em vectors above.
keratinF = fluorophoreSet(keratinF,'eem',keratinEEM);

%{
fluorophorePlot(keratinF,'eem');
fluorophorePlot(keratinF,'eem wave','excitation wave',420);
fluorophorePlot(keratinF,'excitation');
fluorophorePlot(keratinF,'emission');
%}
    
%% Save
comment = 'See s_keratinEEMCreate. EEM data from wuqu3006. parafac (N=1) derived excitation/emission.';
savePath = fullfile(fiToolboxRootPath,'data','WuQu2006','KeratinWuQu');
fiSaveFluorophore(savePath, keratinF);

%% END