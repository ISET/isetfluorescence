% s_keratinPenaCreate
%
% 

%% Load the excitation emission.

[emission,dwave1] = ieReadSpectra('KeratinEmissions_PenaEtAl2005');
w1 = min(dwave1); w2 = max(dwave1);
[excitation,dwave2] = ieReadSpectra('KeratinExcitation_PenaEtAl2005');
w1 = min(w1,min(dwave2(:))); w2 = max(w2,max(dwave2(:)));
wave = round(w1):round(w2);
emission = interp1(dwave1,emission,wave);
excitation = interp1(dwave2,excitation,wave);

%% Create the fluorophore struct

keratinF = fluorophoreCreate('type','custom',...
    'name','keratin',...
    'solvent','none', ...
    'wave', wave, ...
    'excitation',excitation,...
    'emission',emission); 
%{
fluorophorePlot(keratinF,'eem');
fluorophorePlot(keratinF,'eem wave','excitation wave',420);
fluorophorePlot(keratinF,'excitation');
fluorophorePlot(keratinF,'emission');
%}

%% Save
comment = 'See s_keratinPenaCreate. Excitation/Emission from Pena 2005.';
savePath = fullfile(fiToolboxRootPath,'data','Pena2005','KeratinPena');
fiSaveFluorophore(savePath, keratinF);