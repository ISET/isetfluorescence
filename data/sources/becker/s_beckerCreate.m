%% s_beckerCreate

ieInit;

%% FAD

wave = 490:700;
emission = ieReadSpectra('FAD_emission_Becker',wave);

FADF = fluorophoreCreate('type','custom',...
    'name','FAD',...
    'solvent','none', ...
    'wave', wave, ...
    'excitation',ones(size(wave)),...
    'emission',emission);

comment = 'See s_beckerCreate. Only emission data provided.';
savePath = fullfile(fiToolboxRootPath,'data','Becker','FADBecker');
fiSaveFluorophore(savePath, FADF);

%%