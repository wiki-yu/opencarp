function [outSignal,miscOutputs] = baselineCorrectSignal(signal,opt)
% This function computes and applies a baseline correction of the input
% signal.
% several baseline correction methods have been implemnted here and can be
% accessed by chaning the options argument
% Inputs:
%   signal: a channels x time instant array to be baseline corrected
%   opt: an optional control variable structure with the following fields:
%       opt.method: the baseline correction method to be used:
%           1(default): mean subtraction. Subtract the mean signal for each channel
%           2: end to end linear baseline removal. Fits a line to the start
%           and end of the signal for each electrode and removes that line.
%           Assumes that the start and end fo the signal are isoelectric
%               Requires: opt.windowSize, size of window >=1 that is used
%               to determine the start and end values.
% Outputs:
%   outSignal: the processed signal
%   miscOuputs: an additional structure where other outputs if any can be
%   found

% input checking and default value setting
if ~exist('opt','var')
    opt.method = 1;
end
if ~isfield(opt,'method')
    opt.method = 1;
end
if ~isfield(opt,'windowSize')
    opt.windowSize = 5;
end

%set up miscOutputs so it at least has somethign in it
miscOutputs.functionHandle = @baselineCorrectSignal;

switch opt.method
    case 1 % mean subtraction
        miscOutputs.signalMean = mean(signal,2);
        outSignal = signal - miscOutputs.signalMean;
        
    case 2 %slope subtraction
        %initilize a time vector
        numTimeSample = size(signal,2);
        timeVec = 0:numTimeSample-1;
        %get the average starting and ending value over the specified
        %window size
        startVal = mean(signal(:,1:opt.windowSize),2);
        endVal = mean(signal(:,end-opt.windowSize:end),2);
        %calculate the slope of the line between start and end
        slopes = (endVal-startVal)./numTimeSample;
        %creat values along this line for every time instant
        baselineVals = slopes*timeVec + startVal;%leverage the fact that
        %vector multiplication here will give us a full matrix of values
        %subtract those lines from the signal
        outSignal = signal-baselineVals;
        %save out the line properties
        miscOutputs.slopes = slopes;
        miscOutputs.intercepts = startVal;
        miscOutputs.baselineVals = baselineVals;
        
end


end

