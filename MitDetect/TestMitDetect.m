bN = '/media/michaeldeng/Seagate Backup Plus Drive/You Lab/Experiments/2015-08-05/Addtl/';
fN = 'xy6.mat';

load([bN fN])


for i=1:numel(app.Images)
    i
    
    rIm = app.Images{i}(:,:,1); rIm = 255*(rIm-min(rIm(:)))./(max(rIm(:))-min(rIm(:)));
    gIm = app.Images{i}(:,:,2); gIm = 255*(gIm-min(gIm(:)))./(max(gIm(:))-min(gIm(:)));
    bIm = app.Images{i}(:,:,3); bIm = 255*(bIm-min(bIm(:)))./(max(bIm(:))-min(bIm(:)));
    currIm = cat(3,uint8(rIm),uint8(gIm),uint8(zeros(size(gIm))));
    
    figure(1),imshow(currIm)
    hold on
    for j=1:numel(app.Bounds{i})
        currBound = app.Bounds{i}{j};
        plot(currBound(:,2),currBound(:,1),'b-')
        text(mean(currBound(:,2)),mean(currBound(:,1)),num2str(j),...
            'HorizontalAlignment','center','Color','m','FontSize',12)
    end
    pause
end


