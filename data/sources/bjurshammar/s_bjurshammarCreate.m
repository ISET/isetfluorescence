%% s_bjurshammarCreate

%%
ieInit;

%% Porphyrin

wave = 600:760;
emission = ieReadSpectra('porphyrins_emission_bjurshammar',wave);

porphyrinF = fluorophoreCreate('type','custom',...
    'name','FAD',...
    'solvent','none', ...
    'wave', wave, ...
    'excitation',ones(size(wave)),...
    'emission',emission);

comment = 'See s_fjurshammarCreate. Only emission data provided.';
savePath = fullfile(fiToolboxRootPath,'data','Bjurshammar','PorphyrinBjurshammar');
fiSaveFluorophore(savePath, porphyrinF);

%{
pF = fiReadFluorophore('PorphyrinBjurshammar');
fluorophorePlot(pF,'eem');
%}
%%