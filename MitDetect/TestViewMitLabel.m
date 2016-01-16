bN = '/media/michaeldeng/Seagate Backup Plus Drive/You Lab/Experiments/2015-08-05/Addtl/';
fN = 'xy3.mat';

load([bN fN])


mitLabel = csvread([bN 'xy3_MitLabel.csv']);



return
for i=32:numel(app.Images)
    i
    
    rIm = app.Images{i}(:,:,1); rIm = 255*(rIm-min(rIm(:)))./(max(rIm(:))-min(rIm(:)));
    gIm = app.Images{i}(:,:,2); gIm = 255*(gIm-min(gIm(:)))./(max(gIm(:))-min(gIm(:)));
    bIm = app.Images{i}(:,:,3); bIm = 255*(bIm-min(bIm(:)))./(max(bIm(:))-min(bIm(:)));
    currIm = cat(3,uint8(rIm),uint8(gIm),uint8(zeros(size(gIm))));
    
    mitCells = (mitLabel(mitLabel(:,1)==i,2))';
    if isempty(mitCells)
        othCells = 1:numel(app.Bounds{i});
    else
        othCells = setdiff(1:numel(app.Bounds{i}),mitCells);
    end
    
    figure(1),imshow(currIm)
    hold on
    for j=othCells
        currBound = app.Bounds{i}{j};
        plot(currBound(:,2),currBound(:,1),'c-')
        text(mean(currBound(:,2)),mean(currBound(:,1)),num2str(j),...
            'HorizontalAlignment','center','Color','c','FontSize',12)
    end
    if ~isempty(mitCells)
        for j=mitCells
            currBound = app.Bounds{i}{j};
            plot(currBound(:,2),currBound(:,1),'m-')
            text(mean(currBound(:,2)),mean(currBound(:,1)),num2str(j),...
                'HorizontalAlignment','center','Color','m','FontSize',12)
        end
    end
    pause
end


