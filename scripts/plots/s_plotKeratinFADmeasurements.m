s_plotKeratinFADmeasurements.m

%% make sure these libraries are on your path
%{
cd /Users/joyce/Github/isetcam;
addpath(genpath(pwd));
cd /Users/joyce/Github/isetfluorescence;
addpath(genpath(pwd));
cd /users/joyce/Github/oraleye/;
addpath(genpath(pwd));
%}

ieInit;

wave = 350:4:750;
nWaves = numel(wave);

%% First read in the fluorophore emission measurements

Keratin_405= ieReadSpectra('Keratin_405light_425filter.mat',wave);
Keratin_450= ieReadSpectra('Keratin_450light_475filter.mat',wave);
Keratin_520= ieReadSpectra('Keratin_520light_550filter.mat',wave);

FAD_405= ieReadSpectra('FAD_405light_425filter.mat',wave);
FAD_450= ieReadSpectra('FAD_450light_475filter.mat',wave);
FAD_520= ieReadSpectra('FAD_520light_550filter.mat',wave);

%% Plot the data
ieNewGraphWin;
plot(wave,Keratin_405,'b','LineWidth',2); hold on;
plot(wave,Keratin_450,'g','LineWidth',2);
plot(wave,Keratin_520,'r','LineWidth',2); 
title('Keratin powder')'
legend('405','450', '520');
ax = gca;
ax.FontSize = 14;
ylabel('Energy (watts/nm/sr/m^2/sec');
xlabel('Wavelength (nm)');

ieNewGraphWin;
plot(wave,FAD_405,'b','LineWidth',2); hold on; hold on;
plot(wave,FAD_450,'g','LineWidth',2); hold on;
plot(wave,FAD_520,'r','LineWidth',2); hold on;
title('FAD powder')'
legend('405','450', '520');
ax = gca;
ax.FontSize = 14;
ylabel('Energy (watts/nm/sr/m^2/sec');
xlabel('Wavelength (nm)');

%% Scale and plot with filters

LP425 = ieReadSpectra('LongPassFilter425',wave)
LP475 = ieReadSpectra('LongPassFilter475',wave);
LP550 = ieReadSpectra('LongPassFilter550',wave);

ieNewGraphWin;
plot(wave,Keratin_405/max(Keratin_405(:)),'b','LineWidth',2); hold on;
plot(wave,Keratin_450/max(Keratin_450(:)),'g','LineWidth',2);
plot(wave,Keratin_520/max(Keratin_520(:)),'r','LineWidth',2);
plot(wave,LP425/LP425(22),'b--','LineWidth',2);
plot(wave,LP475/LP475(34),'g--','LineWidth',2);
plot(wave,LP550/LP550(56),'r--','LineWidth',2);
title('Keratin powder')'
legend('405','450', '520','LP425', 'LP450','LP520')
ax = gca;
ax.FontSize = 14;
ylabel('Energy (watts/nm/sr/m^2/sec');
xlabel('Wavelength (nm)');

ieNewGraphWin; 
plot(wave,FAD_405/max(FAD_405(:)),'b','LineWidth',2); hold on;
plot(wave,FAD_450/max(FAD_450(:)),'g','LineWidth',2);
plot(wave,FAD_520/max(FAD_520(:)),'r','LineWidth',2);
plot(wave,LP425/LP425(101),'b--','LineWidth',2);
plot(wave,LP475/LP475(101),'g--','LineWidth',2);
plot(wave,LP550/LP550(101),'r--','LineWidth',2);
ylim([0,1]);
title('FAD powder')'
legend('405','450', '520','LP425', 'LP450','LP520')
ax = gca;
ax.FontSize = 14;
ylabel('Energy (watts/nm/sr/m^2/sec');
xlabel('Wavelength (nm)');