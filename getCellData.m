function [cellData] = getCellData(CCs,Image,varargin)
% Calculate metrics for objects in an image. CCs is a structure of
% connected components in image Image.
% 
% C = getCellData(c,i) returns a cell array with size equal to the number
% of objects, with each cell containing a vector of object measurements.
%
%   'ImAssign' - which image channel to use as object channel
%   'BkgdCorr' - method for background correction using getCellBkgd
%       function; either 'Gauss' or 'SKIZ'
%   'FiltSize' - filter size for getCellBkgd function for 'Gauss'
%       background correction
%
% Written by: Michael M. Deng
% Last updated: 1/25/15

%% ----------INPUT PARSE----------
p = inputParser;
defaultImAssign = 1;
defaultBkgdCorr = 'None';
defaultFiltSize = 500;

p.addParamValue('ImAssign',defaultImAssign,@(x) x<=3 && x>=1 && mod(x,1)==0);
p.addParamValue('BkgdCorr',defaultBkgdCorr,@(x) strcmp(x,'None')||strcmp(x,'Gauss')||strcmp(x,'SKIZ'))
p.addParamValue('FiltSize',defaultFiltSize,@(x) isnumeric(x)&&x>=0);

p.parse(varargin{:});

imageAssign = p.Results.ImAssign;
bkgdCorr = p.Results.BkgdCorr;
filtSize = p.Results.FiltSize;

%% ----------FUNCTION----------
boundNum = CCs.NumObjects;
%% Initial image assignment
tmp = 1:3;
nucImage = Image(:,:,imageAssign);
rest = tmp(tmp~=imageAssign);
trackImage = {Image(:,:,rest(1)),Image(:,:,rest(2))};
%% Generate background corrected images
switch bkgdCorr
    case 'None'
        corrNucIm = nucImage;
        corrTrackIms = trackImage;
    case 'Gauss'
        [corrNucIm,corrTrackIms] = getBkgdImage(nucImage,trackImage,bkgdCorr,filtSize);
    case 'SKIZ'
        [corrNucIm,corrTrackIms] = getBkgdImage(nucImage,trackImage,bkgdCorr,filtSize);
    otherwise
        error('Invalid background correction method.')
end
%% Pre-allocate memory
nucmean = zeros(boundNum,1);
nucmed  = zeros(boundNum,1);
nucstd  = zeros(boundNum,1);
nucmin  = zeros(boundNum,1);
nucmax  = zeros(boundNum,1);
t1mean  = zeros(boundNum,1);
t1med   = zeros(boundNum,1);
t1std   = zeros(boundNum,1);
t1min   = zeros(boundNum,1);
t1max   = zeros(boundNum,1);
t2mean  = zeros(boundNum,1);
t2med   = zeros(boundNum,1);
t2std   = zeros(boundNum,1);
t2min   = zeros(boundNum,1);
t2max   = zeros(boundNum,1);
dens    = zeros(boundNum,1);
%% Get basic boundary measurement
CCStats = regionprops(CCs,'Area','Perimeter','Centroid','Orientation');
area    = arrayfun(@(x) x.Area,CCStats);
perim   = arrayfun(@(x) x.Perimeter,CCStats);
xpos    = arrayfun(@(x) x.Centroid(1),CCStats);
ypos    = arrayfun(@(x) x.Centroid(2),CCStats);
circ    = arrayfun(@(x) 4*pi*x.Area/x.Perimeter/x.Perimeter,CCStats);
orient  = arrayfun(@(x) x.Orientation,CCStats);
%% Get fluorescence measurements
for i=1:boundNum
    nucInts = corrNucIm(CCs.PixelIdxList{i});
    t1Ints = corrTrackIms{1}(CCs.PixelIdxList{i});
    t2Ints = corrTrackIms{2}(CCs.PixelIdxList{i});
    nucmean(i) = mean(nucInts);
    nucmed(i) = median(nucInts);
    nucstd(i) = std(nucInts);
    nucmin(i) = min(nucInts);
    nucmax(i) = max(nucInts);
    t1mean(i) = mean(t1Ints);
    t1med(i) = median(t1Ints);
    t1std(i) = std(t1Ints);
    t1min(i) = min(t1Ints);
    t1max(i) = max(t1Ints);
    t2mean(i) = mean(t2Ints);
    t2med(i) = median(t2Ints);
    t2std(i) = std(t2Ints);
    t2min(i) = min(t2Ints);
    t2max(i) = max(t2Ints);
end

% Calculate local cell density
numRads = 200;
closeCells = zeros(numRads,boundNum);
closeArea  = zeros(numRads,boundNum);
rs = linspace(round(sqrt(area(i)/pi)),min(size(Image(:,:,1)))/2,numRads);
for i=1:boundNum
    locNum = @(x,y,xi,yi,r) sum(((x-xi).^2+(y-yi).^2-r^2)<=0);
    [tmpX,tmpY] = meshgrid(1:size(Image,2),1:size(Image,1));
    locArea = @(x,y,r) sum(sum(((tmpX-x).^2+(tmpY-y).^2-r^2)<=0));
    currX = xpos(i);
    currY = ypos(i);
    otherX = xpos(setdiff(1:boundNum,i));
    otherY = ypos(setdiff(1:boundNum,i));
    for j=1:numRads
        verts = [0.5;size(Image,2)-.5;0.5;size(Image,1)-.5];
        numS = sum(abs(verts(1:2)-currX)<rs(j))+sum(abs(verts(3:4)-currY)<rs(j));
        numV = locNum(currX,currY,[0;0;size(Image,2);size(Image,2)],[0;size(Image,1);0;size(Image,1)],rs(j));
        % Algorithm to calculate overlap area of current circle surrounding
        % cell and image rectangle (faster than calculating distance for
        % each index of image)
        if numS==0&&numV==0
            closeArea(j,i) = pi*rs(j)^2;
        elseif numS==1&&numV==0
            tmp = abs(verts-[currX;currX;currY;currY]);
            h = tmp(tmp<rs(j));
            theta = acos(h/rs(j));
            circA = pi*rs(j)*rs(j);
            sectA = theta*rs(j)*rs(j);
            triA = 0.5*sin(2*theta)*rs(j)*rs(j);
            segA = sectA-triA;
            closeArea(j,i) = circA-segA;
        elseif numS==2&&numV==0
            tmp = abs(verts-[currX;currX;currY;currY]);
            h = tmp(tmp<rs(j));
            theta = acos(h/rs(j));
            circA = pi*rs(j)*rs(j);
            sectA = theta*rs(j)*rs(j);
            triA = 0.5*sin(2*theta)*rs(j)*rs(j);
            segA = sectA-triA;
            closeArea(j,i) = circA-sum(segA);
        elseif numS==2&&numV==1
            tmp = abs(verts-[currX;currX;currY;currY]);
            h = tmp(tmp<rs(j));
            theta = acos(h/rs(j));
            L = rs(j)*sin(theta)+h(end:-1:1);
            triA = 0.5*L(1)*L(2);
            phi = 1.5*pi-sum(theta);
            secA = phi/2*rs(j)*rs(j);
            trigA = 0.5*rs(j)*rs(j)*sin(phi);
            segA = secA-trigA;
            closeArea(j,i) = triA+segA;
        else
            closeArea(j,i)  = locArea(currX,currY,rs(j));
        end
        closeCells(j,i) = locNum(currX,currY,otherX,otherY,rs(j));
    end
    tmpDens = sum(closeCells(:,i),2)./closeArea(:,i);
    dens(i) = 10000*trapz(rs,tmpDens)/(max(rs)-min(rs));
end

%% ----------OUTPUT----------
cellData = {nucmean nucmed nucstd nucmin nucmax...
    t1mean t1med t1std t1min t1max...
    t2mean t2med t2std t2min t2max...
    area perim xpos ypos circ dens orient};

for i=1:length(cellData)
    if sum(cellData{i}==0)>0
        cellData{i}(cellData{i}==0) = realmin;
    end
end

end