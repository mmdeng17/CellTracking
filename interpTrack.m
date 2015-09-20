function yhat = interpTrack(t,y,varargin)
% Interpolates incomplete track data. t is a vector of timepoints, while y
% is the track measurements with missing values equal to 0.
%
% Y = interpTrack(t,y) returns the interpolated track data in vector Y.
%
%   'NumStart' - maximum number of missing initial points that can be 
%       extrapolated from data
%   'NumEnd' - mxaimum numer of missing end points that can be extrapolated
%       from data
%   'NumHole' - maximum number of contiguous points in middle of data set
%       that can be interpolated.
%
% Written by: Michael Deng
% Last modified: 1/25/15

%% Parse Arguments
p = inputParser;
defaultNumStart    = 5;
defaultNumEnd = 0;
defaultNumHole   = 1e99;

p.addParamValue('NumStart',defaultNumStart, @(x) isnumeric(x) && mod(x,1)==0 && x>=0);
p.addParamValue('NumEnd',defaultNumStart, @(x) isnumeric(x) && mod(x,1)==0 && x>=0);
p.addParamValue('NumHole',defaultNumHole,@(x) isnumeric(x) && mod(x,1)==0 && x>=0);

p.parse(varargin{:});

numStart = p.Results.NumStart;
numEnd = p.Results.NumEnd;
numHole = p.Results.NumHole;

%% Function
nPts = numel(t);

% Find start/endpts of nonzero data
tStart = 1;
tEnd  = nPts;
for i=2:nPts
    if sum(y(i:end)==0)==nPts-i+1
        tEnd = i-1;
        break
    end
end
for i=nPts:-1:1
    if sum(y(1:i)==0)==i
        tStart = i+1;
        break
    end
end

yhat = y;

% If necessary, fill in missing start and end data based on numEnd
if tStart<=numStart && tStart~=1
    nFill = min(max(2,tStart-1),tEnd-tStart+1);
    for i=tStart-1:-1:1
        usePts = i+2:i+nFill+1;
        newY = zeros(1,numel(usePts));
        p1 = i+1;
        for j=1:numel(usePts)
            p2 = usePts(j);
            currM = (yhat(p2)-yhat(p1))/(t(p2)-t(p1));
            newY(j) = yhat(p1)-(t(p1)-t(i))*currM;
        end
        yhat(i) = mean(newY);
    end
    tStart = 1;
end

if (nPts-tEnd)<=numEnd && tEnd~=nPts
    nFill = min(max(2,nPts-tEnd),tEnd-tStart+1);
    for i=tEnd+1:nPts
        usePts = i-2:-1:i-nFill-1;
        newY = zeros(1,numel(usePts));
        p1 = i-1;
        for j=1:numel(usePts)
            p2 = usePts(j);
            currM = (yhat(p2)-yhat(p1))/(t(p2)-t(p1));
            newY(j) = yhat(p1)-(t(p1)-t(i))*currM;
        end
        yhat(i) = mean(newY);
    end
    tEnd = nPts;
end

% If necessary fill in missing interpolant data using numHole
zPts = find(yhat(tStart:tEnd)==0);
zPts = zPts+tStart-1;
count = 1;
while(~isempty(zPts)) && count<=numel(zPts)
    currZ = zPts(count);
    currG = zPts-currZ-(1:numel(zPts))+count;
    nG = sum(currG==0);
    if nG<=numHole
        zeroPts = zPts(currG==0);
        nZeroPts = tStart:tEnd;
        nZeroPts = nZeroPts(yhat(nZeroPts)~=0);
        yhat(zeroPts) = interp1(t(nZeroPts),yhat(nZeroPts),zeroPts,'pchip');
    end
    count = count+nG;
end


end

