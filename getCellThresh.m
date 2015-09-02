function [threshIm,imThresh] = getCellThresh(Image,method,varargin)
% Calculates threshold for object detection for given image, using either a
% local adaptive or a global method. Image is a two-dimensional grayscale
% input image, while method is a string of either 'Single' or 'Adapt',
% indicating which mthod to use.
% 
% [T,I] = getCellThresh(i,m) returns a binary image representing the
% thresholded pixels in T and the threshold value in I
% 
%   'Div' - number of divisions to use for each dimension of image to
%       calculate local threshold in each division.
%
% Written by: Michael Deng
% Last edited: 1/25/15

%% ----------INPUT PARSE----------
p = inputParser;
defaultDiv = 1;
p.addParamValue('Div',defaultDiv, @(x) isnumeric(x) && x>=1);
p.parse(varargin{:});
div = p.Results.Div;


%% FUNCTION
%% Blur image first to remove noise
sig = 1;
filtLength = 2*sig;
[x,y] = meshgrid(-filtLength:filtLength,-filtLength:filtLength);
gaussBlur = exp(-(x.^2+y.^2)/(2*sig^2));
gaussBlur = gaussBlur/sum(gaussBlur(:));
BlurImage = conv2(Image,gaussBlur,'same') ./ conv2(ones(size(Image)),gaussBlur,'same');

%% Perform thresholding using Otsu's method
if strcmp(method,'Single')
    [~,OThresh] = otsu(BlurImage,2);
    [~,MoGThresh] = MoG(BlurImage,sum(sum(BlurImage>OThresh))/(size(BlurImage,1)*size(BlurImage,2)));
    imThresh = mean([OThresh MoGThresh]);
    threshIm = BlurImage>imThresh;
%% Perform adaptive thresholding using Otsu's method at local areas
elseif strcmp(method,'Adapt')
    xDiv = round(size(Image,2)/div);
    yDiv = round(size(Image,1)/div);
    
    numXDiv = size(Image,2)+1-xDiv;
    numYDiv = size(Image,1)+1-xDiv;
    vertThresh = zeros(size(Image,1),size(Image,2));
    vertNum = zeros(size(Image,1),size(Image,2));
    horizThresh = zeros(size(Image,1),size(Image,2));
    horizNum = zeros(size(Image,1),size(Image,2));
    
    for i=1:numXDiv
        Pix = BlurImage(:,i:i+xDiv-1);
        Pix = Pix(:);
        thresh = otsuThresh(Pix,2);
        vertThresh(:,i:i+xDiv-1) = vertThresh(:,i:i+xDiv-1)+thresh;
        vertNum(:,i:i+xDiv-1) = vertNum(:,i:i+xDiv-1)+1;
    end
    for i=1:numYDiv
        Pix = BlurImage(i:i+yDiv-1,:);
        Pix = Pix(:);
        thresh = otsuThresh(Pix,2);
        horizThresh(i:i+yDiv-1,:) = horizThresh(i:i+yDiv-1,:)+thresh;
        horizNum(i:i+yDiv-1,:) = horizNum(i:i+yDiv-1,:)+1;
    end
    
    threshAv = (vertThresh+horizThresh)./(vertNum+horizNum);
    imThresh = sum(threshAv,3)./sum(threshAv~=0,3);
    threshIm = Image>imThresh;
    % imThresh = conv2(imThresh,gaussBlur,'same') ./ conv2(ones(size(imThresh)),gaussBlur,'same');
else
    error('Invalid method argument');
end



end

