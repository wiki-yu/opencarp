clear
clc
close all
%%
dataDir = 'C:\Users\jakea\Documents\DockerBridge\SignalAlgos_data\openCarp\simpleAtriaExample\';
saveDir = [dataDir,'meshes\'];
%%
load(sprintf('%satriaGeom_lowres.mat',dataDir),'scirunfield');
points = scirunfield.node;
elem = scirunfield.face;

fibers = ones(size(scirunfield.face,2),3);
dims= size(elem,1);

%% save points
stimPointIx = {[1],...
               [1367],...
               [785],...
               [1341],...
               [1714],...
               };
stimLabels = {'anterior',...
              'pv_1',...
              'pv_2',...
              'pv_3',...
              'pv_4'};
numPointsToStim = 5;
for stimIx = 1:length(stimPointIx)
    originNode = points(:,stimPointIx{stimIx});
    distances = sqrt(sum((points - originNode).^2,1));
    [~,sortIx]  = sort(distances);
    nearbyNodes = [1:size(points,2)];
    nearbyNodes = nearbyNodes(sortIx);
    fileId = fopen(sprintf('%s%s.vtx',saveDir,stimLabels{stimIx}),'w');
    fprintf(fileId,'%d\nextra\n',numPointsToStim);
    fprintf(fileId,'%d\n',nearbyNodes(1:numPointsToStim));
    fclose(fileId);
end
%%

fileId = fopen([saveDir,'atria.pts'],'w');
fprintf(fileId,'%d\n',size(points,2));
fprintf(fileId,'%f %f %f\n',points);
fclose(fileId);
%% save elem
elem = elem-1;
fileId = fopen([saveDir,'atria.elem'],'w');
fprintf(fileId,'%d\n',size(elem,2));
if dims == 3
    fprintf(fileId,'Tr %d %d %d 1\n',elem);
else
    fprintf(fileId,'Tt %d %d %d %d 1\n',elem);
end
fclose(fileId);
%% save fibers
fileId = fopen([saveDir,'atria.lon'],'w');
fprintf(fileId,'1\n');
fprintf(fileId,'%d %d %d\n',fibers);
fclose(fileId);