classdef ImageLoader < handle
    
    properties
        Method
        NFrames
        ImType
        Path
        Resize
        
        InNames
    end
    
    properties (SetAccess = protected)
        Status
        FrameInds
        
        Images
        OutNames
		PrevWarn
    end
    
    methods
        
        % Constructor
        function obj = ImageLoader
            obj.Method = 'File';
            obj.NFrames = 100;
            obj.FrameInds = 1:100;
            obj.ImType = 'RGB';
            obj.Path = pwd;
            obj.Resize = 1;
            obj.Status = 0;
        end
        
        % Function to prep loader for loading
        function initialize(obj)
			% Disable TIFF library warnings
			tmpStruct = warning('query','last');
			if strcmp(tmpStruct.state,'on')
				PrevWarn = true;
			else
				PrevWarn = false;
			end
			warning('off');

            switch obj.Method
                case 'File'
                    switch obj.ImType
                        case {'RGB','Gray'}
                            obj.NFrames = numel(obj.InNames);
                        case 'Split'
                            obj.NFrames = numel(obj.InNames{1});
                    end
                case 'Base'
                    if numel(obj.NFrames)>1
                        obj.FrameInds = obj.NFrames;
                        obj.NFrames = numel(obj.NFrames);
                    elseif numel(obj.NFrames)==1
                        obj.FrameInds = 1:obj.NFrames;
                    end
            end
            
            obj.Images = cell(obj.NFrames,1);
            obj.OutNames = cell(obj.NFrames,1);
            addpath(obj.Path);
        end
        
        % Function to load all images
        function loadAll(obj)
            for i=1:obj.NFrames
                switch obj.Method
                    case 'File'
                        switch obj.ImType
                            case {'RGB','Gray'}
                                tmp = Tiff(obj.InNames{i});
                                obj.Images{i} = tmp.read();
                                obj.OutNames{i} = obj.InNames{i};
                            case 'Split'
                                tmp = {Tiff(obj.InNames{1}{i}),Tiff(obj.InNames{2}{i}),Tiff(obj.InNames{3}{i})};
                                obj.Images{i} = cat(3,tmp{1}.read(),tmp{2}.read(),tmp{3}.read());
                                obj.OutNames{1}{i} = obj.InNames{1}{i};
                                obj.OutNames{2}{i} = obj.InNames{2}{i};
                                obj.OutNames{3}{i} = obj.InNames{3}{i};
                        end
                    case 'Base'
                        switch obj.ImType
                            case {'RGB','Gray'}
                                tmpName = sprintf(obj.InNames,obj.FrameInds(i));
                                tmp = Tiff(tmpName);
                                obj.Images{i} = tmp.read();
                                obj.OutNames{i} = tmpName;
                            case 'Split'
                                tmpName = {sprintf(obj.InNames{1},obj.FrameInds(i)),sprintf(obj.InNames{2},obj.FrameInds),sprintf(obj.InNames{3},obj.FrameInds)};
                                tmp = {Tiff(tmpName{1}),Tiff(tmpName{2}),Tiff(tmpName{3})};
                                obj.Images{i} = cat(3,tmp{1}.read(),tmp{2}.read(),tmp{3}.read());
                                obj.OutNames{1}{i} = tmpName{1};
                                obj.OutNames{2}{i} = tmpName{2};
                                obj.OutNames{3}{i} = tmpName{3};
                        end
                end
                
                if strcmp(obj.ImType,'Gray')
                    obj.Images{i} = cat(3,obj.Images{i},obj.Images{i},pbj.Images{i});
                end
                
                if obj.Resize~=1
                    obj.Images{i} = imresize(obj.Images{i},obj.Resize);
                end
                
                obj.Status = i;
            end
            
            obj.Images = cellfun(@(x) double(x),obj.Images,'UniformOutput',false);
            rmpath(obj.Path);
        end
        
        % Function to determine whether more images need to be loaded
        function yn = hasNext(obj)
            yn = obj.Status<obj.NFrames;
        end
        
        % Function to load images 1 at a time
        function loadNext(obj)
            i = obj.Status+1;
            switch obj.Method
                case 'File'
                    switch obj.ImType
                        case {'RGB','Gray'}
                            tmp = Tiff(obj.InNames{i});
                            obj.Images{i} = tmp.read();
                            obj.OutNames{i} = obj.InNames{i};
                        case 'Split'
                            tmp = {Tiff(obj.InNames{1}{i}),Tiff(obj.InNames{2}{i}),Tiff(obj.InNames{3}{i})};
                            obj.Images{i} = cat(3,tmp{1}.read(),tmp{2}.read(),tmp{3}.read());
                            obj.OutNames{1}{i} = obj.InNames{1}{i};
                            obj.OutNames{2}{i} = obj.InNames{2}{i};
                            obj.OutNames{3}{i} = obj.InNames{3}{i};
                    end
                case 'Base'
                    switch obj.ImType
                        case {'RGB','Gray'}
                            tmpName = sprintf(obj.InNames,obj.FrameInds(i));
                            tmp = Tiff(tmpName);
                            obj.Images{i} = tmp.read();
                            obj.OutNames{i} = tmpName;
                        case 'Split'
                            tmpName = {sprintf(obj.InNames{1},obj.FrameInds(i)),sprintf(obj.InNames{2},obj.FrameInds),sprintf(obj.InNames{3},obj.FrameInds)};
                            tmp = {Tiff(tmpName{1}),Tiff(tmpName{2}),Tiff(tmpName{3})};
                            obj.Images{i} = cat(3,tmp{1}.read(),tmp{2}.read(),tmp{3}.read());
                            obj.OutNames{1}{i} = tmpName{1};
                            obj.OutNames{2}{i} = tmpName{2};
                            obj.OutNames{3}{i} = tmpName{3};
                    end
            end
            
            if strcmp(obj.ImType,'Gray')
                obj.Images{i} = cat(3,obj.Images{i},obj.Images{i},obj.Images{i});
            end
            
            if obj.Resize~=1
                obj.Images{i} = imresize(obj.Images{i},obj.Resize);
            end
            
            obj.Status = i;
            if obj.Status==obj.NFrames
                obj.Images = cellfun(@(x) double(x),obj.Images,'UniformOutput',false);
                rmpath(obj.Path);
            end
        end

		function finalize(obj)
			% Reenable Tiff library warnings if necessary
			if PrevWarn
				warning('on');
			else
				warning('off');
			end
		end
        
    end
    
end
