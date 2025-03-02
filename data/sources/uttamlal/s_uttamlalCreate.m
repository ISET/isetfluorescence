%% s_uttamlalCreate

%%
ieInit;

%% Porphyrin

wave = 350:760;
emission = ieReadSpectra('porphyrins_emissions_Uttamlal',wave);
excitation = ieReadSpectra('porphyrins_excitation_Uttamlal',wave);

porphyrinF = fluorophoreCreate('type','custom',...
    'name','porphyrin',...
    'solvent','none', ...
    'wave', wave, ...
    'excitation',excitation,...
    'emission',emission);

comment = 'See s_uttamlalCreate. Only emission data provided.';
savePath = fullfile(fiToolboxRootPath,'data','Uttamlal','PorphyrinUttamlal');
fiSaveFluorophore(savePath, porphyrinF);

%{
pF = fiReadFluorophore('PorphyrinSudhakar');
fluorophorePlot(pF,'eem');
%}
%%