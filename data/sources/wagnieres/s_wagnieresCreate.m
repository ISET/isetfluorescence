%% s_wagnieresCreate

%%
ieInit;

%% Porphyrin

wave = 350:760;

emission = ieReadSpectra('porphyrins_emission_Wagnieres',wave);
excitation = ieReadSpectra('porphyrins_excitation_Wagnieres',wave);

porphyrinF = fluorophoreCreate('type','custom',...
    'name','porphyrin',...
    'solvent','none', ...
    'wave', wave, ...
    'excitation',excitation,...
    'emission',emission);

comment = 'See s_wagnieresCreate. Only emission data provided.';
savePath = fullfile(fiToolboxRootPath,'data','Wagnieres','PorphyrinWagnieres');
fiSaveFluorophore(savePath, porphyrinF);

%{
pF = fiReadFluorophore('PorphyrinWagnieres');
fluorophorePlot(pF,'eem');
%}
%%