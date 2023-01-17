function [data,headder] = readigbfile(filePath)
%READIGBFILE Summary of this function goes here
%   Detailed explanation goes here
fileId = fopen(filePath);
headder = fread(fileId,1024,'uchar');
headder = char(join(string(char(headder))));
endDim = strfind(headder,'y :');
xDim = headder(4:endDim(1)-1);
xDim = str2num(strrep(xDim,' ',''));
data = fread(fileId,inf,'float');
yDim = length(data)/xDim;
data = reshape(data,xDim,yDim);
fclose(fileId);
end

