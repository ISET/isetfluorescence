% s_CompareFluorophores.m

% Purpose: 
%   The ultimate purpose of this script is to determine which EEM data to
%   use in simulations
%   Read in the excitation and emission spectra for different fluorophores from different data sources and compare
%   NADH, FAD, collagen, elastin, keratin, porphyrins
%   Some of the data are stored as Excitation Emission Matrices (EEMs)
%       in this case, we use the function fiReadFluorophore to read the
%       excitation and/or emission data
%   For my own simulatios and those we published, I (Joyce) chose to use the 
%   DaCosta data that are stored in the directory called webfluor.  
%       Unfortunately, the link to the original DaCosta data no longer exists

% Data Sources: 
%   The excitation and emission data for the different fluorophores are
%   obtained from graphs published in various sources.  Data from these
%   graphs were generated using grabit.  
%   The amplitude of excitation and emission range between 0 and 1, since the
%   concentration of each tissue fluorophore is unknown. The actual
%   concentration will be determined by tissue location and/or simulated. 
%   The best data will have the entire spectra mapped out ... otherwise the
%   max which is set to 1 will not be the actual maximum excitation or emission
%   For this reason, we discard any data for which the entire spectra is not
%   measured (e.g. Deal et al 2018)
%   In some cases the data from different sources overlap - 
%       I will check this again and update the script if necessary

% This script requires the isetcam and isetfluorescence toolboxes
%   https://github.com/ISET/isetcam
%   https://github.com/ISET/isetfluorescence
% 
%
%% Set the path (this is my path)
%%{
 cd /Users/joyce/Github/isetcam;
 addpath(genpath(pwd));
 cd /users/joyce/Github/isetfluorescence/;
 addpath(genpath(pwd));
%}
ieInit;

%% Set the range of wavelengths 
theseWaves = 200:5:700;

%% Plot Excitation 
% Excitation plotted as a function of wavelength
% ~ absorption of light as function of wavelength

% NADH
ieNewGraphWin; 
chdir(fullfile(fiToolboxRootPath,'data','Monici'));
NADH = fiReadFluorophore('NADH.mat','wave',theseWaves); 
plot(theseWaves,NADH.excitation,'g','LineWidth',3); hold on;
chdir(fullfile(fiToolboxRootPath,'data','webfluor'));
NADH = fiReadFluorophore('NADH.mat','wave',theseWaves); 
plot(theseWaves,NADH.excitation,'r:','LineWidth',3); hold on;
legend('Monici 2005', 'DaCosta et al 2003');
title('NADH Excitation');
ax = gca;
ax.FontSize=16;
xlabel('Wavelength (nm)');
% x = [385,385]; y = [0,1]; plot(x,y,'k--','LineWidth',3); % 

% FAD
ieNewGraphWin; 
FADExcitation = ieReadSpectra('FAD_excitation_DealEtAl2018.mat',theseWaves); 
plot(theseWaves,FADExcitation,'b','LineWidth',3); hold on;
chdir(fullfile(fiToolboxRootPath,'data','Monici'));
FAD = fiReadFluorophore('FAD.mat','wave',theseWaves); 
plot(theseWaves,FAD.excitation,'g','LineWidth',3); hold on;
chdir(fullfile(fiToolboxRootPath,'data','webfluor'));
FAD = fiReadFluorophore('FAD.mat','wave',theseWaves); 
plot(theseWaves,FAD.excitation,'r:','LineWidth',3); hold on;
legend('Deal et al 2019', 'Monici 2005', 'DaCosta et al 2003');
title('FAD Excitation');
ax = gca;
ax.FontSize=16;
xlabel('Wavelength (nm)');
% x = [385,385]; y = [0,1]; plot(x,y,'k--','LineWidth',3);

% Collagen
ieNewGraphWin; 
% Deal et al 2018 does not have a "real" maximum
% chdir(fullfile(fiToolboxRootPath,'data','OtherSources'));
% collagenExcitation = ieReadSpectra('collagen_excitation_DealEtAl2018.mat',theseWaves); 
% plot(theseWaves,collagenExcitation,'b'); hold on;
chdir(fullfile(fiToolboxRootPath,'data','Monici'));
collagen = fiReadFluorophore('Collagen.mat','wave',theseWaves); 
plot(theseWaves,collagen.excitation,'g','LineWidth',3); hold on;
chdir(fullfile(fiToolboxRootPath,'data','webfluor'));
collagen = fiReadFluorophore('collagen1.mat','wave',theseWaves); 
plot(theseWaves,collagen.excitation,'r:','LineWidth',3); hold on;
legend('Monici 2005', 'DaCosta et al 2003');
title('Collagen Excitation');
ax = gca;
ax.FontSize=16;
xlabel('Wavelength (nm)');
% x = [385,385]; y = [0,1]; plot(x,y,'k--','LineWidth',3);

% Elastin
ieNewGraphWin; 
% Deal et al 2018 does not have a "real" maximum
% chdir(fullfile(fiToolboxRootPath,'data','OtherSources'));
% elastinExcitation = ieReadSpectra('elastin_excitation_DealEtAl2018.mat',theseWaves); 
% plot(theseWaves,collagenExcitation,'b'); hold on;
chdir(fullfile(fiToolboxRootPath,'data','Monici'));
elastin = fiReadFluorophore('Elastin.mat','wave',theseWaves); 
plot(theseWaves,elastin.excitation,'g','LineWidth',3); hold on;
chdir(fullfile(fiToolboxRootPath,'data','webfluor'));
elastin = fiReadFluorophore('elastin.mat','wave',theseWaves); 
plot(theseWaves,elastin.excitation,'r:','LineWidth',3); hold on;
legend('Monici 2005', 'DaCosta et al 2003');
title('Elastin Excitation');
ax = gca;
ax.FontSize=16;
xlabel('Wavelength (nm)');
% x = [385,385]; y = [0,1]; plot(x,y,'k--','LineWidth',3);

% Porphyrins
ieNewGraphWin; 
PorphyrinsExcitation = ieReadSpectra('porphyrins_excitation_DealEtAl2018.mat',theseWaves); 
plot(theseWaves,PorphyrinsExcitation,'b','LineWidth',3); hold on;
chdir(fullfile(fiToolboxRootPath,'data','Monici'));
Porphyrins = fiReadFluorophore('Porphyrins.mat','wave',theseWaves); 
plot(theseWaves,Porphyrins.excitation,'g','LineWidth',3); hold on;
chdir(fullfile(fiToolboxRootPath,'data','webfluor'));
Porphyrins = fiReadFluorophore('protoporphyrin.mat','wave',theseWaves); 
plot(theseWaves,Porphyrins.excitation,'r:','LineWidth',3); hold on;
legend('Deal et al 2019', 'Monici 2005', 'DaCosta et al 2003');
title('Porphyrins Excitation');
ax = gca;
ax.FontSize=16;
xlabel('Wavelength (nm)');
% x  = [385,385]; y = [0,1]; plot(x,y,'k--','LineWidth',3);

% Keratin -  
% Note that we measured Keratin powder fluorescence
% in Tulio Valdez's laboratory for 405 and 425 nm illumination
% i.e. 405 and 425 were excitation wavelengths for keratin powder
% fluorescence
% This means that we are not confident about these EEMs, particularly for
% keratin
ieNewGraphWin; 
chdir(fullfile(fiToolboxRootPath,'data','Keratin'));
Keratin = fiReadFluorophore('Keratin_WuandQu.mat','wave',theseWaves); 
plot(theseWaves,Keratin.excitation,'g','LineWidth',3); hold on;
chdir(fullfile(fiToolboxRootPath,'data','webfluor'));
Keratin = fiReadFluorophore('Keratin.mat','wave',theseWaves);
plot(theseWaves,Keratin.excitation,'r:','LineWidth',3); hold on;
legend('Wu & Qu 2006','DaCosta et al 2003');
title('Keratin Excitation');
ax = gca;
ax.FontSize=16;
xlabel('Wavelength (nm)');

%% Plot Emission 
% The amount of light emitted as a function of excitation wavelength

% NADH
ieNewGraphWin;
NADHEmission = ieReadSpectra('NADPH_emission_PaleroEtAl2007.mat',theseWaves); 
plot(theseWaves,NADHEmission,'b','LineWidth',3); hold on;
chdir(fullfile(fiToolboxRootPath,'data','Monici'));
NADH = fiReadFluorophore('NADH.mat','wave',theseWaves); 
plot(theseWaves,NADH.emission,'g','LineWidth',3); hold on;
chdir(fullfile(fiToolboxRootPath,'data','webfluor'));
NADH = fiReadFluorophore('NADH.mat','wave',theseWaves); 
plot(theseWaves,NADH.emission,'r:','LineWidth',3); hold on;
legend('Palero Et al 2007', 'Monici 2005', 'DaCosta et al 2003');
title('NADH Emission');
ax = gca;
ax.FontSize=16;
xlabel('Wavelength (nm)');

% FAD
ieNewGraphWin;
FADEmission = ieReadSpectra('FAD_emission_PaleroEtAl2007.mat',theseWaves); 
plot(theseWaves,FADEmission,'b','LineWidth',3); hold on;
chdir(fullfile(fiToolboxRootPath,'data','Monici'));
FAD = fiReadFluorophore('FAD.mat','wave',theseWaves); 
plot(theseWaves,FAD.emission,'g','LineWidth',3); hold on;
chdir(fullfile(fiToolboxRootPath,'data','webfluor'));
FAD = fiReadFluorophore('FAD.mat','wave',theseWaves); 
plot(theseWaves,FAD.emission,'r:','LineWidth',3); hold on;
legend('Palero Et al 2007', 'Monici 2005', 'DaCosta et al 2003');
title('FAD Emission');
ax = gca;
ax.FontSize=16;
xlabel('Wavelength (nm)');

% collagen
ieNewGraphWin;
collagenEmission = ieReadSpectra('collagen_emission_PaleroEtAl2007.mat',theseWaves); 
plot(theseWaves,collagenEmission,'b','LineWidth',3); hold on;
chdir(fullfile(fiToolboxRootPath,'data','Monici'));
collagen = fiReadFluorophore('Collagen.mat','wave',theseWaves); 
plot(theseWaves,collagen.emission,'g','LineWidth',3); hold on;
chdir(fullfile(fiToolboxRootPath,'data','webfluor'));
collagen = fiReadFluorophore('collagen1.mat','wave',theseWaves); 
plot(theseWaves,collagen.emission,'r:','LineWidth',3); hold on;
legend('Palero Et al 2007', 'Monici 2005', 'DaCosta et al 2003');
title('Collagen Emission');
ax = gca;
ax.FontSize=16;
xlabel('Wavelength (nm)');

% elastin 
ieNewGraphWin;
elastinEmission = ieReadSpectra('elastin_emission_PaleroEtAl2007.mat',theseWaves); 
plot(theseWaves,elastinEmission,'b','LineWidth',3); hold on;
chdir(fullfile(fiToolboxRootPath,'data','Monici'));
elastin = fiReadFluorophore('Elastin.mat','wave',theseWaves); 
plot(theseWaves,elastin.emission,'g','LineWidth',3); hold on;
chdir(fullfile(fiToolboxRootPath,'data','webfluor'));
elastin = fiReadFluorophore('elastin.mat','wave',theseWaves); 
plot(theseWaves,elastin.emission,'r:','LineWidth',3); hold on;
legend('Palero Et al 2007', 'Monici 2005', 'DaCosta et al 2003');
title('Elastin Emission');
ax = gca;
ax.FontSize=16;
xlabel('Wavelength (nm)');

% Porphyrins
ieNewGraphWin;
chdir(fullfile(fiToolboxRootPath,'data','Monici'));
Porphyrins = fiReadFluorophore('Porphyrins.mat','wave',theseWaves); 
plot(theseWaves,Porphyrins.emission,'g','LineWidth',3); hold on;
chdir(fullfile(fiToolboxRootPath,'data','webfluor'));
Porphyrins= fiReadFluorophore('protoporphyrin.mat','wave',theseWaves); 
plot(theseWaves,Porphyrins.emission,'r:','LineWidth',3); hold on;
legend('Monici 2005', 'DaCosta et al 2003');
title('Porphyrin Emission');
ax = gca;
ax.FontSize=16;
xlabel('Wavelength (nm)');

% Keratin - 
% not sure why the emission data are the same - check this
ieNewGraphWin;
chdir(fullfile(fiToolboxRootPath,'data','Keratin'));
Keratin = fiReadFluorophore('Keratin.mat','wave',theseWaves); 
plot(theseWaves,Keratin.emission,'g','LineWidth',3); hold on;
chdir(fullfile(fiToolboxRootPath,'data','webfluor'));
Keratin = fiReadFluorophore('Keratin.mat','wave',theseWaves); 
plot(theseWaves,Keratin.emission,'r:','LineWidth',3); 
legend('Wu & Qu 2006','DaCosta et al 2003');
title('Keratin Emission');
ax = gca;
ax.FontSize=16;
xlabel('Wavelength (nm)');


