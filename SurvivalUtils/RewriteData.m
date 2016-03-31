function RewriteData
Mets = {'Area','Circularity','Local Density','Nuc Mean','Nuc Std Dev',...
    'Orientation','Track1 Mean','Track1 Std Dev','Track2 Mean',...
    'Track2 Std Dev','X Position','Y Position'};

baseNs = input('Please enter the base name of the file: ','s');
dataFmt = input('Please enter the format of the data files: ','s');
% baseNs  = 'p13_';
% dataFmt = '.csv';

cellNum = input('Please enter the cell number(s) to rewrite: ','s');
cellNum = str2double(cellNum);
startInd = input('Please enter the start index: ','s');
startInd = str2double(startInd);
endInd = input('Please enter the end index: ','s');
endInd = str2double(endInd);
% cellNum = 15;
% startInd = 166;
% endInd = 167;

YN = input(sprintf('Are you sure you want to rewrite cell %d from frames %d to %d? (y/n)\n',cellNum,startInd,endInd),'s');

if ~strcmp(YN,'y')&&~strcmp(YN,'Y')
    return
end

if cellNum==0 || startInd==0 || endInd==0
    return
end

for i=1:numel(Mets)
    if strcmp(dataFmt,'.csv')
        d = csvread([baseNs Mets{i} '.csv']);
        d(cellNum,startInd:endInd) = 0;
        csvwrite([baseNs Mets{i} '.csv'],d)
    elseif strcmp(dataFmt,'.xls') || strcmp(dataFmt,'.xlsx')
    else
        error('Unrecognized input data format.')
    end
end

disp('Data successfully overwritten.')
end