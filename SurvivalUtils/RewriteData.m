function RewriteData
Mets = {'Area','Circularity','Local Density','Nuc Mean','Nuc Std Dev',...
    'Orientation','Track1 Mean','Track1 Std Dev','Track2 Mean',...
    'Track2 Std Dev','X Position','Y Position'};

baseNs  = 'xyComb_Final_';
dataFmt = '.csv';

cellNum = 2;
startInd = 170;
endInd = 257;

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