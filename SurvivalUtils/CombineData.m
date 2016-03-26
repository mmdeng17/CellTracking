function CombineData()
Mets = {'Area','Circularity','Local Density','Nuc Mean','Nuc Std Dev',...
    'Orientation','Track1 Mean','Track1 Std Dev','Track2 Mean',...
    'Track2 Std Dev','X Position','Y Position'};

baseNs  = {'xyComb_Final_'};
dataFmt = '.csv';
survFmt = '.csv';

outBase = 'test';
outDataFmt = '.csv';
outSurvFmt = '.csv';

outData = cell(1,numel(Mets));
outSurv = [];
currCount = 0;

for i=1:numel(baseNs)
    %% Read in data
    if strcmp(dataFmt,'.csv')
        for j=1:numel(Mets)
            d = csvread([baseNs{i} Mets{j} '.csv']);
            outData{j} = [outData{j};d];
        end
    elseif strcmp(dataFmt,'.xls') || strcmp(dataFmt,'.xlsx')
    else
        error('Unrecognized input data format.')
    end
    
    %% Read in survival
    if strcmp(survFmt,'.csv')
        delimiter = ',';
        formatSpec = '%s%s%s%s%s%s%s%s%s%s%[^\n\r]';
        fileID = fopen([baseNs{i} 'Survival.csv'],'r');
        dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
        fclose(fileID);
        raw = repmat({''},length(dataArray{1}),length(dataArray)-1);
        for col=1:length(dataArray)-1
            raw(1:length(dataArray{col}),col) = dataArray{col};
        end
        sData = raw;
        for j=[1 2 4 5 6 7 8 9]
            for k=1:size(sData,1)
                if ~isnan(str2double(sData{k,j}))
                    sData{k,j} = str2double(sData{k,j});
                end
            end
        end
    elseif strcmp(survFmt,'.xls') || strcmp(survFmt,'.xlsx')
        [~, ~, sData] = xlsread([sBaseNs{i} 'Survival.xlsx']);
        sData(cellfun(@(x) ~isempty(x) && isnumeric(x) && isnan(x),sData)) = {''};
    else
        error('Unrecognized input survival format.')
    end
    
    %% Combine survival data
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
end

%% Write output data
if strcmp(outDataFmt,'.csv')
    for i=1:numel(Mets)
        csvwrite([outBase Mets{i} '.csv'],outData{i})
    end
elseif strcmp(outDataFmt,'.xls') || strcmp(outDataFmt,'.xlsx')
    for i=1:numel(Mets)
        xlswrite([outBase Mets{i}],outData{i})
    end
else
    error('Unrecognized output data format.')
end

%% Write output survival
if strcmp(outSurvFmt,'.csv')
    fID = fopen([outBase 'Survival.csv'],'w');
    try
        SurvivalData = outSurv;
        for i=1:size(SurvivalData,1)
            fprintf(fID,'%d,%d,%s,%d,%d,',SurvivalData{i,1:5});
            fprintf(fID,'%s,%s,%s,%s,%s\n',combineHelper(SurvivalData{i,6}),...
                combineHelper(SurvivalData{i,7}),combineHelper(SurvivalData{i,8}),....
                combineHelper(SurvivalData{i,9}),combineHelper(SurvivalData{i,10}));
        end
    catch
        error('Error writing output survival file.')
    end
    fclose(fID);
elseif strcmp(outSurvFmt,'.xls') || strcmp(outSurvFmt,'.xlsx')
    xlswrite([outBase 'Survival'],outSurv);
else
    error('Unrecognized output survival format.')
end

end


function out = combineHelper(x)
if isnumeric(x)
    out = num2str(x);
else
    out = x;
end
end