function filteredSignal = temporalFilter(signal)
% Temporal filter designed for electrogram data
% TODO: Finish description
% filter Parameters for Direct Form II Transposed filter
A = 1;
B = [0.0277777777777778	0.0555555555555556	0.0833333333333333	0.111111111111111	0.138888888888889	0.166666666666667	0.138888888888889	0.111111111111111	0.0833333333333333	0.0555555555555556	0.0277777777777778];


%%%% do the filtering
Data = signal';
Data = filter(B,A,Data);
%The first filtereSize samples of data will be messed up a bit so just
%replace them with the next bit of viable signal
Data( 1:(max(length(A),length(B))-1), :) = ones( max(length(A),length(B))-1  ,1 )  *  Data( max(length(A),length(B)) ,:);
filteredSignal = Data'; 