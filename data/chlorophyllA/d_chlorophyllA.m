%% d_chlorophyllA
%
% Shifting the chlorophyll emission
chl      = fiReadFluorophore('chlorophyllA');
wave     = fluorophoreGet(chl,'wave');
emission = fluorophoreGet(chl,'emission');

plotRadiance(wave,emission);

%% Shift it some number of nm longer
n = numel(emission);
shiftSize = 7;    % Shift this many nanometers to the right
k = zeros(1,51);
k(26+shiftSize) = 1;
tmp = conv(emission,k,'same');
ieFigure; plot(wave,tmp,'k-',wave,emission,'r-');

%% 
chlS = fluorophoreSet(chl,'emission',tmp);
fname = sprintf('chlorophyllA-%d',shiftSize);
chlS = fluorophoreSet(chlS,'name',fname);
chlS = fluorophoreSet(chlS,'comment','See d_chlorophyllA for the shift method.');

fullpathName = fullfile(fiToolboxRootPath,'data','chlorophyllA',fname);

fluorophoreSave(fullpathName,chlS,'See d_chlorophyllA for the shift method.');

%% Compare the original and shifted

ieFigure;
chlShifted = fiReadFluorophore(fname);
chl = fiReadFluorophore('chlorophyllA');
e1 = fluorophoreGet(chlShifted,'emission');
e2 = fluorophoreGet(chl,'emission');
plot(wave,e1,'k-',wave,e2,'r-');
grid on;
legend({'shifted','original'});

%%