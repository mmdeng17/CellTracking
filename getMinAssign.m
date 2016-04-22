function [assign,unassign,costs] = getMinAssign(initData,finData,dataDiffs,varargin)
% getMinAssign Assign initial states to final states based on minimization
% of sum of finite differences motion detection algorithm.
%   Tracking algorithm to assign initial states to final states based on a 
%   cost matrix and a modified Hungarian assignment algorithm. initData and
%   finData refer to vectors of data for initial and final states of the
%   objects, while dataDiffs refers to the average difference in states for
%   each parameter of the object state.
%
%   [A,U,C] = makeAssignment[i,f,d] returns the assignment of tracked cell
%   boundary objects as an assignment vector A, where the A(i) final object
%   is linked to the ith inital object. U consists of a vector of cells
%   that were unassigned in the algorithm, and C is a vector in the same
%   format as A with assignment costs instead of indices as vector
%   elements.
%
%   'MetCost' - maximum cost allowed for assignment of one object to
%       another for a single metric. The maximum cost allowed for
%       assignment is MetCost*m, where m is the number of state parameters
%       to be used for tracking.
%   'BgDiffs' - background shift correction for videos that have large
%       uniform shifts. Shifts must be calculated manually and consist of a
%       1x2 matrix indicating x and y shift in pixels
%   'Greedy' - logical representing whether a greedy assignment algorithm
%       should be combined with Hungarian assignment algorithm when
%       creating assignments
%
% Written by: Michael M. Deng
% Last modified: 1/25/15
%
% Credits to to Yi Cao, whose Hungarian Assignment algorithm is utilized
% in this code.

%% Parse Arguments
p = inputParser;
defaultMetCost = 16;
defaultGreedy  = true;
defaultAngle   = false;

p.addParamValue('MetCost', defaultMetCost, @(x) isnumeric(x) && x>=0)
p.addParamValue('Greedy',defaultGreedy,@(x) islogical(x)||x==1||x==0);
p.addParamValue('Angle',defaultAngle,@(x) islogical(x));

p.parse(varargin{:});

metCost = p.Results.MetCost;
greedy  = p.Results.Greedy;
angle   = p.Results.Angle;

%% Input Validation

%% Function
nMet = numel(initData);
numInit  = numel(initData{1});
numFin   = numel(finData{1});
costMats = zeros(numInit,numFin,nMet);

% Calculate costs
for k=setdiff(1:nMet,15)
    if dataDiffs(k)==0
        continue
    end
    for i=1:numInit
        for j=1:numFin
            initMet = initData{k}(i);
            finMet  = finData{k}(j);
            diff    = abs(finMet-initMet);
            cost    = (1+diff/dataDiffs(k))^2;
            costMats(i,j,k) = cost;
        end
    end
end

if angle~=0
    for i=1:numInit
        for j=1:numFin
            initMet = initData{15}(i);
            finMet  = finData{15}(j);
            if sign(initMet)~=sign(finMet);
                diff = min( abs((sign(initMet)*90-initMet)-(sign(finMet)*90-finMet)),...
                    abs(finMet-initMet) );
            else
                diff = abs(finMet-initMet);
            end
            cost = (1+diff/dataDiffs(15))^2;
            costMats(i,j,15) = cost;
        end
    end
end

% Generate final cost matrix
costMat = sum(costMats,3);
for i=1:numInit
    for j=1:numFin
        if costMat(i,j)>(metCost*sum(dataDiffs~=0))
            costMat(i,j) = Inf;
        end
    end
end

% Perform greedy assignment
greedyAssign = zeros(1,numInit);
greedyCost   = zeros(1,numInit);
if greedy
    for i=1:numInit
        for j=1:numFin
            if costMat(i,j)==min(costMat(i,:))&&costMat(i,j)==min(costMat(:,j))&&~isinf(costMat(i,j))
                greedyAssign(i) = j;
                greedyCost(i)   = costMat(i,j);
                costMat(i,:) = Inf;
                costMat(:,greedyAssign(i)) = Inf;
            end
        end
    end
end

[assign,costs] = munkres(costMat);
if greedy
    for i=1:length(greedyAssign)
        if greedyAssign(i)~=0
            assign(i) = greedyAssign(i);
            costs(i) = greedyCost(i);
        end
    end
end
assign(assign==0) = -1;
unassign = setdiff(1:numFin,assign);
end

