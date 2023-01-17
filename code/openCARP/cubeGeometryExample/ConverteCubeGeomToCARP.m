clear
clc
close all
%%
load('cubeGeom.mat');
points = scirunfield.node;
if isfield(scirunfield,'face')
    elem = scirunfield.face;
else
    elem = scirunfield.cell;
end
fibers = scirunfield.field;
dims= size(elem,1);
saveDir = 'D:\DockerBridge\tissueTests\scripts\meshes\';
%% save points
stimPointIx = [0,1];
%stimPoint = points(:,stimPointIx);
fileId = fopen([saveDir,'stimPoint.vtx'],'w');
fprintf(fileId,'%d\nextra\n',length(stimPointIx));
%fprintf(fileId,'%f %f %f\n',stimPoint);
fprintf(fileId,'%d\n',stimPointIx);
fclose(fileId);


fileId = fopen([saveDir,'cubeGeom.pts'],'w');
fprintf(fileId,'%d\n',size(points,2));
fprintf(fileId,'%f %f %f\n',points);
fclose(fileId);
%% save elem
elem = elem-1;
fileId = fopen([saveDir,'cubeGeom.elem'],'w');
fprintf(fileId,'%d\n',size(elem,2));
if dims == 3
    fprintf(fileId,'Tr %d %d %d 1\n',elem);
else
    fprintf(fileId,'Tt %d %d %d %d 1\n',elem);
end
fclose(fileId);
%% save fibers
fileId = fopen([saveDir,'cubeGeom.lon'],'w');
fprintf(fileId,'1\n');
fprintf(fileId,'%d %d %d\n',fibers);
fclose(fileId);