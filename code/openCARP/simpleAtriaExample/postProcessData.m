clear
clc
close all
%% directory setup
baseDir = 'C:\Users\jakea\Documents\DockerBridge\';
dataDir = [baseDir,'SignalAlgos_data\openCarp\simpleAtriaExample\'];

experimentList = {'anterior',...
                  'pv_1',...
                  'pv_2',...
                  'pv_3',...
                  'pv_4',...
                  'anterior_v2',...
                  'pv_1_v2',...
                  'pv_2_v2',...
                  'pv_3_v2',...
                  'pv_4_v2'};
%% convert data from IGB format
for expIx = 1:length(experimentList)
    files = dir(sprintf('%s*%s\\phie.igb',dataDir,experimentList{expIx})); % find data file
    folders{expIx} = [files(1).folder,'\'];
    dataFiles{expIx} = [files(1).folder,'\',files(1).name];
    [data,headder] = readigbfile(dataFiles{expIx}); %run conversion
    % assemble output structure
    ts.potvals = data;
    ts.units = 'mV';
    ts.timeUnits = '0.01 ms';
    ts.carpHeadder = headder;
    ts.label = sprintf('simulation output from carp for %s stimulation',experimentList{expIx});
    save(sprintf('%s\\phie_%s.mat',files(1).folder,experimentList{expIx}),'ts')
end
%%
for expIx = 1:length(experimentList)
    load(sprintf('%s\\phie_%s.mat',folders{expIx},experimentList{expIx}),'ts')
    potvals = ts.potvals;
    clear('ts')
    ts.potvals = nan(size(potvals,1),1);
    for sigIx = 1:size(potvals,1)
        ts.potvals(sigIx) = ActDetect(potvals(sigIx,:),5,2);
    end
    save(sprintf('%s\\actTimes_%s.mat',folders{expIx},experimentList{expIx}),'ts')
end

%% plot in map3d
geom = [dataDir,'atriaGeom_lowRes.mat'];
opt.nw = [1];
simStartIx = 1;%start at 1 for v1, start at 6 for v2
twoMonitor = 1;
if twoMonitor
    screenDims = [-3800 -2800 -1080 -200;...
                  -2800 -1800 -1080 -200;...
                  -1800 -800 -1080 -200;...
                  -3800 -2800 -200 670;...
                  -2800 -1800 -200 670];
else
    screenDims = [0 600 0 500;...
                  600 1200 0 500;...
                  1200 1800 0 500;...
                  0 600 500 1000;...
                  600 1200 500 1000];
end
plot_map3d({geom,geom,geom,geom,geom},...
           {sprintf('%s\\phie_%s.mat',folders{simStartIx},experimentList{simStartIx}),...
            sprintf('%s\\phie_%s.mat',folders{simStartIx+1},experimentList{simStartIx+1}),...
            sprintf('%s\\phie_%s.mat',folders{simStartIx+2},experimentList{simStartIx+2}),...
            sprintf('%s\\phie_%s.mat',folders{simStartIx+3},experimentList{simStartIx+3}),...
            sprintf('%s\\phie_%s.mat',folders{simStartIx+4},experimentList{simStartIx+4})},...
           {sprintf('-sc 1 0 3 -s 1 500 -sm 3 -as %d %d %d %d',screenDims(1,1:4)),...
            sprintf('-sc 1 0 3 -s 1 500 -sm 3 -as %d %d %d %d',screenDims(2,1:4)),...
            sprintf('-sc 1 0 3 -s 1 500 -sm 3 -as %d %d %d %d',screenDims(3,1:4)),...
            sprintf('-sc 1 0 3 -s 1 500 -sm 3 -as %d %d %d %d',screenDims(4,1:4)),...
            sprintf('-sc 1 0 3 -s 1 500 -sm 3 -as %d %d %d %d',screenDims(5,1:4)),...
           },...
           opt)
screenDims = [0 600 0 500;...
              600 1200 0 500;...
              1200 1800 0 500;...
              0 600 500 1000;...
              600 1200 500 1000];
plot_map3d({geom,geom,geom,geom,geom},...
           {sprintf('%s\\actTimes_%s.mat',folders{simStartIx},experimentList{simStartIx}),...
            sprintf('%s\\actTimes_%s.mat',folders{simStartIx+1},experimentList{simStartIx+1}),...
            sprintf('%s\\actTimes_%s.mat',folders{simStartIx+2},experimentList{simStartIx+2}),...
            sprintf('%s\\actTimes_%s.mat',folders{simStartIx+3},experimentList{simStartIx+3}),...
            sprintf('%s\\actTimes_%s.mat',folders{simStartIx+4},experimentList{simStartIx+4})},...
           {sprintf('-sc 1 0 3 -sm 3 -as %d %d %d %d',screenDims(1,1:4)),...
            sprintf('-sc 1 0 3 -sm 3 -as %d %d %d %d',screenDims(2,1:4)),...
            sprintf('-sc 1 0 3 -sm 3 -as %d %d %d %d',screenDims(3,1:4)),...
            sprintf('-sc 1 0 3 -sm 3 -as %d %d %d %d',screenDims(4,1:4)),...
            sprintf('-sc 1 0 3 -sm 3 -as %d %d %d %d',screenDims(5,1:4)),...
           },...
           opt)
