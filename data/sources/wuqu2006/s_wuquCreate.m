%% s_wuquCreate
%
% We no longer trust the EEM matrices for collagen and keratin. These
% scripts have now been deprecated:    
%
%    s_collagenEEMCreate 
%    s_keratinEEMCreate
%
% This script creates all of the fluorophores, without any EEM.  Just a 1d
% fluorophore emission.
%

%%
ieInit;
wave = 380:800;

%% Collagen

filePath355 = which('collagen_355nm.mat');
emission = ieReadSpectra(filePath355, wave);
emission = emission / max(emission);

comment = sprintf('Using collagen 355 as the emission.  See s_wuquCreate.');

collagenF = fluorophoreCreate('type','custom',...
    'name','collagen',...
    'solvent','none', ...
    'wave', wave, ...
    'excitation',ones(size(wave)),...
    'emission',emission, ...
    'comment',comment);

savePath = fullfile(fiToolboxRootPath,'data','WuQu2006','CollagenWuQu');
fiSaveFluorophore(savePath, collagenF);

%% Keratin

filePath355 = which('Keratin_355nm.mat');
emission = ieReadSpectra(filePath355, wave);
emission = emission / max(emission);

comment = sprintf('Using kertain 355 as the emission.  See s_wuquCreate.');

keratinF = fluorophoreCreate('type','custom',...
    'name','keratin',...
    'solvent','none', ...
    'wave', wave, ...
    'excitation',ones(size(wave)),...
    'emission',emission, ...
    'comment',comment);

savePath = fullfile(fiToolboxRootPath,'data','WuQu2006','KeratinWuQu');
fiSaveFluorophore(savePath, keratinF);

fluorophorePlot(keratinF,'emission', ...
    'line color','r'); 
ieFigure; plotRadiance(wave,emission);

%% FAD
%
% For this and NADH we have only a single emission function

[emission,~,comment] = ieReadSpectra('FAD_WuQu2006',wave);
emission = emission / max(emission);

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
emission = emission / max(emission);

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

%% Have a look at all four of them

tmp = fiReadFluorophore('FADWuQu','wave',wave);
hdl = fluorophorePlot(tmp,'emission',...
    'linecolor','k', ...
    'normalize',true); hold on;

tmp = fiReadFluorophore('NADHWuQu','wave',wave);
fluorophorePlot(tmp,'emission','fighdl',hdl, ...
    'line color','r'); hold on;

% Note that Collagen and Keratin are virtually identical emissions.  The
% only way we can tell them apart is if one is determined by blood
% (collagen) and the other is not (Keratin).
tmp = fiReadFluorophore('CollagenWuQu','wave',wave);
fluorophorePlot(tmp,'emission',...
    'excitation wave', 355, ...
    'normalize',true, ...
    'fighdl',hdl, ...
    'line color','b');

tmp = fiReadFluorophore('KeratinWuQu','wave',wave);
fluorophorePlot(tmp,'emission',...
    'excitation wave', 355, ...
    'fighdl',hdl, 'line color','g');

legend('FAD','NADH','Collagen','Keratin')

%%

tmp = fiReadFluorophore('CollagenWuQu','wave',wave);
fluorophorePlot(tmp,'eem image');
