%% s_linCreate
%
%  We only have emissions from Lin 2022. So we are making up kind of a
%  dummy fluorescence structure.

%%
ieInit;
wave = 380:800;

%% FAD
[emission, ~ , comment] = ieReadSpectra('FAD_emissions_Lin',wave);
comment = addText('See s_linCreate. Only emission data provided.  Excitation was 365nm',comment);

FADF = fluorophoreCreate('type','custom',...
    'name','FAD',...
    'solvent','none', ...
    'wave', wave, ...
    'excitation',ones(size(wave)),...
    'emission',emission, ...
    'comment',comment);

savePath = fullfile(fiToolboxRootPath,'data','Lin2022','FADLin');
fiSaveFluorophore(savePath, FADF);

%% Collagen
[emission, ~ , comment] = ieReadSpectra('collagen_emissions_Lin',wave);

collagenF = fluorophoreCreate('type','custom',...
    'name','collagen',...
    'solvent','none', ...
    'wave', wave, ...
    'excitation',ones(size(wave)),...
    'emission',emission,...
    'comment',comment);

savePath = fullfile(fiToolboxRootPath,'data','Lin2022','CollagenLin');
fiSaveFluorophore(savePath, collagenF);

%% NADH

emission = ieReadSpectra('NADH_emissions_Lin',wave);

NADHF = fluorophoreCreate('type','custom',...
    'name','NADH',...
    'solvent','none', ...
    'wave', wave, ...
    'excitation',ones(size(wave)),...
    'emission',emission, ...
    'comment',comment);

savePath = fullfile(fiToolboxRootPath,'data','Lin2022','NADHLin');
fiSaveFluorophore(savePath, NADHF);

%%