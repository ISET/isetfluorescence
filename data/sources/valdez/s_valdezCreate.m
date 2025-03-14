%% s_valdezCreate
%
%  Data from power by Joyce and Stella
% 

%%
ieInit;
wave = 380:800;

%% FAD

% The three excitation files are all similar.  This one has the best
% SNR because 450nm is the peak excitation wavelength.
% The blocking filter is irrelevant because there is very little or no
% signal up to 475nm.
[emission,~,comment] = ieReadSpectra('FAD_450light_475filter',wave);
comment = addText(sprintf('See s_valdezCreate.\n'), comment);

FADF = fluorophoreCreate('type','custom',...
    'name','FAD',...
    'solvent','none', ...
    'wave', wave, ...
    'excitation',ones(size(wave)),...
    'emission',emission, ...
    'comment',comment);

savePath = fullfile(fiToolboxRootPath,'data','Valdez','FADValdez');
fiSaveFluorophore(savePath, FADF);

%{
tmp = fiReadFluorophore('FADValdez','wave',wave);
fluorophorePlot(tmp,'emission');
tmp.comment
%}
%% Keratin

[emission,~,comment] = ieReadSpectra('Keratin_405light_425filter',wave);
comment = addText(sprintf('See s_valdezCreate.\n'), comment);

keratinF = fluorophoreCreate('type','custom',...
    'name','keratin',...
    'solvent','none', ...
    'wave', wave, ...
    'excitation',ones(size(wave)),...
    'emission',emission, ...
    'comment',comment);

savePath = fullfile(fiToolboxRootPath,'data','Valdez','KeratinValdez');
fiSaveFluorophore(savePath, keratinF);

%{
 tmp = fiReadFluorophore('KeratinValdez','wave',wave);
 fluorophorePlot(tmp,'emission');
%}
%%