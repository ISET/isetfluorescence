% This script uses the CIM (fiReflAndEm) reflectance and fluorescence
% emission estimation algorithm to estimate the surface properties of a
% real test target: Macbeth test chart with overlaid with fluorescence
% slides. 
%
% Copyright, Henryk Blasinski 2016

close all;
clear variables;
clc;

ieInit;

%%

nSamples = 24;

nReflBasis = 5;
nEmBasis = 12;

alpha = 0.1;
beta = 0.2;

testFileName = 'Macbeth+Fl';
backgroundFileName = 'Background';

% Save data to file if saveFName ~= []
dirName = fullfile(fiToolboxRootPath,'results','experiments');
if ~exist(dirName,'dir'), mkdir(dirName); end;
% saveFName = fullfile(dirName,sprintf('em_%s.mat',testFileName));
saveFName = [];

wave = 380:4:1000;
deltaL = wave(2) - wave(1);
nWaves = length(wave);

% Load the light spectra (in photons). We scale by the maximum for
% numerical stability. This does not matter in the long run as we are
% calibrating for an unknown gain paramter.
fName = fullfile(fiToolboxRootPath,'camera','illuminants');
illuminant = ieReadSpectra(fName,wave);
illuminantPhotons = Energy2Quanta(wave,illuminant);
illuminantPhotons = illuminantPhotons/max(illuminantPhotons(:));

nChannels = size(illuminant,2);

% Load camera spectral properties
fName = fullfile(fiToolboxRootPath,'camera','filters');
filters = ieReadSpectra(fName,wave);

fName = fullfile(fiToolboxRootPath,'camera','qe');
qe = ieReadSpectra(fName,wave);

camera = diag(qe)*filters;
nFilters = size(camera,2);


% Load the test target reflectance
fName = fullfile(fiToolboxRootPath,'data','macbethChart');
reflRef = ieReadSpectra(fName,wave);

fName = fullfile(fiToolboxRootPath,'data','redFlTransmittance');
redTr = ieReadSpectra(fName,wave);

fName = fullfile(fiToolboxRootPath,'data','greenFlTransmittance');
greenTr = ieReadSpectra(fName,wave);

reflRef(:,[1:4:nSamples 2:4:nSamples]) = diag(greenTr)*reflRef(:,[1:4:nSamples 2:4:nSamples]);
reflRef(:,[3:4:nSamples 4:4:nSamples]) = diag(redTr)*reflRef(:,[3:4:nSamples 4:4:nSamples]);

% Generate basis function sets

% Use the reflectance corrected for transmittance to derive basis
% functions.
reflBasis = pca(reflRef','centered',false);
reflBasis = reflBasis(:,1:nReflBasis);
% Or use generic basis functions, the difference is minimal
% reflBasis = fiCreateBasisSet('reflectance','wave',wave','n',nReflBasis);

emBasis = fiCreateBasisSet('emission','wave',wave','n',nEmBasis);


% These values are the measured ground truth data.
flQe = [0.25 0.53];

% Load fluorescence data and get reference spectra
fName = fullfile(fiToolboxRootPath,'data','redFl');
redFl = fiReadFluorophore(fName,'wave',wave);

fName = fullfile(fiToolboxRootPath,'data','greenFl');
greenFl = fiReadFluorophore(fName,'wave',wave);

fluorophores = [greenFl; redFl];
flScene = fluorescentSceneCreate('type','fromfluorophore','fluorophore',fluorophores,'wave',wave,'qe',flQe);

dMatRef = fluorescentSceneGet(flScene,'donaldsonReference','sceneSize',[4 6]);
exRef = fluorescentSceneGet(flScene,'excitationReference','sceneSize',[4 6]);
emRef = fluorescentSceneGet(flScene,'emissionReference','sceneSize',[4 6]);



%% Calibration
% The whole linear image formation model has an unknown gain parameter, we
% are computing this gain for every pixel by taking an image of a white
% surface with a known reflectance. The gain is just the result of the
% division between pixel intensities and linear model predictions.

% Predict the response of a target surface
prediction = deltaL*((camera')*illuminantPhotons);

% Generate the gain map for every pixel
fName = fullfile(fiToolboxRootPath,'data','experiments',backgroundFileName);
[~, ~, scaledRAW, shutterBackground] = fiReadImageStack(fName);
hh = size(scaledRAW,1);
ww = size(scaledRAW,2);

% For every illuminant channel and the monochromatic filter pick a
% reference point (say in the middle). Compute how would you need to scale
% other pixels so that the image intensity is uniform. We are using the
% monochromatic channel for the computations and then using the same map
% across all the channels
refPt = scaledRAW(hh/2,ww/2,1,:);
refImg = repmat(refPt,[hh ww 1 1]);
scaleMap = refImg./scaledRAW(:,:,1,:);
scaleMap = repmat(scaleMap,[1 1 nFilters 1]);

nonuniformityCorrected = scaledRAW.*scaleMap;

% Now for each channel compute the gain parameter, that represents the
% precise value of the light intensity.
avgIntensity = squeeze(mean(mean(nonuniformityCorrected(:,:,1,:),1),2));
gains = avgIntensity'./prediction(1,:);

% Assume that the light intensity is constant, we can apply the same gain
% to different camera filters.
cameraGain = repmat(gains,[nFilters, 1, nSamples]);
cameraOffset = zeros([nFilters, nChannels, nSamples]);
[reflValsRef, flValsRef] = fiComputeReflFlContrib(camera,illuminantPhotons,cameraGain(:,:,1)*deltaL,reflRef,dMatRef);


%% Extract data from a Macbeth image
fName = fullfile(fiToolboxRootPath,'data','experiments',testFileName);
[~, ~, scaledMacbeth, shutterMacbeth] = fiReadImageStack(fName);
linearVals = scaledMacbeth.*scaleMap;

% Read the sensor data
cp = [28 873;1262 919;1271 138;58 74];
measVals = zeros(nFilters,nChannels,nSamples);
for f=1:nFilters
    sensor = createCameraModel(f);

    for i=1:nChannels
       
        sensor = sensorSet(sensor,'volts',linearVals(:,:,f,i));
        ieAddObject(sensor);

        if isempty(cp)
            sensorWindow('scale',1);
            [tmp, ~, ~, cp] = macbethSelect(sensor,1,1,cp);
        else
            [tmp, ~, ~, cp] = macbethSelect(sensor,0,1,cp);
        end
        measVals(f,i,:) = cellfun(@(x) mean(x(~isnan(x) & ~isinf(x))),tmp);
    end 
end

% Normalize the measured pixel intensities, so that the maxium for each 
% patch is 1. To preserve the image formation model we need to scale camera
% gains accordingly.
nF = max(max(measVals,[],1),[],2);
nF = repmat(nF,[nFilters nChannels 1]);
measVals = measVals./nF;
cameraGain = cameraGain./nF;


%% Estimate the reflectance and single fluorescence


[ reflEst, reflCoeffs, emEst, emCoeffs, emWghts, reflValsEst, flValsEst, hist  ] = ...
    fiRecReflAndEm( measVals, camera, cameraGain*deltaL, cameraOffset,...
    illuminantPhotons, reflBasis, emBasis, alpha, beta, 'maxIter', 20);

if ~isempty(saveFName)
    save(saveFName,'reflEst','reflCoeffs','emEst','emCoeffs','emWghts','reflValsEst','flValsEst','hist',...
        'wave','alpha','beta','reflRef','exRef','emRef','measVals');
end

measValsEst = reflValsEst + flValsEst;

fprintf('Total time %f, per sample %f, per iteration %f\n',sum(cellfun(@(x) sum(x.computeTime),hist)),mean(cellfun(@(x) sum(x.computeTime),hist)),mean(cellfun(@(x) mean(x.computeTime),hist)));

[err, std] = fiComputeError(reshape(measValsEst,[nChannels*nFilters,nSamples]), reshape(measVals - cameraOffset,[nChannels*nFilters,nSamples]), 'absolute');
fprintf('Total pixel error %.3f, std %.3f\n',err,std);

[err, std] = fiComputeError(reshape(reflValsEst,[nChannels*nFilters,nSamples]), reshape(reflValsRef,[nChannels*nFilters,nSamples]), 'absolute');
fprintf('Reflected pixel error %.3f, std %.3f\n',err,std);

[err, std] = fiComputeError(reshape(flValsEst,[nChannels*nFilters,nSamples]), reshape(flValsRef,[nChannels*nFilters,nSamples]), 'absolute');
fprintf('Fluoresced pixel error %.3f, std %.3f\n',err,std);

[err, std] = fiComputeError(reflEst, reflRef, 'absolute');
fprintf('Reflectance error %.3f, std %.3f\n',err,std);

[err, std] = fiComputeError(emEst, emRef, 'absolute');
fprintf('Emission error %.3f, std %.3f\n',err,std);

[err, std] = fiComputeError(emEst, emRef, 'normalized');
fprintf('Emission error (normalized) %.3f, std %.3f\n',err,std);


%% Plot the results

figure;
hold all; grid on; box on;
plot(measValsEst(:),measVals(:),'.');
xlabel('Model predicted pixel value');
ylabel('ISET pixel value');

% Convergence
figure;
for xx=1:6
for yy=1:4

    plotID = (yy-1)*6 + xx;
    sampleID = (xx-1)*4 + yy;

    subplot(4,6,plotID);
    hold all; grid on; box on;
    plot([hist{sampleID}.objValsReEm, hist{sampleID}.objValsReWe],'LineWidth',2);
    

end
end


% Estimated vs. ground truth reflectance
figure;
for xx=1:6
for yy=1:4

    plotID = (yy-1)*6 + xx;
    sampleID = (xx-1)*4 + yy;

    subplot(4,6,plotID);
    hold all; grid on; box on;
    plot(wave,reflEst(:,sampleID),'g','LineWidth',2);
    plot(wave,reflRef(:,sampleID),'b--','LineWidth',2);
    xlim([min(wave) max(wave)]);
    ylim([-0.05 1.05]);

    rmse = sqrt(mean((reflEst(:,sampleID) - reflRef(:,sampleID)).^2));
    title(sprintf('RMSE %.2f',rmse));

end
end

% Estimated vs. ground truth emission

maxVal = max([emEst(:); emRef(:)]);
figure;
for xx=1:6
for yy=1:4

    plotID = (yy-1)*6 + xx;
    sampleID = (xx-1)*4 + yy;

    subplot(4,6,plotID);
    hold all; grid on; box on;
    plot(wave,emEst(:,sampleID),'m','LineWidth',2);
    plot(wave,emRef(:,sampleID),'b--','LineWidth',2);
    xlim([min(wave) max(wave)]);
    ylim([0.0 1.05*maxVal]);

    rmse = sqrt(mean((emEst(:,sampleID) - emRef(:,sampleID)).^2));
    title(sprintf('RMSE %.2f',rmse));

end
end




