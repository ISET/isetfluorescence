%% s_chlorophyllCreate

%%
ieInit;

%% ChlorophyllA

wave = 350:760;

emission = ieReadSpectra('chlorophyllA_emission.mat',wave);
excitation = ieReadSpectra('chlorophyllA_absorption.mat',wave);

chlorophyllAF = fluorophoreCreate('type','custom',...
    'name','chlorophyllA',...
    'solvent','none', ...
    'wave', wave, ...
    'excitation',excitation,...
    'emission',emission);

savePath = fullfile(fiToolboxRootPath,'data','chlorophyllA','chlorophyllA');
fiSaveFluorophore(savePath, chlorophyllAF);

%{
pF = fiReadFluorophore('chlorophyllA');
fluorophorePlot(pF,'eem');
%}
%%