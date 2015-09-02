function [corrNucIm,corrTrackIms] = getBkgdImage(nucImage,trackImages,method,filtSize)
% Get background level for input image using either a Gaussian blurring
% method or a SKIZ method. nucImage is image containing foreground objects,
% while trackImages is a 2x1 cell array containing the images for the other
% 2 image channels. method is a string with either 'Gauss' or 'SKIZ'
% indicating the method to be used. filtSize refers to the size of the
% Gaussian filter to be used, which can be estimated as twice the area of
% the largest object in the image.
%
% [CNI,CTI] = getBkgdImage(n,t,m,f) returns the object channel image with 
% background intensity subtracted, as well as other image channels in a
% cell array in CTI.
%
% Written by: Michael M. Deng
% Last updated: 1/25/15

switch method
    case 'Gauss'
        %% Gaussian blur image and subtract from image
        G = fspecial('gaussian',[filtSize filtSize],filtSize/3);
        blurImage = double(imfilter(nucImage,G,'same','symmetric'));
        corrNucIm = double(nucImage)-blurImage;
        blurImage = double(imfilter(trackImages{1},G,'same','symmetric'));
        corrTrackIms{1} = double(trackImages{1})-blurImage;
        blurImage = double(imfilter(trackImages{2},G,'same','symmetric'));
        corrTrackIms{2} = double(trackImages{2})-blurImage;
    case 'SKIZ'
        %% Determine nuclear and tracking foreground objects
        div = round(sqrt(size(nucImage,1)*size(nucImage,2)/filtSize/4));
        nucFgm = getCellThresh(nucImage,'Adapt','Div',div);
        nucFgm = imopen(imclose(nucFgm,strel('disk',1)),strel('disk',1));
        nucFgm = imdilate(nucFgm,strel('disk',1));
        t1Fgm = getCellThresh(trackImages{1},'Adapt','Div',div);
        t1Fgm = imopen(imclose(t1Fgm,strel('disk',1)),strel('disk',1));
        t1Fgm = imdilate(t1Fgm,strel('disk',1));
        t2Fgm = getCellThresh(trackImages{2},'Adapt','Div',div);
        t2Fgm = imopen(imclose(t2Fgm,strel('disk',1)),strel('disk',1));
        t2Fgm = imdilate(t2Fgm,strel('disk',1));
        %% Subtract SKIZ from nuclear image
        nucBg = watershed(bwdist(nucFgm))==0;
        nucBg(1:end,1) = 1; nucBg(1:end,end) = 1; nucBg(1,1:end) = 1; nucBg(end,1:end) = 1;      
        nucBgBound = bwboundaries(nucBg,8);
        nucBgBound(1) = [];
        nucBgMask = zeros(size(nucImage,1),size(nucImage,2));
        for i=1:length(nucBgBound)
            inds = (nucBgBound{i}(:,2)-1)*size(nucImage,1)+nucBgBound{i}(:,1);
            nucBgMask(inds) = 1;
        end
        nucCCs = bwconncomp(nucBgMask);
        nucStats = regionprops(nucCCs,'PixelIdxList','FilledImage','BoundingBox');
        corrNucIm = nucImage;
        for i=1:length(nucStats)
            bkgdLevel = mean(nucImage(nucStats(i).PixelIdxList));
            initX = nucStats(i).BoundingBox(1)+.5;
            initY = nucStats(i).BoundingBox(2)+.5;
            tmpMask = zeros(size(nucImage,1),size(nucImage,2));
            tmpMask(initY:initY+nucStats(i).BoundingBox(4)-1,initX:initX+nucStats(i).BoundingBox(3)-1) = nucStats(i).FilledImage;
            corrNucIm(logical(tmpMask)) = corrNucIm(logical(tmpMask))-bkgdLevel;
        end
        %% Subtrack SKIZ from track image 1
        t1Bg = watershed(bwdist(nucFgm|t1Fgm))==0;
        t1Bg(1:end,1) = 1; t1Bg(1:end,end) = 1; t1Bg(1,1:end) = 1; t1Bg(end,1:end) = 1;
        t1BgBound = bwboundaries(t1Bg,8);
        t1BgBound(1) = [];
        t1BgMask = zeros(size(nucImage,1),size(nucImage,2));
        for i=1:length(t1BgBound)
            inds = (t1BgBound{i}(:,2)-1)*size(nucImage,1)+t1BgBound{i}(:,1);
            t1BgMask(inds) = 1;
        end
        t1CCs = bwconncomp(t1BgMask);
        t1Stats = regionprops(t1CCs,'PixelIdxList','FilledImage','BoundingBox');
        corrTrackIms{1} = trackImages{1};
        for i=1:length(t1Stats)
            bkgdLevel = mean(trackImages{1}(t1Stats(i).PixelIdxList));
            initX = t1Stats(i).BoundingBox(1)+.5;
            initY = t1Stats(i).BoundingBox(2)+.5;
            tmpMask = zeros(size(nucImage,1),size(nucImage,2));
            tmpMask(initY:initY+t1Stats(i).BoundingBox(4)-1,initX:initX+t1Stats(i).BoundingBox(3)-1) = t1Stats(i).FilledImage;
            corrTrackIms{1}(logical(tmpMask)) = corrTrackIms{1}(logical(tmpMask))-bkgdLevel;
        end
        %% Subtract SKIZ from track image 2
        t2Bg = watershed(bwdist(nucFgm|t2Fgm))==0;
        t2Bg(1:end,1) = 1; t2Bg(1:end,end) = 1; t2Bg(1,1:end) = 1; t2Bg(end,1:end) = 1;
        t2BgBound = bwboundaries(t2Bg,8);
        t2BgBound(1) = [];
        t2BgMask = zeros(size(nucImage,1),size(nucImage,2));
        for i=1:length(t2BgBound)
            inds = (t2BgBound{i}(:,2)-1)*size(nucImage,1)+t2BgBound{i}(:,1);
            t2BgMask(inds) = 1;
        end
        t2CCs = bwconncomp(t2BgMask);
        t2Stats = regionprops(t2CCs,'PixelIdxList','FilledImage','BoundingBox');
        corrTrackIms{2} = trackImages{2};
        for i=1:length(t2Stats)
            bkgdLevel = mean(trackImages{2}(t2Stats(i).PixelIdxList));
            initX = t2Stats(i).BoundingBox(1)+.5;
            initY = t2Stats(i).BoundingBox(2)+.5;
            tmpMask = zeros(size(nucImage,1),size(nucImage,2));
            tmpMask(initY:initY+t2Stats(i).BoundingBox(4)-1,initX:initX+t2Stats(i).BoundingBox(3)-1) = t2Stats(i).FilledImage;
            corrTrackIms{2}(logical(tmpMask)) = corrTrackIms{2}(logical(tmpMask))-bkgdLevel;
        end
        
    otherwise
        error('Invalid background correct method')
end

switch method
    case 'Gauss'
        corrNucIm(corrNucIm<0) = 0;
        corrTrackIms{1}(corrTrackIms{1}<0) = 0;
        corrTrackIms{2}(corrTrackIms{1}<0) = 0;
    otherwise
        corrNucIm = corrNucIm-min(min(corrNucIm));
        corrTrackIms{1} = corrTrackIms{1}-min(min(corrTrackIms{1}));
        corrTrackIms{2} = corrTrackIms{2}-min(min(corrTrackIms{2}));
end

end

