%% s_sudhakarCreate

%%
ieInit;

%% Porphyrin

wave = 350:760;
emission = ieReadSpectra('porphyrins_emission_Sudhakar',wave);
excitation = ieReadSpectra('porphyrins_excitation_Sudhakar',wave);

porphyrinF = fluorophoreCreate('type','custom',...
    'name','porphyrin',...
    'solvent','none', ...
    'wave', wave, ...
    'excitation',excitation,...
    'emission',emission);

comment = 'See s_sudhakarCreate. Only emission data provided.';
savePath = fullfile(fiToolboxRootPath,'data','Sudhakar','PorphyrinSudhakar');
fiSaveFluorophore(savePath, porphyrinF);

%{
pF = fiReadFluorophore('PorphyrinSudhakar');
fluorophorePlot(pF,'eem');
%}
%%