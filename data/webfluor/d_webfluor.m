%% Unrealistic ripples in the original collagen1 data beyond 600nm.
%
% We smoothed the ripples away using sgolayfilt.
%

collagen = fluorophoreRead('collagen1');
wave = fluorophoreGet(collagen,'wave');
emission = fluorophoreGet(collagen,'emission');

ieFigure;
plot(wave,emission); hold on;

poly_order  = 3;
window_size = 13;
S_smooth = sgolayfilt(emission, poly_order, window_size);
ieFigure;
plot(wave,S_smooth,'k-');
grid on;

collagen = fluorophoreSet(collagen,'emission',S_smooth);
collagen = fluorophoreSet(collagen,'name','collagen1-smooth');
comment  = sprintf('Fit with sgolayfilt poly_order %d window_size %d',poly_order,window_size);
collagen = fluorophoreSet(collagen,'comment',comment);

fiSaveFluorophore('collagen1-smooth',collagen);

%% Test

collagen = fluorophoreRead('collagen1-smooth');
disp(collagen.comment)

wave = fluorophoreGet(collagen,'wave');
emission = fluorophoreGet(collagen,'emission');

ieFigure;
plotRadiance(wave,emission);

%%
