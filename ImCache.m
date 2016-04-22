classdef ImCache
% ImCache Wrapper class for caching microscopy images for faster viewing.
% 	The ImCache class attempts to cache recent and nearby images for faster
% 	loading on the CellTracking GUI.
%
% Written by: Michael M. Deng
% Last updated: 4/22/2016
    
    properties
        NBlocks
        BlockSize
        Blocks
        Images
    end
    
    properties (SetAccess = protected)
        LUR
    end
    
    methods
        function cache = ImCache
            if  nargin > 0
                cache.NBlocks = NB;
                cache.BlockSize = BS;
            else
                cache.NBlocks = 1;
                cache.BlockSize = 1;
            end
            
            cache.LRU = [1 2 3];
            cache.Blocks = cell(cache.NBlocks,1);
            cache.Images = cell(cache.NBlocks,1);
        end
        
        function loadBlock(cache,index,Ims)
            start = cache.BlockSize*floor(index/cache.BlockSize)+1;
            last = start+cache.BlockSize-1;
            
            for i=start:min(last,numel(Ims))
                % get image
                
            end
        end
    end
    
end

