function CheckData
Mets = {'Area','Circularity','Local Density','Nuc Mean','Nuc Std Dev',...
    'Orientation','Track1 Mean','Track1 Std Dev','Track2 Mean',...
    'Track2 Std Dev','X Position','Y Position'};

baseNs  = 'xyComb_Final_';
dataFmt = '.csv';
survFmt = '.csv';

%% Load data
outData = cell(1,numel(Mets));
if strcmp(dataFmt,'.csv')
    for j=1:numel(Mets)
        d = csvread([baseNs Mets{j} '.csv']);
        outData{j} = [outData{j};d];
    end
elseif strcmp(dataFmt,'.xls') || strcmp(dataFmt,'.xlsx')
else
    error('Unrecognized input data format.')
end


%% Load survival
if strcmp(dataFmt,'.csv')
    delimiter = ',';
    formatSpec = '%f%f%s%f%f%s%s%s%s%s%[^\n\r]';
    fileID = fopen([baseNs 'Survival.csv'],'r');
    try
        dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
    catch
        error('Error reading data file')
    end
    fclose(fileID);
    
    Cell = dataArray{:, 1};
    Parent = dataArray{:, 2};
    F = dataArray{:, 3};
    T = dataArray{:, 4};
    L = dataArray{:, 5};
    D1 = dataArray{:, 6};
    D2 = dataArray{:, 7};
    D3 = dataArray{:, 8};
    D4 = dataArray{:, 9};
    Notes = dataArray{:, 10};
    
    clearvars filename delimiter formatSpec fileID dataArray ans;
    
    Survival = struct('Cell',num2cell(Cell),'Parent',num2cell(Parent),...
        'F',F,'T',num2cell(T),'L',num2cell(L),...
        'D1',D1,'D2',D2,'D3',D3,'D4',D4,'Notes',Notes);
elseif strcmp(dataFmt,'.xls') || strcmp(dataFmt,'.xlsx')
else
    error('Unrecognized input data format.')
end

for i=1:numel(Mets)
    if size(outData{i},1)~=numel(Survival)
        error(sprintf('Data sheet %d does not match survival sheet.',i)) 
    end
end

size(outData{1})
for i=1:numel(Survival)
    for j=1:size(outData{1},2)
        if outData{1}(i,j)~=0
            break
        end
    end
    dataStart = j;
    
    for j=size(outData{1},2):-1:1
        if outData{1}(i,j)~=0
            break
        end
    end
    dataEnd = j+1;
    
    if Survival(i).Parent==0
        survStart = 0;
    else
        survStart = Survival(Survival(i).Parent).T+Survival(Survival(i).Parent).L;
    end
    if dataStart<survStart
        fprintf('Cell %d data (t=%d) does not match start time of %d.\n',i,dataStart,survStart)
    end
    
    switch Survival(i).F
        case {'M','A'}
            survEnd = Survival(i).T;
            if dataEnd>survEnd
                fprintf('Cell %d data (t=%d) does not match fate time of %d.\n',i,dataEnd,survEnd)
            end
    end
end

end