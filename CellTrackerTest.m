% To test MotionDetector Object

InData = cell(3,1);
InData{1} = cell(3,1);
InData{1}{1} = [1;2;1.5;5]; InData{1}{2} = [10;20;15;30]; InData{1}{3} = [5;6;4;20];
InData{2} = cell(3,1);
InData{2}{1} = [1.5;1.9;1.1]; InData{2}{2} = [15;22;8]; InData{2}{3} = [3;7;5];
InData{3} = cell(3,1);
InData{3}{1} = [1.8;1.5;1.2;5.1]; InData{3}{2} = [24;15;6;30.1]; InData{3}{3} = [8;2;5;20.1];
Settings = struct('Method','MinAssign','MetCost',25,'GapClose',2,'Greedy',true,'Diffs',[.1 2 1],'Angle',false);

MD = MotionDetector();
MD.InData = InData;
MD.Settings = Settings;
MD.initialize();
MD.linkAll();
MD.finalize();
TrackData = MD.TrackData;
TrackData

InData{2}{1} = [1.5;1.9;1.1;5]; InData{2}{2} = [15;22;8;30]; InData{2}{3} = [3;7;5;20];
MD.update(TrackData,InData,4);
MD.linkAll();
MD.finalize();
TrackData = MD.TrackData;
TrackData