clear
clc
close all
%%
dataDir = 'C:\Users\jakea\Documents\DockerBridge\SignalAlgos_data\openCarp\bratislavaPatient\';
saveDir = [dataDir,'meshes\'];
%%
load(sprintf('%sventricularMesh.mat',dataDir),'scirunfield');
points = scirunfield.node;
elem = scirunfield.cell;

fibers = ones(size(scirunfield.cell,2),3);
dims= size(elem,1);

%% save points
stimPointIx = {[1]               };
numberOfPoints = 10;
stimLabels = {'test'};
for stimIx = 1:length(stimPointIx)'
    nearestIx = dsearchn(points',points(:,stimPointIx{stimIx}));
    pointsToStim = nearestIx(1:numberOfPoints) - 1;%-1 to correct for python indexing.
    fileId = fopen(sprintf('%s%s.vtx',saveDir,stimLabels{stimIx}),'w');
    fprintf(fileId,'%d\nextra\n',length(pointsToStim));
    fprintf(fileId,'%d\n',pointsToStim);
    fclose(fileId);
end
%%

fileId = fopen([saveDir,'ventricles.pts'],'w');
fprintf(fileId,'%d\n',size(points,2));
fprintf(fileId,'%f %f %f\n',points);
fclose(fileId);
%% save elem
elem = elem-1;
fileId = fopen([saveDir,'ventricles.elem'],'w');
fprintf(fileId,'%d\n',size(elem,2));
if dims == 3
    fprintf(fileId,'Tr %d %d %d 1\n',elem);
else
    fprintf(fileId,'Tt %d %d %d %d 1\n',elem);
end
fclose(fileId);
%% save fibers
fileId = fopen([saveDir,'ventricles.lon'],'w');
fprintf(fileId,'1\n');
fprintf(fileId,'%d %d %d\n',fibers);
fclose(fileId);