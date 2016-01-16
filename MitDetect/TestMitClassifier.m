bN = '/media/michaeldeng/Seagate Backup Plus Drive/You Lab/Experiments/2015-08-05/Addtl/';
fN = 'xy3.mat';

load([bN fN])

mitLabel = csvread([bN 'xy3_MitLabel.csv']);

allData   = [];
allClass = [];
for i=1:140
    nCells = numel(app.Data{i}{1});
    
    tmpClass = zeros(nCells,1);
    tmpClass(mitLabel(mitLabel(:,1)==i,2)) = 1;

    tmpData = zeros(nCells,22);
    for j=1:22
        tmpData(:,j) = app.Data{i}{j};
    end
    
    allData = [allData;tmpData];
    allClass = [allClass;tmpClass];
end

MitSVM = fitcsvm(allData,allClass);
sv = MitSVM.SupportVectors;
figure(1),gscatter(allData(:,1),allData(:,16),allClass)
hold on
plot(sv(:,1),sv(:,16),'ko','MarkerSize',10)
legend('NonMit','Mit','Support Vector')
hold off