function [Bounds,CCs,pObj] = findCells(Image,method,varargin)
% findCells Find foreground objects in image.
%   Finds object boundaries from input image using either edge detection of
%   thresholding algorithms, where Image is a two-dimensional grayscale
%   image, method is a string 'EdgeWater' or 'ThreshWater' referring to
%   detection algorithm used.
%
%   [B,C,p] = findCells(i,m) returns the detected objects as a cell array
%   of boundaries B, or a structure of connected components CC, as well as
%   the proportion of image area covered by objects p.
%
%   'MinSize' - minimum size for objects (for 'EdgeWater'- refers to object
%       area, for 'ThreshWater'- refers to object radius')
%   'MaxSize' - maximum size for objects (for 'EdgeWater'- refers to object
%       area, for 'ThreshWater'- refers to object radius')
%   'MergeObj' - boolean on whether to merge detected objects
%   'PostProc' - boolean for post processing objects to make edges sharper
%   'PropObj' - approximate proportion of area covered by objects for use
%       in segmentation algorithm
%   'Thresh' - threshold multiplying factor for EW edge detection; 1 by 
%       default
%
% Written by: Michael M. Deng
% Last updated: 4/22/2016

%% ----------INPUT PARSE----------
p = inputParser;

if strcmp(method,'EdgeWater')
    defaultMinSize  = 40;
    defaultMaxSize  = 400;
elseif strcmp(method,'ThreshWater')
    defaultMinSize  = 5;
    defaultMaxSize  = 50;
else
    error('Invalid method argument')
end
defaultMergeObj = false;
defaultPostProc = false;
defaultPObj     = 0.1;
defaultThreshM   = 1.5;

p.addParameter('MinSize',defaultMinSize, @(x) isnumeric(x) && mod(x,1)==0 && x>=0);
p.addParameter('MaxSize',defaultMaxSize, @(x) isnumeric(x) && mod(x,1)==0 && x>=defaultMinSize);
p.addParameter('MergeObj',defaultMergeObj, @(x) islogical(x)||x==0||x==1);
p.addParameter('PostProc',defaultPostProc, @(x) islogical(x)||x==0||x==1);
p.addParameter('PropObj',defaultPObj, @(x) x>0 && x<1);
p.addParameter('ThreshM',defaultThreshM, @(x) isnumeric(x) && x>0);

p.parse(varargin{:});

minSize  = p.Results.MinSize;
maxSize  = p.Results.MaxSize;
mergeObj = p.Results.MergeObj;
postProc = p.Results.PostProc;
pObj     = p.Results.PropObj;
threshM  = p.Results.ThreshM;


%% ----------FUNCTION----------
if strcmp(method,'EdgeWater')
    div = round(sqrt(size(Image,1)*size(Image,2)/maxSize/25));
elseif strcmp(method,'ThreshWater')
    div = round(sqrt(size(Image,1)*size(Image,2)/maxSize/maxSize/pi/10));
end
% Smooth image
sig = 1;
filtLength = 2*sig;
[x,y] = meshgrid(-filtLength:filtLength,-filtLength:filtLength);
gaussBlur = exp(-(x.^2+y.^2)/(2*sig^2));
gaussBlur = gaussBlur/sum(gaussBlur(:));
blurImage = conv2(Image,gaussBlur,'same') ./ conv2(ones(size(Image)),gaussBlur,'same');

if strcmp(method,'EdgeWater')
    %% ----------EDGE-WATERSHED METHOD-----------
    %% Canny edge detection
    [~,thresh] = edge(blurImage,'canny');
    imEdges = edge(Image,'canny',threshM*thresh);
    imBounds = bwconncomp(imEdges,8);
    edgeStats = regionprops(imBounds,'PixelIdxList','BoundingBox');

    %% Construct objects from edge CCs
    edgeCCs = struct('Connectivity',8,'ImageSize',size(Image),'NumObjects',0,'PixelIdxList',[]);
	objMask = zeros(size(Image,1),size(Image,2));
    for i=1:numel(edgeStats)
        tmpMask1 = zeros(size(Image,1),size(Image,2));
        tmpMask2 = tmpMask1;
        tmpMask1(edgeStats(i).PixelIdxList) = 1;
        
        maskX = [edgeStats(i).BoundingBox(1)+.5;...
            edgeStats(i).BoundingBox(1)+.5+edgeStats(i).BoundingBox(3)-1];
        maskY = [edgeStats(i).BoundingBox(2)+.5;...
            edgeStats(i).BoundingBox(2)+.5+edgeStats(i).BoundingBox(4)-1];
        maskX(1) = max(maskX(1)-5,1); maskX(2) = min(maskX(1)+5,size(Image,2));
        maskY(1) = max(maskY(1)-5,1); maskY(2) = min(maskY(1)+5,size(Image,1));
        
        locMask = bwmorph(tmpMask1(maskY(1):maskY(2),maskX(1):maskX(2)),'bridge');
        tmpMask1(maskY(1):maskY(2),maskX(1):maskX(2)) = locMask;
        
        boundStat = regionprops(tmpMask1,'FilledImage','BoundingBox');
        initX = boundStat(1).BoundingBox(1)+.5;
        initY = boundStat(1).BoundingBox(2)+.5;
        tmpMask2(initY:initY+boundStat(1).BoundingBox(4)-1,initX:initX+boundStat(1).BoundingBox(3)-1) = boundStat(1).FilledImage;
        tmpMask2 = imopen(logical(tmpMask2),strel('disk',1));            
        if sum(sum(tmpMask2))>minSize/2&&sum(sum(tmpMask2))<maxSize*2
            objMask = objMask|tmpMask2;
        end
    end

    [edgeBounds,objLabel,nObjs,~] = bwboundaries(objMask);
    edgeCCs.NumObjects = nObjs;
    for i=1:nObjs
        edgeCCs.PixelIdxList{end+1} = find(objLabel==i);
    end
    edgeStats = regionprops(edgeCCs,'PixelIdxList','Area','Centroid','Perimeter','BoundingBox');
    %% Remove extra regions
    tmpCircs = arrayfun(@(x) 4*pi*x.Area/x.Perimeter/x.Perimeter,edgeStats);
    tmpAreas = arrayfun(@(x) x.Area,edgeStats);
    toRemove = tmpCircs<.2|tmpAreas<minSize|tmpAreas>maxSize;
    edgeStats(toRemove) = [];
    edgeBounds(toRemove) = [];
    edgeCCs.NumObjects = edgeCCs.NumObjects-sum(toRemove);
    edgeCCs.PixelIdxList(toRemove) = [];
    %% Remove overlapping edge regions
    toRemove = [];
    for i=1:edgeCCs.NumObjects
        for j=setdiff(1:edgeCCs.NumObjects,i)
            cent1 = edgeStats(i).Centroid;
            cent2 = edgeStats(j).Centroid;
            if (cent1(1)-cent2(1))^2+(cent1(2)-cent2(2))^2<maxSize
                tmpMask1 = zeros(size(Image,1),size(Image,2));
                tmpMask2 = tmpMask1;
                tmpMask1(edgeStats(i).PixelIdxList) = 1;
                tmpMask2(edgeStats(j).PixelIdxList) = 1;
                tmp = logical(tmpMask1)&logical(tmpMask2);
                if sum(tmp(:))>=min([edgeStats(i).Area edgeStats(j).Area])
                    if edgeStats(i).Area>=edgeStats(j).Area
                        toRemove = [toRemove;j];
                    else
                        toRemove = [toRemove;i];
                    end
                end
            end
        end
    end
    toRemove = unique(toRemove);
    edgeStats(toRemove) = [];
    edgeBounds(toRemove) = [];
    edgeCCs.NumObjects = edgeCCs.NumObjects-numel(toRemove);
    edgeCCs.PixelIdxList(toRemove) = [];
    
    Bounds = edgeBounds;
    CCs = edgeCCs;
    Areas = arrayfun(@(x) x.Area,edgeStats,'UniformOutput',true);
    pObj = sum(Areas)/(size(Image,1)*size(Image,2));
elseif strcmp(method,'ThreshWater')
    %% Threshold image to get foreground objects
    try
        [~,imThresh] = getCellThresh(blurImage,'Adapt','Div',div);
    catch err
        if (strcmp(err.identifier,'MATLAB:pmaxsize')||strcmp(err.identifier,'MATLAB:nomem'))
            warning('Image too large for adaptive thresholding. Single threshold performed instead.')
            [~,imThresh] = getCellThresh(blurImage,'Single');
        else
            err
            rethrow(err)
        end
    end
    fgm = Image>imThresh;
    fgm = imopen(imclose(logical(fgm),strel('disk',1)),strel('disk',1));
    %% Further thresholding of clumped cells
    glowIm = Image.*fgm;
    clumps = bwconncomp(glowIm,8);
    clumpStats = regionprops(clumps,'PixelIdxList','Area');
    fgmNew = zeros(size(Image,1),size(Image,2));
    for i=1:length(clumpStats)
        tmpMask = zeros(size(Image,1),size(Image,2));
        if clumpStats(i).Area>minSize*maxSize*pi
            oldPix = clumpStats(i).PixelIdxList;
            tmpGlow = glowIm(clumpStats(i).PixelIdxList);
            [tmp,glowThresh1] = otsu(tmpGlow,2);
            [~,glowThresh2] = MoG(tmpGlow,sum(sum(tmp-1))/numel(tmpGlow));
            newPix = oldPix(tmpGlow>mean([glowThresh1 glowThresh2]));
            tmpMask(newPix) = 1;
            tmpMask = bwareaopen(tmpMask,minSize^2);
            tmpMask = imclearborder(tmpMask,8);
            tmpMask = imopen(imclose(logical(tmpMask),strel('disk',1)),strel('disk',1));
            fgmNew(tmpMask) = 1;
        else
            fgmNew(clumpStats(i).PixelIdxList) = 1;
        end
    end
    fgmNew = imfill(fgmNew,'holes');
    %% Determine image maxima and perform watershed segmentation
    imMaxima = fgmNew;
    imLocalMaxima = bwdist(imMaxima)<minSize;
    watershedMask = imimposemin(1-Image,imLocalMaxima);
    tmp = watershed(watershedMask)>0;
    Objects = fgmNew.*tmp;
    %% Label initial cell objects
    initCells = bwconncomp(Objects);
    if mergeObj
        initCells = MergeObjects(initCells,Image,[5 50]);
    end
    initStats  = regionprops(initCells,'Area','PixelIdxList');
    nBounds = length(initStats);
    %% Create boundaries for initial cell objects
    if ~postProc
        CCs = struct('Connectivity',8,'ImageSize',size(Image),'NumObjects',0,'PixelIdxList',[]);
        Bounds = cell(length(initStats),1);
        for i=1:nBounds
            tmpMask = zeros(size(Image,1),size(Image,2));
            tmpMask(initStats(i).PixelIdxList) = 1;
            tmpMask = imclose(logical(tmpMask),strel('disk',1));
            tmpMask = imclearborder(tmpMask);
            tmp = bwboundaries(tmpMask);
            if ~isempty(tmp)&&initStats(i).Area>(minSize^2)&&initStats(i).Area<(maxSize^2*pi)
                Bounds{i} = tmp{1};
                CCs.NumObjects = CCs.NumObjects+1;
                CCs.PixelIdxList{end+1} = find(tmpMask==1);
            end
        end
        Bounds = Bounds(cellfun(@(x) ~isempty(x),Bounds));
        Areas = arrayfun(@(x) x.Area,initStats,'UniformOutput',true);
        pObj = sum(Areas)/(size(Image,1)*size(Image,2));
        CCs.NumObjects = CCs.NumObjects-sum(cellfun(@(x) isempty(x),CCs.PixelIdxList));
        CCs.PixelIdxList = CCs.PixelIdxList(cellfun(@(x) ~isempty(x),CCs.PixelIdxList)==1);
    %% Post Process cell objects
    else
        newBounds = [];
        newAreas  = [];
        CCs = struct('Connectivity',8,'ImageSize',size(Image),'NumObjects',0,'PixelIdxList',[]);
        for i=1:nBounds
            if initStats(i).Area>minSize^2*pi&&initStats(i).Area<maxSize^2*pi       % Area limits
                oldPix = initStats(i).PixelIdxList;
                [tmp,newThresh1,~] = otsu(Image(oldPix),2);
                [~,newThresh2] = MoG(Image(oldPix),sum(sum(tmp-1))/(size(Image,1)*size(Image,2)));
                newMask = zeros(size(Image,1),size(Image,2));
                newPix = oldPix(Image(oldPix)>min([newThresh1 newThresh2]));
                newMask(newPix) = 1;
                newMask = imclose(logical(newMask),strel('disk',2));
                newMask = imclearborder(newMask);
                newStats = regionprops(bwconncomp(newMask),'Area','PixelIdxList');
                if numel(newStats)==1
                    if newStats.Area>minSize^2
                        tmp = bwboundaries(newMask);
                        newBounds{size(newBounds,1)+1,1} = tmp{1};
                        newAreas = [newAreas;newStats.Area];
                        CCs.NumObjects = CCs.NumObjects+1;
                        CCs.PixelIdxList{end+1} = find(newMask==1);
                    end
                elseif numel(newStats)>1
                    tmp = bwboundaries(newMask);
                    for j=1:numel(newStats)
                        if newStats(j).Area>minSize^2
                            newBounds{size(newBounds,1)+1,1} = tmp{j};
                            newAreas = [newAreas;newStats(j).Area];
                            CCs.NumObjects = CCs.NumObjects+1;
                            CCs.PixelIdxList{end+1} = newStats(j).PixelIdxList;
                        end
                    end
                end
            end
        end
        Bounds = newBounds;
        pObj = sum(newAreas)/(size(Image,1)*size(Image,2));
        CCs.NumObjects = CCs.NumObjects-sum(cellfun(@(x) isempty(x),CCs.PixelIdxList));
        CCs.PixelIdxList = CCs.PixelIdxList(cellfun(@(x) ~isempty(x),CCs.PixelIdxList)==1);
    end
else
end
%% Sort output boundaries by position
xpos = cellfun(@(x) mean(x(:,2)),Bounds);
[~,possort] = sort(xpos,'ascend');
Bounds  = Bounds(possort);
CCs.PixelIdxList = CCs.PixelIdxList(possort);

end