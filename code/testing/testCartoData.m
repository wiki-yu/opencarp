clear
close all
clc
%% directory setup

dataDir = 'C:\Users\jakea\Documents\DockerBridge\SignalAlgos_data\carto\openEPCartoData\';
load([dataDir,'openEP_cartoData_1.mat'],'userdata')

%%
atria.node = userdata.surface.triRep.X';
atria.face = userdata.surface.triRep.Triangulation';

measurementLocations = userdata.electric.egmSurfX;
egmData.potvals = squeeze(userdata.electric.egmUni(:,:,1));
acttimes.potvals = userdata.electric.annotations.mapAnnot;
badLeads = find(acttimes.potvals<0)';
for bl = badLeads
    nearest = dsearchn(measurementLocations(acttimes.potvals>0,:),measurementLocations(bl,:));
    fprintf('For node %d switching act time from %d to %d from node %d\n',bl,nearest,acttimes.potvals(bl),acttimes.potvals(nearest))
    acttimes.potvals(bl) = acttimes.potvals(nearest);
end
acttimes.potvals = acttimes.potvals - min(acttimes.potvals);
%% visualize
figure(1);clf();hold on;
trisurf(atria.face',atria.node(1,:),atria.node(2,:),atria.node(3,:),'FaceColor',[1,1,1])
pcshow(measurementLocations,'g','MarkerSize',500)
%pcshow(userdata.rf.originaldata.force.position,'r','MarkerSize',700)
%% median filter data
fullData = nan(size(atria.node,2),1);
fullData(dsearchn(atria.node',measurementLocations)) = acttimes.potvals;
interpActTimes.potvals = medianSpatialFilter_jb(fullData,userdata.surface.triRep,5,0);
%%
fullData = nan(size(atria.node,2),size(egmData.potvals,2));
fullData(dsearchn(atria.node',measurementLocations),:) = egmData.potvals;
interpEGMData.potvals = medianSpatialFilter_jb(fullData,userdata.surface.triRep,5,0);
%% saving things out
save([dataDir,'atria_geom.mat'],'atria')
save([dataDir,'measurementLocations.pts'],'measurementLocations','-ascii')
save([dataDir,'measuredEGM.mat'],'egmData')
save([dataDir,'actTimes.mat'],'acttimes')
save([dataDir,'actTimes_interp.mat'],'interpActTimes')
save([dataDir,'measuredEGM_interp.mat'],'interpEGMData')
%% plot in map3d


