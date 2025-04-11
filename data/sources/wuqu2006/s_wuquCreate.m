%% s_wuquCreate
%
% We have the EEM matrices for collagen and keratin.  To build those, run
% 
%    s_collagenEEMCreate 
%    s_keratinEEMCreate
%
% This script creates FADWuQu and NADHWuQu
%

%%
ieInit;
wave = 380:800;

%% FAD
%
% For this and NADH we have only a single emission function

[emission,~,comment] = ieReadSpectra('FAD_WuQu2006',wave);
comment = addText(sprintf('See s_wuquCreate.\n'), comment);

FADF = fluorophoreCreate('type','custom',...
    'name','FAD',...
    'solvent','none', ...
    'wave', wave, ...
    'excitation',ones(size(wave)),...
    'emission',emission, ...
    'comment',comment);

savePath = fullfile(fiToolboxRootPath,'data','WuQu2006','FADWuQu');
fiSaveFluorophore(savePath, FADF);

%{
tmp = fiReadFluorophore('FADWuQu','wave',wave);
fluorophorePlot(tmp,'emission');
tmp.comment
%}
%% NADH

[emission,~,comment] = ieReadSpectra('NADH_WuQu2006',wave);
comment = addText(sprintf('See s_wuquCreate.\n'), comment);

NADHF = fluorophoreCreate('type','custom',...
    'name','NADH',...
    'solvent','none', ...
    'wave', wave, ...
    'excitation',ones(size(wave)),...
    'emission',emission, ...
    'comment',comment);

savePath = fullfile(fiToolboxRootPath,'data','WuQu2006','NADHWuQu');
fiSaveFluorophore(savePath, NADHF);

%{
 tmp = fiReadFluorophore('NADHWuQu','wave',wave);
 fluorophorePlot(tmp,'emission');
%}

%%


