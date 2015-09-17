classdef MotionDetector < handle
    % Class to handle motion detection of objects. Allows updating of
    % original track information to re-link tracks from new data.
    
    properties
        InData
        Settings
    end
    
    properties (SetAccess = protected)
        TrackData
        Tracks
        NFrames
        NMets
    end
    
    properties (Access = protected)
        CurrFrame
        CellNum
        AdjMat
        RowLink
        ColLink
        UnlinkFrom
        UnlinkTo
    end
    
    methods
        
        function obj = MotionDetecting
            % Constructor.
            obj.Settings.Method = 'MinAssign';
            obj.Settings.MetCost = 25;
            obj.Settings.GapClose = 5;
            obj.Settings.Greedy = true;
            obj.Settings.Diffs = [];
            obj.Settings.Angle = 0;
        end
        
        
        function initialize(obj)
            % Function to initialize object for motion detection. Execute
            % this before any tracking (including re-linking).
            obj.NFrames = numel(obj.InData);
            obj.NMets = numel(obj.InData{1});
            obj.CellNum = [];
            for i=1:obj.NFrames
                NCells = numel(obj.InData{i}{1});
                next = [i*ones(NCells,1),(1:NCells)'];
                obj.CellNum = [obj.CellNum;next];
            end
            obj.CellNum = [obj.CellNum,(1:size(obj.CellNum,1))'];
            obj.CurrFrame = 1;
            obj.RowLink = []; obj.ColLink = [];
            obj.UnlinkFrom = cell(obj.NFrames,1);
            obj.UnlinkTo = cell(obj.NFrames,1);
            for i=1:obj.NFrames-1
                obj.UnlinkFrom{i} = 1:sum(obj.CellNum(:,1)==i);
                obj.UnlinkTo{i+1} = 1:sum(obj.CellNum(:,1)==(i+1));
            end
            obj.AdjMat = [];
        end
        
        
        function linkAll(obj)
            % Function to conduct (re)linking of all objects in all frames.
            for i=1:obj.NFrames-1
                linkNext(obj);
            end

            obj.restart();
            for i=1:obj.NFrames-obj.Settings.GapClose
                linkNextGap(obj);
            end
        end

        
        function linkNext(obj)
            % Function to (re)link objects in next frame.
            
            Init= cell(obj.NMets,1); Fin = cell(obj.NMets,1);
            for i=1:obj.NMets
                Init{i} = obj.InData{obj.CurrFrame}{i}(obj.UnlinkFrom{obj.CurrFrame},:);
                Fin{i} = obj.InData{obj.CurrFrame+1}{i}(obj.UnlinkTo{obj.CurrFrame+1},:);
            end
            if isempty(Fin{1})||isempty(Init{1})
                return
            end

            assign = getMinAssign(Init,Fin,obj.Settings.Diffs,...
                'MetCost',obj.Settings.MetCost,'Greedy',obj.Settings.Greedy,'Angle',obj.Settings.Angle);
            revassign = getMinAssign(Fin,Init,obj.Settings.Diffs,...
                'MetCost',obj.Settings.MetCost,'Greedy',obj.Settings.Greedy,'Angle',obj.Settings.Angle);
            for i=1:length(assign)
                if assign(i)>0 && i~=revassign(assign(i))
                    assign(i) = -1;
                end
            end

            % Convert assignment to adjacency
            for i=1:length(assign)
                if assign(i)==-1
                    continue
                end
                currRowInd = obj.UnlinkFrom{obj.CurrFrame}(i);
                currColInd = obj.UnlinkTo{obj.CurrFrame+1}(assign(i));
                obj.RowLink(end+1) = obj.CellNum(obj.CellNum(:,1)==obj.CurrFrame & obj.CellNum(:,2)==currRowInd,3);
                obj.ColLink(end+1) = obj.CellNum(obj.CellNum(:,1)==obj.CurrFrame+1 & obj.CellNum(:,2)==currColInd,3);
            end
            
            % Remove new assignments for next round of linking
            NewLinks = assign~=-1;
            obj.UnlinkFrom{obj.CurrFrame}(NewLinks) = [];
            obj.UnlinkTo{obj.CurrFrame+1}(assign(NewLinks)) = [];

            obj.CurrFrame = obj.CurrFrame+1;
        end
        
        
        function linkNextGap(obj)
            % Function to (re)link objects across gap in next frame.
            
            for i=obj.CurrFrame+2:min(obj.CurrFrame+obj.Settings.GapClose,obj.NFrames)
                % Get forward and backward assignment
                Init= cell(obj.NMets,1); Fin = cell(obj.NMets,1);
                for j=1:obj.NMets
                    Init{j} = obj.InData{obj.CurrFrame}{j}(obj.UnlinkFrom{obj.CurrFrame},:);
                    Fin{j} = obj.InData{i}{j}(obj.UnlinkTo{i},:);
                end
                
                assign = getMinAssign(Init,Fin,obj.Settings.Diffs,...
                    'MetCost',obj.Settings.MetCost,'Greedy',obj.Settings.Greedy,'Angle',obj.Settings.Angle);
                revassign = getMinAssign(Fin,Init,obj.Settings.Diffs,...
                    'MetCost',obj.Settings.MetCost,'Greedy',obj.Settings.Greedy,'Angle',obj.Settings.Angle);
                for j=1:length(assign)
                    if assign(j)>0 && j~=revassign(assign(j))
                        assign(j) = -1;
                    end
                end
                
                % Convert assignment to adjacency
                for j=1:length(assign)
                    if assign(j)==-1
                        continue
                    end
                    currRowInd = obj.UnlinkFrom{obj.CurrFrame}(j);
                    currColInd = obj.UnlinkTo{i}(assign(j));
                    obj.RowLink(end+1) = obj.CellNum(obj.CellNum(:,1)==obj.CurrFrame & obj.CellNum(:,2)==currRowInd,3);
                    obj.ColLink(end+1) = obj.CellNum(obj.CellNum(:,1)==i & obj.CellNum(:,2)==currColInd,3);
                end
                
                % Remove new assignments for next round of linking
                NewLinks = assign~=-1;
                obj.UnlinkFrom{obj.CurrFrame}(NewLinks) = [];
                obj.UnlinkTo{i}(assign(NewLinks)) = [];
            end
            
            obj.CurrFrame = obj.CurrFrame+1;
        end
        
        function finalize(obj)
            % Function to get adjacency matrix from row and column links
            % and finalize detection by converting to track array. Execute
            % this every time a (re)linking has been completed.
            
            % Get adjacency matrix
            obj.AdjMat = sparse(obj.RowLink,obj.ColLink,1,size(obj.CellNum,1),size(obj.CellNum,1));
            
            % Convert adjacency matrix to track
            noSource = [];
            for i = 1:size(obj.AdjMat,2)
                if isempty(find(obj.AdjMat(:,i),1))
                    noSource = [noSource;i];
                end
            end
            trackNum = numel(noSource);
            adjTracks = cell(trackNum,1);
            AT = obj.AdjMat';
            for i=1:trackNum
                tmpHolder = NaN(obj.NFrames,1);
                target = noSource(i);
                index = obj.CellNum(target,1);
                while ~isempty(target)
                    tmpHolder(index) = target;
                    target = find(AT(:,target),1,'first');
                    index = obj.CellNum(target,1);
                end
                tmpHolder(isnan(tmpHolder)) = 0;
                adjTracks{i} = tmpHolder(~isnan(tmpHolder));
                obj.Tracks{i} = arrayfun(@(x) obj.adjHelper(x),adjTracks{i});
            end
            
            % Remove small tracks
            for i=numel(obj.Tracks):-1:1
                if sum(~isnan(obj.Tracks{i}))<=2
                    obj.Tracks(i) = [];
                end
            end

            % Convert tracks to track data
            obj.TrackData = zeros(trackNum,obj.NFrames);
            for i=1:trackNum
                obj.TrackData(i,:) = obj.Tracks{i}';
            end
        end
        
        
        function restart(obj)
            obj.CurrFrame = 1;
        end
        
        
        function update(obj,NewTrack,NewData,Exclude)
            % Function to update adjacency matrix and unlinked cells from 
            % user generated tracks.
            
            if nargin==3
                Exclude = [];
            end
            
            % Keep only user-selected tracks
            NewTrack = NewTrack(Exclude,:);
            obj.TrackData = NewTrack;
            obj.InData = NewData;
            obj.initialize();

            % Recalculate adjacency matrix
            for i=1:size(obj.TrackData,1)
                TrackStart = find(NewTrack(i,:)>0,1,'first');
                for j=TrackStart:size(NewTrack,2)-1
                    if NewTrack(i,j)==0
                        continue
                    end
                    StartInds = [NewTrack(i,j) j];
                    EndInds = [];
                    for k=j+1:obj.NFrames
                        if NewTrack(i,k)==0
                            continue
                        end
                        EndInds = [NewTrack(i,k) k];
                        break
                    end

                    if isempty(EndInds)
                        continue
                    end
                    
                    % Break connections over gaps
                    if EndInds(2)-StartInds(2)>1
                        continue
                    end
                    
                    obj.RowLink(end+1) = obj.CellNum(obj.CellNum(:,1)==StartInds(2) & obj.CellNum(:,2)==StartInds(1),3);
                    obj.ColLink(end+1) = obj.CellNum(obj.CellNum(:,1)==EndInds(2) & obj.CellNum(:,2)==EndInds(1),3);
                end
            end
            obj.AdjMat = sparse(obj.RowLink,obj.ColLink,1,size(obj.CellNum,1),size(obj.CellNum,1));
            
            % Recalculate unlinked cells
            for i=1:obj.NFrames-1
                curr = obj.CellNum(obj.CellNum(:,1)==i+1,2:3);
                tolinks = arrayfun(@(x) obj.unlinktoHelper(x),curr(:,2));
                obj.UnlinkTo{i+1} = curr(tolinks==0,1);
                curr = obj.CellNum(obj.CellNum(:,1)==i,2:3);
                fromlinks = arrayfun(@(x) obj.unlinkfromHelper(x),curr(:,2));
                obj.UnlinkFrom{i} = curr(fromlinks==0,1);
            end
        end         
        
        function out = adjHelper(obj,x)
            % Helper function to return object in frame indexing from
            % all-indexing
            if x==0
                out = 0;
            else
                out = obj.CellNum(obj.CellNum(:,3)==x,2);
            end
        end
        
        function out = unlinktoHelper(obj,x)
            % Helper function to return prev object linked to x
            out = find(obj.AdjMat(:,x),1,'first');
            if isempty(out)
                out = 0;
            end
        end
        
        function out = unlinkfromHelper(obj,x)
            % Helper function to return next object linked from x
            out = find(obj.AdjMat(x,:),1,'first');
            if isempty(out)
                out = 0;
            end
        end
    end
end
