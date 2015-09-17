classdef CellTracker < handle
    
    properties
        FileNames
        FileSettings
        FcnSettings
        SaveSettings
        
        ImLoader
        MotionDetect
        
        Data
        TrackData
        DataArray
    end
    
    properties (SetAccess = protected)
        Properties
        Images
        Bounds
        CCs
        MotionData
    end
    
    methods
        
        function obj = CellTracker
            % Constructor.
            obj.Properties = struct('Status','Empty','Meta',datetime);
        end
        
        function init(obj)
            % Function to initialize object and its fields from settings.
            nFrames = obj.FileSettings.NFrames;
            obj.Bounds = cell(nFrames,1);
            obj.CCs  = cell(nFrames,1);
            obj.Data = cell(nFrames,1);
            obj.Properties = struct('Status','Initialized');
        end
        
        function ready(obj)
            % Function to ready object for analysis.
            obj.Properties.Status = 'Ready';
        end
        
        function yn = isReady(obj)
            % Function to check if object ready for analysis
            yn = strcmp(obj.Properties.Status,'Ready');
        end
        
        function initLoad(obj)
            % Function to prep for image loading.
            obj.ImLoader = ImageLoader();
            obj.ImLoader.Method = obj.FileSettings.FileType;
            obj.ImLoader.NFrames = obj.FileSettings.NFrames;
            obj.ImLoader.ImType = obj.FcnSettings.ImType;
            obj.ImLoader.Path = obj.FileSettings.FilePath;
            obj.ImLoader.Resize = obj.FcnSettings.Resize;
            obj.ImLoader.InNames = obj.FileNames;
            obj.ImLoader.initialize();
        end
        
        % Function to load images from objects
        function loadImages(obj)
            obj.ImLoader.loadAll();
        end
        
        % Function to check if loading is finished
        function yn = hasNextImage(obj)
            yn = obj.ImLoader.hasNext();
        end
        
        % Function to load images one by one
        function loadNextImage(obj)
            obj.ImLoader.loadNext();
        end
		
		function finLoad(obj);
			obj.ImLoader.finalize();
		end
        
        % Function to segment objects in image
        function segment(obj,i)
            switch obj.FcnSettings.SegAlg
                case 'EdgeWater'
                    if numel(obj.FcnSettings.SegAlgSett)==2
                        [obj.Bounds{i},obj.CCs{i}] = findCells(obj.Images{i}(:,:,obj.FcnSettings.ObjCh),obj.FcnSettings.SegAlg,...
                            'MinSize',obj.FcnSettings.SegAlgSett{1}{1},'MaxSize',obj.FcnSettings.SegAlgSett{1}{2});
                    elseif numel(obj.FcnSettings.SegAlgSett)==3
                        [obj.Bounds{i},obj.CCs{i}] = findCells(obj.Images{i}(:,:,obj.FcnSettings.ObjCh),obj.FcnSettings.SegAlg,...
                            'MinSize',obj.FcnSettings.SegAlgSett{1}{1},'MaxSize',obj.FcnSettings.SegAlgSett{1}{2},...
                            'Thresh',obj.FcnSettings.SegAlgSett{1}{3});
                    end
                case 'ThreshWater'
                    [obj.Bounds{i},obj.CCs{i}] = findCells(obj.Images{i}(:,:,obj.FcnSettings.ObjCh),obj.FcnSettings.SegAlg,...
                        'MinSize',obj.FcnSettings.SegAlgSett{2}{1},'MaxSize',obj.FcnSettings.SegAlgSett{2}{2},...
                        'MergeObj',obj.FcnSettings.SegAlgSett{2}{3},'PostProc',obj.FcnSettings.SegAlgSett{2}{4});
            end
        end
        
        % Function to characterize objects in image
        function characterize(obj,i)
            obj.Data{i} = getCellData(obj.CCs{i},obj.Images{i},...
                'BkgdCorr',obj.FcnSettings.BkgdCorr);
            obj.MotionData{i} = {obj.Data{i}{1};obj.Data{i}{2};obj.Data{i}{3};obj.Data{i}{6};...
                obj.Data{i}{7};obj.Data{i}{8};obj.Data{i}{11};obj.Data{i}{12};obj.Data{i}{13};...
                obj.Data{i}{16};obj.Data{i}{17};obj.Data{i}{18};obj.Data{i}{19};obj.Data{i}{20};...
                obj.Data{i}{22}};
        end
        
        
        function initMotion(obj)
            % Function to prep for motion detection.
            obj.MotionDetect = MotionDetector();
            obj.MotionDetect.InData = obj.MotionData;
            Settings.Method = 'MinAssign';
            Settings.MetCost = obj.FcnSettings.MetCost;
            Settings.GapClose = obj.FcnSettings.GapClose;
            Settings.Greedy = obj.FcnSettings.Greedy;
            Settings.Diffs = obj.FcnSettings.TrackMets(2,:);
            Settings.Angle = obj.FcnSettings.TrackMets(1,end)==1;
            obj.MotionDetect.Settings = Settings;
            obj.MotionDetect.initialize();
        end
        
        function linkNext(obj)
            % Function to conduct initial motion tracking
            obj.MotionDetect.linkNext();
        end

		function resetMotion(obj)
			% Function to reset motion for 2nd phase (ie gap linking)
		end
        
        function linkNextGap(obj)
            % Function to conduct secondary gap tracking
            obj.MotionDetect.linkNextGap();
        end
        
        function finalMotion(obj)
            % Function to finalize motion tracking
            obj.MotionDetect.finalize();
            obj.TrackData = obj.MotionDetect.TrackData;
        end
        
        % Function to finalize object data for display in GUI
        function finalize(obj)
            nTracks = size(obj.TrackData,1);
            measInd = find(obj.FcnSettings.ObjMets(1,:)==1);
            tmp = zeros(nTracks,obj.FileSettings.NFrames,sum(obj.FcnSettings.ObjMets(1,:),2)+1);
            for k=1:length(measInd)
                for i=1:obj.FileSettings.NFrames
                    for j=1:nTracks
                        currCell = obj.TrackData(j,i);
                        if currCell~=0
                            tmp(j,i,k) = obj.Data{i}{measInd(k)}(currCell);
                        end
                    end
                end
            end
            
            tmp(:,:,end) = obj.TrackData;
            obj.DataArray = tmp;
        end
        
        
        function updateData(obj,newData)
            obj.DataArray = newData;
        end
        
        function addBound(obj,frame,Bound)
            obj.Bounds{frame}{end+1} = Bound;
        end
        
        function addData(obj,frame,data)
            for i=1:numel(obj.Data{frame})
                obj.Data{frame}{i} = [obj.Data{frame}{i};data{i}];
            end
        end
        
        % Function to return images
        function Images = get.Images(obj)
            if isempty(obj.ImLoader)
                Images = [];
            else
                Images = obj.ImLoader.Images;
            end
        end
        
    end
end
