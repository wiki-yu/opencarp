%% preamble
clear
close all
clc
%% setup directories
scriptPath = which('testValenciaData');
basePath = scriptPath(1:strfind(scriptPath,'SignalAlgos')-1);
datasetPath = [basePath,'datasets/Valencia_pat2_11-30-2014'];

%% load data
load(formatPath(sprintf('%s/Interventions/AV_block/EGM_AV_block.mat',datasetPath)));

%% preprocess data

ts = EGM;
[numLeads,numTime] = size(ts.potvals);
ts_orig = EGM;
timeWindowOfInterest = [4000,5000];%section of the signal I have decided to care about for the moment
ts_orig.potvals = EGM.potvals(:,timeWindowOfInterest(1):timeWindowOfInterest(2));
%baseline correct
processOpts.method = 1;
ts.potvals = baselineCorrectSignal(ts_orig.potvals,processOpts);
processOpts.method = 2;
processOpts.windowSize = 5;
[ts.potvals,miscOutputs] = baselineCorrectSignal(ts.potvals,processOpts);


figure(1);clf();
subplot(311);hold on;
plot(ts_orig.potvals');
yline(mean(ts_orig.potvals,2))
subplot(312);
plot(ts.potvals');

%filter
ts.potvals = temporalFilter(ts.potvals);

subplot(313);
plot(ts.potvals');

%%
figure(1);clf();
subDims = [10,10];
for ele = 1:73
    subplot(subDims(1),subDims(2),ele);
    hold on;
    plot(ts.potvals(ele,:),'b');
    plot(ts_orig.potvals(ele,:),'r');
    title(ele)
end
%%
save(formatPath(sprintf('%sscratchSpace/valenciaDataTesting/testPotvals.mat',basePath)),'ts')

%% functions

