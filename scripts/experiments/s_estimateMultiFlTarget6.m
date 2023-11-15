% This script uses the multi-fluorophore (fiReflAndMultiFl) reflectance and
% fluorescence emission estimation algorithm to estimate the surface 
% properties of the whole image of a natural looking test target (paper
% with symbols colored with fluorescent dyes). The original 1MP image is
% downsampled by a factor of dsFac to speed up the computation, but even
% then the computation is VERY long.
%
% Copyright, Henryk Blasinski 2016

close all;
clear variables;
clc;

ieInit;

%%

nReflBasis = 5;
nExBasis = 12;
nEmBasis = 12;

dsFac = 10; % Image downscale factor.

alpha = 0.1; %0.1
beta = 5;
eta = 0.01;
maxIter = 250;

testFileName = 'Target6';
backgroundFileName = 'Target1-white';
dirName = fullfile(fiToolboxRootPath,'results','experiments');
if ~exist(dirName,'dir'), mkdir(dirName); end;

wave = 380:4:1000;
deltaL = wave(2) - wave(1);
nWaves = length(wave);

% Create basis function sets
reflBasis = fiCreateBasisSet('reflectance','wave',wave','n',nReflBasis);
exBasis = fiCreateBasisSet('excitation','wave',wave','n',nExBasis);
emBasis = fiCreateBasisSet('emission','wave',wave','n',nEmBasis);

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


%% Calibration
% The whole linear image formation model has an unknown gain parameter, we
% are computing this gain for every pixel by taking an image of a white
% surface with a known reflectance. The gain is just the result of the
% division between pixel intensities and linear model predictions.

% Predict the response of a target surface
prediction = deltaL*((camera')*illuminantPhotons);

% Generate the gain map for every pixel
fName = fullfile(fiToolboxRootPath,'data','experiments',backgroundFileName);
[RAW, ~, scaledRAW, shutterBackground] = fiReadImageStack(fName);
hh = size(scaledRAW,1);
ww = size(scaledRAW,2);

%{
for f=1:nFilters
    figure;
    for c=1:nChannels
        subplot(4,4,c);
        imshow(RAW(:,:,f,c));
        title(sprintf('F %i, C %i',f,c))
    end
end
%}
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


%% Extract data from a Macbeth image
fName = fullfile(fiToolboxRootPath,'data','experiments',testFileName);
[RAW, ~, scaledMacbeth, shutterMacbeth] = fiReadImageStack(fName);
linearVals = scaledMacbeth.*scaleMap;
%{
for f=1:nFilters
    figure;
    for c=1:nChannels
        subplot(4,4,c);
        imshow(RAW(:,:,f,c));
        title(sprintf('F %i, C %i',f,c))
    end
end

for f=1:nFilters
    figure;
    for c=1:nChannels
        subplot(4,4,c);
        imagesc(dsLinearVals(:,:,f,c));
        title(sprintf('F %i, C %i',f,c))
    end
end
%}
% Downsample the image
antialiasFilter = fspecial('gaussian',2*dsFac,dsFac);
antialiasLinearVals = imfilter(linearVals,antialiasFilter,'same');

dsLinearVals = antialiasLinearVals(1:dsFac:end,1:dsFac:end,:,:);
nRows = size(dsLinearVals,1);
nCols = size(dsLinearVals,2);

% Assume that the light intensity is constant, we can apply the same gain
% to different camera filters.
cameraGain = repmat(gains,[nFilters, 1, nRows]);
cameraOffset = zeros([nFilters, nChannels, nRows]);

try
    cluster = parcluster('local');
    cluster.NumWorkers = 30;
    pool = parpool(cluster,cluster.NumWorkers);
catch
end


parfor cc=1:nCols

    
    measVals = squeeze(dsLinearVals(:,cc,:,:));
    measVals = permute(measVals,[2 3 1]);
    
    % Normalize the measured pixel intensities, so that the maxium for each 
    % filter is 1. To preserve the image formation model we need to scale camera
    % gains accordingly.
    % nF = max(max(measVals,[],2),[],1);
    % nF = repmat(nF,[nFilters nChannels 1]);
    
    % nF = max(measVals,[],2);
    % nF = repmat(nF,[1 nChannels 1]);
    
    nF = max(measVals,[],1);
    nF = repmat(nF,[nFilters 1 1]); 
    
    nF(nF==0) = 1;  % In those weird cases where nothing is captured in all channels
    measVals = measVals./nF;
    cameraGainCol = cameraGain./nF;

    % try
    [ reflEst, ~, emEst, ~, exEst, ~, dMatEst, reflValsEst, flValsEst, hist  ] = ...
        fiRecReflAndMultiFl( measVals, camera, illuminantPhotons, cameraGainCol*deltaL,...
                             cameraOffset, reflBasis, emBasis, exBasis, alpha, beta, beta, eta, 'maxIter',maxIter,'rescaleRho',false);
                         
    fName = fullfile(dirName,sprintf('multiFlV2_%s_col_%i.mat',testFileName,cc));
    
    parforSave(fName,reflEst,emEst,exEst,dMatEst,reflValsEst,flValsEst,hist,...
                wave,alpha,beta,eta,measVals);
    %catch
    %    t = getCurrentTask;
    %    fprintf('Lab index error %i, column %i\n',t.ID,cc);
    %    error('Nan in SVD');
    % end
                                          
end

try 
    delete(pool);
catch
end


