function [tracks,arrayTracks] = trackLinker(data,varargin)
% trackLinker Calculates trajectories of object data using motion detection
% algorithm.
%   Links objects from frame to frame together using a cost matrix and
%   Munkres Hungarian assignment algorithm. data is a cell array of data
%   with a cell for each frame containing a cell array of data for objects
%   in that frame.
%
%   [T,A] = trackLinker(d) returns cell array of indices for each found
%   trajectory, where the ith value refers to the object index in frame i,
%   as well as the indices in array form in A.
%
%   'Method' - in development for SVM tracking (NOT CURRENTLY FUNCTIONAL)
%   'MetCost' - maximum cost for a single parameter of the object data. The
%       maximum cost for assignment is MetCost*number of metrics
%   'GapClose' - maximum number of frames that can be skipped over when 
%       linking two objects
%   'Greedy' - boolean whether or not to use greedy or Munkres assignment
%       for object linking
%   'Diffs' - vector of average differences from frame to frame for each
%       parameter
%   'Angle' - whether or not the angle metric is used to track objects
% 
% Written by: Michael M. Deng
% Last updated: 4/22/2016

%% Parse Arguments
p = inputParser;
defaultMethod   = 'MinAssign';
defaultMetCost  = 25;
defaultGapClose = 5;
defaultGreedy   = true;
defaultDiffs = [];
defaultAngle = 0;

p.addParamValue('Method', defaultMethod, @(x) strcmp(x,'MinAssign')||strcmp(x,'SVM'));
p.addParamValue('MetCost', defaultMetCost, @(x) isnumeric(x)&&x>0);
p.addParamValue('GapClose', defaultGapClose, @(x) isnumeric(x)&&mod(x,1)==0&&x>=0);
p.addParamValue('Greedy',defaultGreedy,@(x) islogical(x)||x==1||x==0);
p.addParamValue('Diffs',defaultDiffs,@(x) isnumeric(x));
p.addParamValue('Angle',defaultAngle,@(x) islogical(x));

p.parse(varargin{:});

method   = p.Results.Method;
metCost  = p.Results.MetCost;
gapClose = p.Results.GapClose;
greedy   = p.Results.Greedy;
dataDiffs = p.Results.Diffs;
angle = p.Results.Angle;

%% Function

nFrames = numel(data);
nTMets = numel(data{1});
frameIndex = 0;
rowIndex = cell(nFrames-1, 1);
colIndex = cell(nFrames-1, 1);
unAssignInit = cell(nFrames,1);
unAssignFin = cell(nFrames,1);
cellNum = zeros(nFrames,1);
for i=1:length(data)
    cellNum(i) = numel(data{i}{1});
end
finCosts = cell(nFrames-1,1);

for i=1:nFrames-1
    initData  = data{i};
    finData = data{i+1};
    
    % Calculate links from frame i to frame i+1 from both forward and
    % reverse assignments
    [assignment,unAssignFin{i+1},finCosts{i}] = getMinAssign(initData,finData,dataDiffs,...
        'MetCost',metCost,'Greedy',greedy,'Angle',angle);
    [revassign,~,~] = getMinAssign(finData,initData,dataDiffs,...
        'MetCost',metCost,'Greedy',greedy,'Angle',angle);
    for j=1:length(assignment)
        if assignment(j)>0
            if j~=revassign(assignment(j))
                unAssignFin{i+1}(end+1) = assignment(j);
                assignment(j) = -1;
            end
        end
    end
    
    unAssignInit{i} = find(assignment==-1);
    
    index = 1;
    for j=1:length(assignment)
        if assignment(j)==-1
            continue
        end
        rowIndex{i}(index) = frameIndex+j;
        colIndex{i}(index) = frameIndex+cellNum(i)+assignment(j);
        index = index+1;
    end
    
    frameIndex = frameIndex+cellNum(i);
end

rowIndices = horzcat(rowIndex{:});
colIndices = horzcat(colIndex{:});
links = ones(length(rowIndices),1);
cellTotal = sum(cellNum);
A = sparse(rowIndices, colIndices, links, cellTotal, cellTotal);

frameIndex = 0;
for i=1:nFrames-2
    targetFrameIndex = frameIndex + cellNum(i) + cellNum(i+1);
    
    for j=i+2:min(i+gapClose,nFrames)
        for k=1:nTMets
            initData{k}  = data{i}{k}(unAssignInit{i},:);
            finData{k} = data{j}{k}(unAssignFin{j},:);
        end
        assignment = getMinAssign(initData,finData,dataDiffs,...
            'MetCost',metCost,'Greedy',greedy,'Angle',angle);
        revassign = getMinAssign(finData,initData,dataDiffs,...
            'MetCost',metCost,'Greedy',greedy,'Angle',angle);
        for k=1:length(assignment)
            if assignment(k)>0
                if k==revassign(assignment(k))
                else
                    assignment(k) = -1;
                end
            end
        end
        
        if isempty(initData) || isempty(finData)
            targetFrameIndex = targetFrameIndex + cellNum(j);
            continue
        end
      
        for k =1:numel(assignment)
            if assignment(k) == -1
                continue
            end
            
            rowIndices = frameIndex + unAssignInit{i}(k);
            colIndices = targetFrameIndex + unAssignFin{j}(assignment(k));
            A(rowIndices, colIndices) = 1;
        end
        
        newLinksTarget = assignment~=-1;
        unAssignInit{i}(newLinksTarget) = [];
        unAssignFin{j}(assignment(newLinksTarget)) = [];
        targetFrameIndex = targetFrameIndex + cellNum(j);
    end
    
    frameIndex = frameIndex + cellNum(i);
end

noSource = [];
for i = 1 : size(A, 2)
    if isempty(find(A(:,i),1))
        noSource = [noSource;i];
    end
end

trackNum = numel(noSource);
adjTracks = cell(trackNum,1);
AT = A';

for i=1:trackNum
    tmpHolder = NaN(cellTotal,1);
    target = noSource(i);
    index = 1;
    while ~isempty(target)
        tmpHolder(index) = target;
        target = find(AT(:,target),1,'first');
        index = index + 1;
    end
    adjTracks{i} = tmpHolder(~isnan(tmpHolder));
end

tracks = cell(trackNum,1);
for i=1:trackNum
    adjTrack = adjTracks{i};
    track = NaN(nFrames,1);
    
    for j = 1 : numel(adjTrack)
        cellIndex = adjTrack(j);
        
        tmp = cellIndex;
        frameIndex = 1;
        while tmp > 0
            tmp = tmp - cellNum(frameIndex);
            frameIndex = frameIndex + 1;
        end
        frameIndex = frameIndex - 1;
        
        track(frameIndex) = tmp + cellNum(frameIndex);
    end
    
    tracks{i} = track;
end

count = 1;
while count<=numel(tracks)
    if sum(~isnan(tracks{count}))<=2
        tracks(count) = [];
        count = count-1;
    end
    count = count+1;
end

costTracks = cell(1,length(tracks));
for i=1:length(tracks)
    costTracks{i} = zeros(nFrames,1);
    costTracks{i}(1) = 0;
    for j=1:nFrames-1
        if ~isnan(tracks{i}(j))
            costTracks{i}(j+1) = finCosts{j}(tracks{i}(j));
        end
    end
end

for i=1:length(tracks)
    tracks{i}(isnan(tracks{i})) = 0;
end

end
