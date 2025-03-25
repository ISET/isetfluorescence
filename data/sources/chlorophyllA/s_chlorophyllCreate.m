%% s_chlorophyllCreate

%%
ieInit;

%% ChlorophyllA

wave = 350:760;

emission = ieReadSpectra('chlorophyllA_emission',wave);

chlorophyllAF = fluorophoreCreate('type','custom',...
    'name','chlorophyllA',...
    'solvent','none', ...
    'wave', wave, ...
    'excitation',ones(size(wave)),...
    'emission',emission);

comment = 'See s_wagnieresCreate. Only emission data provided.';
savePath = fullfile(fiToolboxRootPath,'data','chlorophyllA','chlorophyllA');
fiSaveFluorophore(savePath, chlorophyllAF);

%{
pF = fiReadFluorophore('chlorophyllA');
fluorophorePlot(pF,'eem');
%}
%%