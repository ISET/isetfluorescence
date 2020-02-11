% Plot the multi-fluorophore estimation results. Estimate confidence
% intervals through bootstrapping. This script generates Fig. 12 in the
% paper.
%
% Copyright, Henryk Blasinski 2016

close all;
clear all;
clc;

% Define the directory where figures will be saved. If saveDir = [], then
% figures are not saved.
% saveDir = fullfile('~','Desktop','Figures');
saveDir = [];
if ~exist(saveDir, 'dir'), mkdir(saveDir); end

% Figure display parameters
fs = 10;
lw = 2;
ms = 7;
sz = [1 1 3.5 2.5] * 2.5;
sz2 = [1 1 3.5 1.75] * 2.5;

leg = {'Multi-fl.','Reference'};

% Select patches whose data is to be saved
selPatches = [8 23 6];
nSel = length(selPatches);

% Select excitation and emission wavelength for Donaldson matrix corss-section
% plots
emRefWave = [500 484 400];
exRefWave = [600 512 508];


fName = fullfile(fiToolboxRootPath,'results','bootstrap','multiFl_Macbeth+multiFl_bootstrap_100_1.mat');
load(fName);

% Load a custom color map
fName = fullfile(fiToolboxRootPath,'data','flCmap');
load(fName);

wave = wave(:);

% Wavelength subsampling
sr = 1:5:length(wave);


%% Display data for all patches

% Pixel values

multiFlMeasValsEst = cell2mat(shiftdim(reflValsEst,-3)) + cell2mat(shiftdim(flValsEst,-3));
avgMultiFlMeasValsEst = mean(multiFlMeasValsEst,4);
avgMultiFlMeasVals = mean(measVals,4);


figure;
hold all; grid on; box on;
plot(avgMultiFlMeasValsEst(:),avgMultiFlMeasVals(:),'.');
xlabel('Model predicted pixel value','interpreter','latex');
ylabel('Measured pixel value','interpreter','latex');


figure;
for xx=1:6
for yy=1:4

    plotID = (yy-1)*6 + xx;
    sampleID = (xx-1)*4 + yy;

    subplot(4,6,plotID);
    hold all; grid on; box on;
    
    
    tmp1 = avgMultiFlMeasValsEst(:,:,sampleID)';
    tmp2 = avgMultiFlMeasVals(:,:,sampleID)';
    
    xlim([0 1]);
    ylim([0 1]);
    
    plot(tmp1,tmp2,'.');

end
end


% Reflectance

multiFlReflEst = cell2mat(shiftdim(reflEst,-2));
avgMultiFlReflEst = mean(multiFlReflEst,3);
sorted = sort(multiFlReflEst,3);
avgMultiFlReflEstLb = sorted(:,:,3);
avgMultiFlReflEstUb = sorted(:,:,97);


figure;
for xx=1:6
for yy=1:4

    plotID = (yy-1)*6 + xx;
    sampleID = (xx-1)*4 + yy;

    subplot(4,6,plotID);
    hold all; grid on; box on;    
    
    % Confidence intervals
    plot(wave,avgMultiFlReflEstLb(:,sampleID),'c','LineWidth',1);
    plot(wave,avgMultiFlReflEstUb(:,sampleID),'c','LineWidth',1);
    
    plot(wave,avgMultiFlReflEst(:,sampleID),'g','LineWidth',2);
    
    % Reference
    plot(wave,reflRef(:,sampleID),'b--','LineWidth',2);
    
    
    xlim([min(wave) max(wave)]);
    ylim([-0.05 1.05]);

    rmse = sqrt(mean((avgMultiFlReflEst(:,sampleID) - reflRef(:,sampleID)).^2));
    title(sprintf('RMSE %.2f',rmse));

end
end



% Donaldson matrix (absolute)

multiFlDMatEst = cell2mat(shiftdim(cellfun(@(x) cell2mat(shiftdim(x,-2)),dMatEst,'UniformOutput',false),-3));
avgMultiFlDMatEst = mean(multiFlDMatEst,4);
sorted = sort(multiFlDMatEst,4);
avgMultiFlDMatEstLb = sorted(:,:,:,3);
avgMultiFlDMatEstUb = sorted(:,:,:,97);

figure;
set(gcf,'Colormap',flCmap);
for xx=1:6
for yy=1:4

    plotID = (yy-1)*6 + xx;
    sampleID = (xx-1)*4 + yy;

    subplot(4,6,plotID);
    
    data = [avgMultiFlDMatEst(:,:,sampleID) dMatRef{sampleID}];
    imagesc(data);

end
end




% Donaldson matrix (normalized)

figure;
set(gcf,'Colormap',flCmap);
for xx=1:6
for yy=1:4

    plotID = (yy-1)*6 + xx;
    sampleID = (xx-1)*4 + yy;

    subplot(4,6,plotID);
    
    t1 = avgMultiFlDMatEst(:,:,sampleID);
    t1 = t1/max(t1(:));
    
    t2 = dMatRef{sampleID};
    t2 = t2/max(t2(:));
    
    data = [t1 t2 ];
    imagesc(data);

end
end

% Excitation (normalized) plot at a given wavelength

refWave = 512;

figure;
for xx=1:6
for yy=1:4

    plotID = (yy-1)*6 + xx;
    sampleID = (xx-1)*4 + yy;

    subplot(4,6,plotID);
    hold on; grid on; box on;
    
    
    t2 = dMatRef{sampleID}(wave == refWave,:);
    t2 = t2/max(t2);
    
    t1Lb = avgMultiFlDMatEstLb(wave == refWave,:,sampleID);
    t1Ub = avgMultiFlDMatEstUb(wave == refWave,:,sampleID);
    
    t1avg= avgMultiFlDMatEst(wave == refWave,:,sampleID);
    nF = max(t1avg);
    
    t1Ub = t1Ub(:)/nF;
    t1Lb = t1Lb(:)/nF;
    t1avg = t1avg(:)/nF;
    
    fill([wave(:); rot90(wave(:),2)],[t1Ub; rot90(t1Lb,2)],[0.8 1 0.8],'edgeColor','none');
    
    plot(wave,t1avg,'g--','LineWidth',2);
    plot(wave,t2,'r-','LineWidth',2);
    
        
    xlim([min(wave) max(wave)]);
    
end
end


% Emission (normalized) plot at a given wavelength


refWave = 520;

figure;
for xx=1:6
for yy=1:4

    plotID = (yy-1)*6 + xx;
    sampleID = (xx-1)*4 + yy;

    subplot(4,6,plotID);
    hold on; grid on; box on;
    
    
    t2 = dMatRef{sampleID}(:,wave == refWave);
    t2 = t2/max(t2);
    
    t1Lb = avgMultiFlDMatEstLb(:,wave == refWave,sampleID);
    t1Ub = avgMultiFlDMatEstUb(:,wave == refWave,sampleID);
    
    t1avg= avgMultiFlDMatEst(:,wave == refWave,sampleID);
    nF = max(t1avg);
    
    t1Ub = t1Ub(:)/nF;
    t1Lb = t1Lb(:)/nF;
    t1avg = t1avg(:)/nF;
    
    fill([wave(:); rot90(wave(:),2)],[t1Ub; rot90(t1Lb,2)],[0.8 1 0.8],'edgeColor','none');
    
    plot(wave,t1avg,'g--','LineWidth',2);
    plot(wave,t2,'r-','LineWidth',2);
    
        
    xlim([min(wave) max(wave)]);
    
end
end

%% Now generate figures for specific, selected patches

% Pixel values

multiFlMeasValsEst = cell2mat(shiftdim(reflValsEst,-3)) + cell2mat(shiftdim(flValsEst,-3));
avgMultiFlMeasValsEst = mean(multiFlMeasValsEst,4);
sorted = sort(multiFlMeasValsEst,4);
avgMultiFlMeasValsEstLb = sorted(:,:,:,3);
avgMultiFlMeasValsEstUb = sorted(:,:,:,97);

for s=1:nSel
   
    id = selPatches(s);
    tmp = measVals(:,:,id); tmp = tmp(:);


    figure;
    hold on; grid on; box on;

    %  estimate
    tmp2 = avgMultiFlMeasValsEst(:,:,id);
    plot(tmp(:),tmp2(:),'go','markerSize',ms,'lineWidth',lw);
    
    % Reference
    plot(linspace(0,1.1,10),linspace(0,1.1,10),'r-','lineWidth',0.5*lw);
    
    xlim([0 1.05]);
    ylim([0 1.05]);
    
    xlabel('Measured','fontsize',fs,'interpreter','latex');
    ylabel('Predicted','fontsize',fs,'interpreter','latex');
    
    
    set(gca,'yTick',0:0.2:1);
    set(gca,'fontsize',fs-2);
    set(gca,'TickLabelInterpreter','latex');
    set(gcf,'Units','centimeters');
    set(gca,'Units','centimeters');
    set(gcf,'PaperPosition',sz);
    
    if ~isempty(saveDir)
        fName = fullfile(saveDir,sprintf('multiFlPixels_%i.eps',id));
        print('-depsc',fName);
    end
end


%  Reflectance
for s=1:nSel
   
    id = selPatches(s);
    
    figure;
    hold on; grid on; box on; 
    
    % Confidence interval on single fluorophore estimate
    fill([wave; rot90(wave,2)],[avgMultiFlReflEstUb(:,id); rot90(avgMultiFlReflEstLb(:,id),2)],[0.8 1 0.8],'edgeColor','none');
    
     
    % Single fluorophore estimate
    l(2) = plot(wave,avgMultiFlReflEst(:,id),'g--','lineWidth',lw);
    plot(wave(sr),avgMultiFlReflEst(sr,id),'go','markerSize',ms,'lineWidth',lw*0.5);
    
    
    % Reference
    l(1) = plot(wave,reflRef(:,id),'r','lineWidth',lw);
    
    xlim([min(wave) max(wave)]);
    ylim([-0.05 1.05]);
    
    lh = legend(l,leg,'location','northwest','interpreter','latex');
    
   % ch = get(lh,'Children');
   % set(ch(1),'Marker','o','MarkerSize',ms);
    
    xlabel('Wavelength, nm','fontsize',fs,'interpreter','latex');
    set(gca,'yTick',0:0.2:1);
    set(gca,'fontsize',fs-2);
    set(gca,'TickLabelInterpreter','latex');
    set(gcf,'Units','centimeters');
    set(gca,'Units','centimeters');
    set(gcf,'PaperPosition',sz);
    
    if ~isempty(saveDir)
        fName = fullfile(saveDir,sprintf('multiFlRefl_%i.eps',id));
        print('-depsc',fName);
    end
end


% Donaldson matrix
for s=1:nSel
   
    id = selPatches(s);

    data = [avgMultiFlDMatEst(:,:,id) dMatRef{id}];
    mVal = max(data(:));
    
    % Estimated
    figure;
    grid on; box on; 
    imagesc(wave,wave,avgMultiFlDMatEst(:,:,id),[0 mVal]);
    
    hold on;
    for k=400:100:1000
        x = [380 1000];
        y = [k k];
        plot(x,y,'Color',[0.2 0.2 0.2],'LineStyle',':','LineWidth',0.5);
    end
    
    for k=400:100:1000
        y = [380 1000];
        x = [k k];
        plot(x,y,'Color',[0.2 0.2 0.2],'LineStyle',':','LineWidth',0.5);
    end
    
    line([min(wave) max(wave)],ones(2,1)*exRefWave(s),'color','green','lineWidth',lw);
    line(ones(2,1)*emRefWave(s),[min(wave) max(wave)],'color','green','lineWidth',lw);

    
    
    ylabel('Emission, nm','fontsize',fs,'interpreter','latex');
    xlabel('Excitation, nm','fontsize',fs,'interpreter','latex');
    set(gcf,'Colormap',flCmap);
    set(gca,'fontsize',fs-2);
    set(gca,'TickLabelInterpreter','latex');
    set(gcf,'Units','centimeters');
    set(gca,'Units','centimeters');
    set(gcf,'PaperPosition',sz);
    
    if ~isempty(saveDir)
        fName = fullfile(saveDir,sprintf('multiFlDMat_%i.eps',id));
        print('-depsc',fName);
    end
    
    % Reference
    figure;
    grid on; box on;
    imagesc(wave,wave,dMatRef{id},[0 mVal]);
    
    hold on;
    
    hold on;
    for k=400:100:1000
        x = [380 1000];
        y = [k k];
        plot(x,y,'Color',[0.2 0.2 0.2],'LineStyle',':','LineWidth',0.5);
    end
    
    for k=400:100:1000
        y = [380 1000];
        x = [k k];
        plot(x,y,'Color',[0.2 0.2 0.2],'LineStyle',':','LineWidth',0.5);
    end
    
    line([min(wave) max(wave)],ones(2,1)*exRefWave(s),'color','red','lineWidth',lw);
    line(ones(2,1)*emRefWave(s),[min(wave) max(wave)],'color','red','lineWidth',lw);
    
    ylabel('Emission, nm','fontsize',fs,'interpreter','latex');
    xlabel('Excitation, nm','fontsize',fs,'interpreter','latex');
    set(gca,'fontsize',fs-2);
    set(gca,'TickLabelInterpreter','latex');
    set(gcf,'Units','centimeters');
    set(gca,'Units','centimeters');
    set(gcf,'PaperPosition',sz);
    set(gcf,'Colormap',flCmap);
    
    if ~isempty(saveDir)
        fName = fullfile(saveDir,sprintf('multiFlDMatRef_%i.eps',id));
        print('-depsc',fName);
    end
    
    
    % Colorbar
    figure;
    set(gcf,'Colormap',flCmap);

    left=100; bottom=100 ; width=20 ; height=500;
    pos=[left bottom width height];
    axis off

    
    cb = colorbar('position',[0.1 0.1  0.5  0.8]);
    set(gca,'CLim',[0 mVal]);
    set(gca,'fontsize',fs-2);
    set(gcf,'OuterPosition',pos);
    set(gcf,'Units','centimeters');
    set(gca,'Units','centimeters');
    set(cb,'TickLabelInterpreter','latex');
    set(gcf,'PaperPosition',[1 1 sz(3)/5 sz(4)]);
        
    if ~isempty(saveDir)
        fName = fullfile(saveDir,sprintf('multiFlScale_%i.eps',id));
        print('-depsc',fName);
    end
    
end

% Excitation (cross section along a row

for s=1:nSel

    id = selPatches(s);
    
    figure;
    hold all; grid on; box on;
    
    t2 = dMatRef{id}(wave == exRefWave(s),:);
    t2 = t2/max(t2);
    
    t1Lb = avgMultiFlDMatEstLb(wave == exRefWave(s),:,id);
    t1Ub = avgMultiFlDMatEstUb(wave == exRefWave(s),:,id);
    
    t1avg= avgMultiFlDMatEst(wave == exRefWave(s),:,id);
    nF = max(t1avg);
    
    t1Ub = t1Ub(:)/nF;
    t1Lb = t1Lb(:)/nF;
    t1avg = t1avg(:)/nF;
    
    fill([wave(:); rot90(wave(:),2)],[t1Ub; rot90(t1Lb,2)],[0.8 1 0.8],'edgeColor','none');
    
    
    l(1) = plot(wave,t1avg,'g--','LineWidth',2);
    l(2) = plot(wave,t2,'r-','LineWidth',2);
    xlim([min(wave) max(wave)]);
    ylim([-0.05 1.05]);
    
    legend(l,leg,'location','northeast','interpreter','latex');
    
    xlabel('Wavelength, nm','fontsize',fs,'interpreter','latex');
    set(gca,'yTick',0:0.2:1);
    set(gca,'fontsize',fs-2);
    set(gca,'TickLabelInterpreter','latex');
    set(gca,'Units','centimeters');
    set(gcf,'Units','centimeters');
    set(gcf,'PaperPosition',sz2);
    
    if ~isempty(saveDir)
        fName = fullfile(saveDir,sprintf('multiFlEx_%i.eps',id));
        print('-depsc',fName);
    end
end


% Emission (cross section along a column)

for s=1:nSel

    id = selPatches(s);
    
    figure;
    hold all; grid on; box on;
    
    t2 = dMatRef{id}(:,wave == emRefWave(s));
    t2 = t2/max(t2);
    
    t1Lb = avgMultiFlDMatEstLb(:,wave == emRefWave(s),id);
    t1Ub = avgMultiFlDMatEstUb(:,wave == emRefWave(s),id);
    
    t1avg= avgMultiFlDMatEst(:,wave == emRefWave(s),id);
    nF = max(t1avg);
    
    t1Ub = t1Ub(:)/nF;
    t1Lb = t1Lb(:)/nF;
    t1avg = t1avg(:)/nF;
    
    fill([wave(:); rot90(wave(:),2)],[t1Ub; rot90(t1Lb,2)],[0.8 1 0.8],'edgeColor','none');
    
    
    l(1) = plot(wave,t1avg,'g--','LineWidth',2);
    l(2) = plot(wave,t2,'r-','LineWidth',2);
    xlim([min(wave) max(wave)]);
    ylim([-0.05 1.05]);
    
    legend(l,leg,'location','northeast','interpreter','latex');
    
    xlabel('Wavelength, nm','fontsize',fs,'interpreter','latex');
    set(gca,'yTick',0:0.2:1);
    set(gca,'TickLabelInterpreter','latex');
    set(gca,'fontsize',fs-2);
    set(gca,'Units','centimeters');
    set(gcf,'Units','centimeters');
    set(gcf,'PaperPosition',sz2);
    
    if ~isempty(saveDir)
        fName = fullfile(saveDir,sprintf('multiFlEm_%i.eps',id));
        print('-depsc',fName);
    end
end


