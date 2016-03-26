function combineData

baseNs  = {'xy03Comb_','xy04Comb_','xy05Comb_','xy06Comb_','xy07Comb_',...
    'xy08Comb_','xy09Comb_','xy10Comb_','xy11Comb_','xy12Comb_','xy13Comb_',...
    'xy14Comb_','xy15Comb_','xy16Comb_'};
sBaseNs = {'xy3Comb_','xy4Comb_','xyComb_','xy6Comb_','xy7Comb_','xy8Comb_',...
    'xy9Comb_','xy10Comb_','xy11Comb_','xy12Comb_','xy13Comb_','xy14Comb_',...
    'xy15Comb_','xy16Comb_'};
sBaseNs = baseNs;
% baseNs = {'xy03Comb_','xy04Comb_'};
% sBaseNs = baseNs;

Mets = {'Area','Circularity','Local Density','Nuc Mean','Nuc Std Dev',...
    'Orientation','Track1 Mean','Track1 Std Dev','Track2 Mean',...
    'Track2 Std Dev','X Position','Y Position'};

outbase = 'xyComb_Final_';

outData = cell(1,numel(Mets));
outSurv = [];
currCount = 0;
for i=1:numel(baseNs)
    for j=1:numel(Mets)
        d = csvread([baseNs{i} Mets{j} '.csv']);
        outData{j} = [outData{j};d];
    end
    
    %     [~, ~, sData] = xlsread([sBaseNs{i} 'Survival.xlsx']);
    %     sData(cellfun(@(x) ~isempty(x) && isnumeric(x) && isnan(x),sData)) = {''};
    %     sData = sData(2:end,:);
    delimiter = ',';
    formatSpec = '%s%s%s%s%s%s%s%s%s%s%[^\n\r]';
    fileID = fopen([sBaseNs{i} 'Survival.csv'],'r');
    dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
    fclose(fileID);
    raw = repmat({''},length(dataArray{1}),length(dataArray)-1);
    for col=1:length(dataArray)-1
        raw(1:length(dataArray{col}),col) = dataArray{col};
    end
    sData = raw;
    for i=[1 2 4 5 6 7 8 9]
        for j=1:size(sData,1)
            if ~isnan(str2double(sData{j,i}))
                sData{j,i} = str2double(sData{j,i});
            else
                %sData{j,i} = 0;
            end
        end
    end
    
    key = [cell2mat(sData(:,1)) (currCount+1:currCount+size(sData,1))'];
    for k=1:size(sData,1)
        ind = find(sData{k,1}==key(:,1));
        if ~isempty(ind)
            sData{k,1} = key(ind,2);
        end
        ind = find(sData{k,2}==key(:,1));
        if ~isempty(ind)
            sData{k,2} = key(ind,2);
        end
        
        if isnumeric(sData{k,6})
            ind = find(sData{k,6}==key(:,1));
            if ~isempty(ind)
                sData{k,6} = key(ind,2);
            end
        end
        if isnumeric(sData{k,7})
            ind = find(sData{k,7}==key(:,1));
            if ~isempty(ind)
                sData{k,7} = key(ind,2);
            end
        end
        if isnumeric(sData{k,8})
            ind = find(sData{k,8}==key(:,1));
            if ~isempty(ind)
                sData{k,8} = key(ind,2);
            end
        end
    end
    outSurv = [outSurv;sData];
    
    currCount = currCount+size(sData,1);
    %pause
end

for i=1:numel(Mets)
    csvwrite([outbase Mets{i} '.csv'],outData{i})
%     xlswrite([outbase Mets{i}],outData{i})
end
%xlswrite([outbase 'Survival'],outSurv);

fID = fopen([outbase 'Survival.csv'],'w');
SurvivalData = outSurv;
for i=1:size(SurvivalData,1)
    fprintf(fID,'%d,%d,%s,%d,%d,',SurvivalData{i,1:5});
    fprintf(fID,'%s,%s,%s,%s,%s\n',combineHelper(SurvivalData{i,6}),...
        combineHelper(SurvivalData{i,7}),combineHelper(SurvivalData{i,8}),....
        combineHelper(SurvivalData{i,9}),combineHelper(SurvivalData{i,10}));
end
fclose(fID);


function out = combineHelper(x)
if isnumeric(x)
    out = num2str(x);
else
    out = x;
end