function [t,parts,parts2,h,h2] = correlogram(data,data2,clrs,histLine,txt,txtClr,saveFig,lbls)
% this is currently hard coded in lots of ways but quickScatter is
% *insanely* flexible...forthcoming is a varargin arg that will let you
% pass in ways to change all sorts of crazy details about your
% scatterplots, even the order in which different elements are displayed.
% Obvs future update will also make this crappy code more elegant and give
% more options at the level of correlogram too...
h = []; h2 = [];

try
    data = table2array(data);
    data2 = table2array(data2);
catch
end

if isempty(data2) && ~isempty(data)
    data2 = data;
end
if ~isempty(data2) && isempty(data)
    data = data2;
end

if isempty(txtClr)
    txtFlgClr = [ 0.901960784313726         0.223529411764706         0.450980392156863];
end
if isempty(txtClr)
    txtClr = [0 0 0];
end

n = size(data,2);
tot =((nchoosek(n,2))*2)+n;
[cMap] = customColorMapInterp(clrs,n+3);
cMap(round(size(cMap,1)/2),:) = [];
cMap(round(size(cMap,1)/2)+1,:) = [];
cMap(round(size(cMap,1)/2)-1,:) = [];

rw = 1:n:tot;
cw = rw(end):tot;
cw = [cw cw(end)-n];
rw(1) = rw(1) + 1;
dw = 1:n+1:tot;

f = figure; f.Position = [100 100 3000 1805]; t = tiledlayout(n,n,'TileSpacing','tight','Padding','compact');
for i = 1:n
    if abs(min([data2(:,i); data(:,i)])) < 1
        mni = round(min([data2(:,i); data(:,i)]),2);
    else
        mni = floor(min([data2(:,i); data(:,i)]));
    end
    if abs(max([data2(:,i); data(:,i)])) < 1
        mxi = round(max([data2(:,i); data(:,i)]),2);
    else
        mxi = ceil(max([data2(:,i); data(:,i)]));
    end
    t1 = round(linspace(mni,mxi,5),2);   
    for j = 1:n
        nexttile
        c = cMap(min([i j]),:);
        c2 = c+0.1; id = find(c2 > 1);c2(id) = 1;
        ind = ((n*i)-n)+j;
        
%         mnj = fix(min([data2(:,j); data(:,j)]));
%         mxj = ceil(max([data2(:,j); data(:,j)]));
        
        if abs(min([data2(:,j); data(:,j)])) < 1
            mnj = round(min([data2(:,j); data(:,j)]),2);
        else
             mnj = floor(min([data2(:,j); data(:,j)]));
        end
        if abs(max([data2(:,j); data(:,j)])) < 1
             mxj = round(max([data2(:,j); data(:,j)]),2);
        else
             mxj = ceil(max([data2(:,j); data(:,j)]));
        end
        
        t2 = round(linspace(mnj,mxj,5),2);
        
        if j < i
            parts{i,j} = quickScatter(data2(:,i),data2(:,j),'cmap',c,'newFig',false,'scatLinWidth',2,'markSz',150,'bounds',{'functional','on'},...
                'markerAlpha',0.2,'shadedAlpha',0.9,'colorIndex',2,'perfectY',false,'xlab','none','ylab','none','markFill',true,'annot',false,'trendLineWidth',2,...
                'box',true,'xlab',lbls{j},'ylab',lbls{i},'fontSizeNames',8,'fontSize',8,'patchTop',true,'trendLineWidth',5);
            ylim(gca,[mni mxi]);
            xlim(gca,[mnj mxj]);
            xticks(t2);
            yticks(t1);
            
        elseif j > i
            parts2{i,j} = quickScatter(data(:,i),data(:,j),'cmap',c2,'newFig',false,'scatLinWidth',2,'markSz',150,'bounds',{'functional','on'},...
                'markerAlpha',0.2,'shadedAlpha',0.9,'colorIndex',2,'perfectY',false,'xlab','none','ylab','none','markFill',true,'annot',false,'trendLineWidth',1,...
                'box',true,'xlab',lbls{j},'ylab',lbls{i},'fontSizeNames',8,'fontSize',8,'patchTop',false,'trendLineWidth',5);
            ylim(gca,[mni mxi]);
            xlim(gca,[mnj mxj]);
            xticks(t2);
            yticks(t1);
            
        elseif j == i
           un = unique(data2(:,i));
           un2 = unique(data(:,i));
           un = [un; un2];
           if length(un) > 2 && length(un) >= 25
               un2 = unique(data(:,i));
               e = linspace(min(un),max(un),25);
           elseif length(un) < 25 && length(un) > 2
               un2 = unique(data(:,i));
               e = linspace(min(un),max(un),length(un));
           else
               e = [1 2];
           end
            
           if ~histLine
               h{i,j} = histogram(data2(:,i),e);
               h{i,j}.FaceColor = c2;
               h{i,j}.FaceAlpha = 0.5;
               h{i,j}.EdgeColor = 'none';
               hold on
               h2{i,j} = histogram(data(:,j),e);
               h2{i,j}.FaceColor = c;
               h2{i,j}.FaceAlpha = 0.5;
               h2{i,j}.EdgeColor = 'none';
           else
               h{i,j} = histfit(data2(:,i),[],'kernel');
               h{i,j}(1).FaceAlpha = 0;
               h{i,j}(1).EdgeAlpha = 0;
               h{i,j}(2).LineWidth = 5;
               ctmp = c2+0.1;
               idx = find(ctmp > 1);
               ctmp(idx) = 1;
               h{i,j}(2).Color = ctmp;
               
               hold on
               h2{i,j} = histfit(data(:,j),[],'kernel');
               h2{i,j}(1).FaceAlpha = 0;
               h2{i,j}(1).EdgeAlpha = 0;
               h2{i,j}(2).LineWidth = 5;
               h2{i,j}(2).Color = c;
               
               patch(h{i,j}(2).XData,h{i,j}(2).YData,'red','FaceColor',ctmp,'FaceAlpha',0.85);
               patch(h2{i,j}(2).XData,h2{i,j}(2).YData,'red','FaceColor',c,'FaceAlpha',0.85);

               xlim([min([h{i,j}(2).XData h2{i,j}(2).XData]) max([h{i,j}(2).XData h2{i,j}(2).XData])])
               ylim([min([h{i,j}(2).YData h2{i,j}(2).YData]) max([h{i,j}(2).YData h2{i,j}(2).YData])])
           end
           
           ax = gca; ax.LineWidth = 2; grid on; set(gca,'TickLength',[0.02 0.02]);
           xlabel(lbls{i})
           %xlabel(data2(:,i).Properties.VariableNames{1},'Position',[40 -125])
           ylabel('Density')
           set(gca,'FontSize',12)
        end
        
        if isempty(intersect(ind,dw))
            if isempty(intersect(ind,cw))
                xlabel('')
                set(gca,'Xticklabel',[])
            end
            if isempty(intersect(ind,rw))
                ylabel('')
                set(gca,'Yticklabel',[])
            end
            if ~isempty(txt)
                annot{i,j} = annotation('textbox','String',txt{i,j},'FitBoxToText','on','FontSize',11,'EdgeColor','none','Color',txtClr{i,j},'Position',[t.Children(1).Position(1)+0.021 t.Children(1).Position(2)+0.014 t.Children(1).Position(3) t.Children(1).Position(4)],'FontAngle','italic','HorizontalAlignment','right');
                annot{i,j}.Position = [t.Children(1).Position(1)+0.003 t.Children(1).Position(2)+0.013 t.Children(1).Position(3) t.Children(1).Position(4)];
                %annot{i,j}.Position = [t.Children(1).Position(1)+round(0.00053*length(txt{i,j}),3) t.Children(1).Position(2)+0.013 t.Children(1).Position(3) t.Children(1).Position(4)];
            end
        end
    end
end
if saveFig
    tmp = num2str(round(now,5));
    %saveas(f,[pwd '/correlogram_' tmp '.eps'],'epsc2');
    saveas(f,[pwd '/correlogram_' tmp '.svg'],'svg');
    saveas(f,[pwd '/correlogram_' tmp '.fig']);
    saveas(f,[pwd '/correlogram_' tmp '.png']);
end