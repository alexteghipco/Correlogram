function [t,parts,parts2,h,h2,annot] = correlogram(data,data2,varargin) %clrs,histLine,txt,txtClr,saveFig,lblsX,lblsY,varargin)
% this is currently hard coded in lots of ways but quickScatter is
% *insanely* flexible...forthcoming is a varargin arg that will let you
% pass in ways to change all sorts of crazy details about your
% scatterplots, even the order in which different elements are displayed.
% Obvs future update will also make this crappy code more elegant and give
% more options at the level of correlogram too...
%
% NEW addition: allow for rectangular matrices. Has to be manual switch. If
% rect, then first row and first column will use scatterhist instead. in
% case of first row AND col display both hists, otherwise, just the one
%
% scatterhist needs to be implemented at the level of quickScatter
% first...need to add ksdensity THEN patch
%
% Assign a unique color to each x and y variable. Then interpolate between
% the two within each tile. 

% setup output...
h = []; h2 = []; parts2 = []; t = []; annot = [];

% setup defaults
opts = struct('clrs',[],'bounds',{{'functional','off'}},'txt',[],'txtClr',[],...
    'err',[],'trendLineWidth',5,'histLine',true,'saveFig',true,'lblsX',[],'lblsY',[],...
    'fontSizeNames',8,'fontSize',8,'scatLinWidth',2,...
    'markerAlpha',0.4,'shadedAlpha',0.9,'excludeExtremes',2,'pointNamesColor','consistent','newFig',true,'xlab',[],'ylab',[],'markFill',true,...
    'markSz',200,'box','on','patchTop',false,'histAlph',0);
optsNm = fieldnames(opts);

% Check inputs
if length(varargin) < 0
    error('You are missing an argument')
end
if length(varargin) > (length(fieldnames(opts))*2)
    error('You have supplied too many arguments')
end  

% convert data if necessary
try
    data = table2array(data);
    data2 = table2array(data2);
catch
end

% in case it's a single matrix data or data2 can be empty...
if isempty(data2) && ~isempty(data)
    data2 = data;
    trun = true;
end
if ~isempty(data2) && isempty(data)
    data = data2;
    trun = false;
end

% now parse the arguments
vleft = varargin(1:end);
for pair = reshape(vleft,2,[]) %pair is {propName;propValue}
    inpName = pair{1}; % make case insensitive by using lower() here but this can be buggy
    if any(strcmpi(inpName,optsNm)) % check if arg pair matches default
        def = opts.(inpName); % default argument
        if ~isempty(pair{2}) % if passed in argument isn't empty, then write that in as the option
            opts.(inpName) = pair{2};
        else
            opts.(inpName) = def; % otherwise use the default values for the option
        end
    else
        error('%s is not a recognized parameter name',inpName)
    end
end

if isempty(opts.txtClr)
    opts.txtClr = [0 0 0];
    % txtClr = [0.9 0.22 0.45];
end

m = size(data,2);
n = size(data2,2);
tot = m*n;
if m == n
    rect = false;
    %tot =((nchoosek(n,2))*2)+n;
    [cMap] = customColorMapInterp(opts.clrs,n+3);
    cMap(round(size(cMap,1)/2),:) = [];
    cMap(round(size(cMap,1)/2)+1,:) = [];
    cMap(round(size(cMap,1)/2)-1,:) = [];
    
    rw = 1:n:tot;
    cw = rw(end):tot;
    cw = [cw cw(end)-n];
    rw(1) = rw(1) + 1;
    dw = 1:n+1:tot;
else
    rect = true;
    if size(opts.clrs,1) ~= m || size(opts.clrs,2) ~= n
        disp('Colors needs to be in same shape as data1 cols x data2 cols (in a 3d matrix where the third dimension is rgb triplet)')
        mps{2} = cool(m+1);
        mps{1} = summer(n+1);
        cMap = customColorMapInterpBars2(mps);
    end
    % we need to add an extra row and an extra column...
    data = [nan(size(data,1),1) data];
    data2 = [data2 nan(size(data2,1),1)];
    opts.lblsX = [opts.lblsX{1} opts.lblsX];
    opts.lblsY = [opts.lblsY opts.lblsY{end}];
    
    m = size(data,2);
    n = size(data2,2);
    annot = cell(m,n);
    tot = m*n;
    rw = 1:m:tot; % maps on
    cw = rw(end):tot;
    dw = [];
    
    %     datatmp = data;
    %     data2tmp = data2;
    %     lblsXtmp = lblsX;
    %     lblsYtmp = lblsY;
    %
    %     data2 = datatmp;
    %     data = data2tmp;
    %     lblsX = lblsYtmp;
    %     lblsY = lblsXtmp;
    
%     txt = [cell([size(txt,1),1]) txt];
%     txt = [txt;cell([size(txt,2),1])'];
%     txtClr = [cell([size(txtClr,1),1]),txtClr];
%     txtClr = [txtClr;cell([size(txtClr,2),1])'];
    
    opts.txt = [opts.txt cell([size(opts.txt,1),1])];
    opts.txt = [cell([size(opts.txt,2),1])'; opts.txt];
    opts.txtClr = [opts.txtClr cell([size(opts.txtClr,1),1])];
    opts.txtClr = [cell([size(opts.txtClr,2),1])'; opts.txtClr];
end


f = figure; f.Position = [100 100 3000 1805]; t = tiledlayout(n,m,'TileSpacing','tight','Padding','compact');
for i = 1:n
    if ~rect
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
        for j = 1:m
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
                parts{i,j} = quickScatter(data2(:,i),data2(:,j),'cmap',c,'newFig',opts.newFig,'scatLinWidth',opts.scatLinWidth,'markSz',opts.markSz,'bounds',{'functional','on'},...
                    'markerAlpha',opts.markerAlpha,'shadedAlpha',opts.shadedAlpha,'colorIndex',2,'perfectY',false,'xlab','none','ylab','none','markFill',opts.markFill,'annot',false,'trendLineWidth',opts.trendLineWidth,...
                    'box',true,'xlab',opts.lblsX{j},'ylab',opts.lblsX{i},'fontSizeNames',opts.fontSizeNames,'fontSize',opts.fontSize,'patchTop',true,'trendLineWidth',5);
                ylim(gca,[mni mxi]);
                xlim(gca,[mnj mxj]);
                xticks(t2);
                yticks(t1);
                
            elseif j > i
                parts2{i,j} = quickScatter(data(:,i),data(:,j),'cmap',c2,'newFig',opts.newFig,'scatLinWidth',opts.scatLinWidth,'markSz',opts.markSz,'bounds',opts.bounds,...
                    'markerAlpha',opts.markerAlpha,'shadedAlpha',opts.shadedAlpha,'colorIndex',2,'perfectY',false,'xlab','none','ylab','none','markFill',opts.markFill,'annot',false,'trendLineWidth',opts.trendLineWidth,...
                    'box',true,'xlab',opts.lblsX{j},'ylab',opts.lblsX{i},'fontSizeNames',opts.fontSizeNames,'fontSize',opts.fontSize,'patchTop',false,'trendLineWidth',5);
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
                
                if ~opts.histLine
                    h{i,j} = histogram(data2(:,i),e);
                    h{i,j}.FaceColor = c2;
                    h{i,j}.FaceAlpha = opts.histAlph;
                    h{i,j}.EdgeColor = 'none';
                    hold on
                    h2{i,j} = histogram(data(:,j),e);
                    h2{i,j}.FaceColor = c;
                    h2{i,j}.FaceAlpha = opts.histAlph;
                    h2{i,j}.EdgeColor = 'none';
                else
                    h{i,j} = histfit(data2(:,i),[],'kernel');
                    h{i,j}(1).FaceAlpha = 0;
                    h{i,j}(1).EdgeAlpha = 0;
                    h{i,j}(2).LineWidth = opts.trendLineWidth;
                    ctmp = c2+0.1;
                    idx = find(ctmp > 1);
                    ctmp(idx) = 1;
                    h{i,j}(2).Color = ctmp;
                    
                    hold on
                    h2{i,j} = histfit(data(:,j),[],'kernel');
                    h2{i,j}(1).FaceAlpha = opts.histAlph;
                    h2{i,j}(1).EdgeAlpha = 0;
                    h2{i,j}(2).LineWidth = opts.trendLineWidth;
                    h2{i,j}(2).Color = c;
                    
                    patch(h{i,j}(2).XData,h{i,j}(2).YData,'red','FaceColor',ctmp,'FaceAlpha',0.85);
                    patch(h2{i,j}(2).XData,h2{i,j}(2).YData,'red','FaceColor',c,'FaceAlpha',0.85);
                    
                    xlim([min([h{i,j}(2).XData h2{i,j}(2).XData]) max([h{i,j}(2).XData h2{i,j}(2).XData])])
                    ylim([min([h{i,j}(2).YData h2{i,j}(2).YData]) max([h{i,j}(2).YData h2{i,j}(2).YData])])
                end
                
                ax = gca; ax.LineWidth = 2; grid on; set(gca,'TickLength',[0.02 0.02]);
                xlabel(opts.lblsX{i})
                %xlabel(data2(:,i).Properties.VariableNames{1},'Position',[40 -125])
                ylabel('Density')
                set(gca,'FontSize',opts.fontSizeNames+opts.fontSize)
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
                if ~isempty(opts.txt)
                    annot{i,j} = annotation('textbox','String',opts.txt{i,j},'FitBoxToText','on','FontSize',opts.fontSizeNames+opts.fontSize,'EdgeColor','none','Color',opts.txtClr{i,j},'Position',[t.Children(1).Position(1)+0.021 t.Children(1).Position(2)+0.014 t.Children(1).Position(3) t.Children(1).Position(4)],'FontAngle','italic','HorizontalAlignment','right');
                    annot{i,j}.Position = [t.Children(1).Position(1)+0.003 t.Children(1).Position(2)+0.0145 t.Children(1).Position(3) t.Children(1).Position(4)];
                    %annot{i,j}.Position = [t.Children(1).Position(1)+round(0.00053*length(txt{i,j}),3) t.Children(1).Position(2)+0.013 t.Children(1).Position(3) t.Children(1).Position(4)];
                end
            end
        end
    else
        xdata = data2(:,i); % get first row...   
        if length(find(isnan(xdata))) ~= size(xdata,1)
            if abs(min(xdata)) < 1
                mni = round(min(xdata));
            else
                mni = floor(min(xdata));
            end
            if abs(max(xdata)) < 1
                mxi = round(max(xdata),2);
            else
                mxi = ceil(max(xdata));
            end
            t1 = round(linspace(mni,mxi,5),2);
        else
            xdatatmp = [];
            mni = [];
            mxi = [];
            t2 = [];
        end
        for j = 1:m
            ind = ((m*i)-m)+j;
            ydata = data(:,j);
            if length(find(isnan(ydata))) ~= size(ydata,1)
                if abs(min(ydata)) < 1
                    mnj = round(min(ydata));
                else
                    mnj = floor(min(ydata));
                end
                if abs(max(ydata)) < 1
                    mxj = round(max(ydata),2);
                else
                    mxj = ceil(max(ydata));
                end
                t2 = round(linspace(mnj,mxj,5),2);
            else
                ydatatmp = data(:,j+1);
                if abs(min(ydata)) < 1
                    mnj = round(min(ydatatmp));
                else
                    mnj = floor(min(ydatatmp));
                end
                if abs(max(ydatatmp)) < 1
                    mxj = round(max(ydatatmp),2);
                else
                    mxj = ceil(max(ydatatmp));
                end
                t2 = round(linspace(mnj,mxj,5),2);
            end
            dt = [xdata ydata];
            nexttile
                        
            c = squeeze(cMap(i,j,:))';
            %ind = ((m*i)-m)+j;
            if isempty(intersect(ind,rw)) & isempty(intersect(ind,cw))
                parts{i,j} = quickScatter(dt(:,1),dt(:,2),'cmap',c,'newFig',opts.newFig,'scatLinWidth',opts.scatLinWidth,'markSz',opts.markSz,'bounds',opts.bounds,...
                    'markerAlpha',opts.markerAlpha,'shadedAlpha',opts.shadedAlpha,'colorIndex',2,'perfectY',false,'xlab','none','ylab','none','markFill',opts.markFill,'annot',false,'trendLineWidth',opts.trendLineWidth,...
                    'box',opts.box,'xlab','','ylab','','fontSizeNames',opts.fontSizeNames,'fontSize',opts.fontSize,'patchTop',true,'trendLineWidth',opts.trendLineWidth,'newFig',opts.newFig);
                xlim(gca,[mnj mxj]);
                ylim(gca,[mni mxi]);
                set(gca,'YTick',t1)
                set(gca,'XTick',t2)
                set(gca,'Xticklabel',[])
                set(gca,'Yticklabel',[])
                pbaspect([1 1 1])
                
                
%                 if intersect(i,rw)
%                     annot{i,j} = annotation('textbox','String',txt{j,i+1},'FitBoxToText','on','FontSize',11,'EdgeColor','none','Color',txtClr{j,i+1},'Position',[t.Children(1).Position(1)+0.021 t.Children(1).Position(2)+0.014 t.Children(1).Position(3) t.Children(1).Position(4)],'FontAngle','italic','HorizontalAlignment','right');
%                 elseif intersect(j,cw)
%                     annot{i,j} = annotation('textbox','String',txt{j+1,i},'FitBoxToText','on','FontSize',11,'EdgeColor','none','Color',txtClr{j+1,i},'Position',[t.Children(1).Position(1)+0.021 t.Children(1).Position(2)+0.014 t.Children(1).Position(3) t.Children(1).Position(4)],'FontAngle','italic','HorizontalAlignment','right');
%                 end
            else
                if ~isempty(intersect(ind,rw)) & ~isempty(intersect(ind,cw))
                    ax = gca; ax.Visible = 'off';
                elseif ~isempty(intersect(ind,cw)) & isempty(intersect(ind,rw))
                    h{i,j} = histfit(dt(:,2),[],'kernel');
                    tmpx = h{i,j}(2).XData;
                    tmpy = h{i,j}(2).YData;
                    delete(h{i,j})
                    h{i,j} = plot(tmpx,-tmpy);
                    h{i,j}.Parent.YTickLabel = num2str(-1*str2double(h{i,j}.Parent.YTickLabel));
                    set(gca,'XAxisLocation','top')
                    set(gca,'YAxisLocation','left')
                    h{i,j}.Color = c;
                    h{i,j}.LineWidth = opts.trendLineWidth;
                    ptch = patch(tmpx,-tmpy,'red','FaceColor',c,'FaceAlpha',opts.shadedAlpha);
                    ptch.EdgeColor = 'none';
                    xlabel(opts.lblsX{j})
                    ylabel('Density')
                    grid on
                    set(gca,'XTickLabels',t2)
                    set(gca,'XTick',t2)
                    xlim([t2(1) t2(end)])
                    try
                        ylim([-(min(tmpy)) -(max(tmpy))])
                    catch
                        ylim([-(max(tmpy)) -(min(tmpy))])
                    end
                    ax = gca; ax.LineWidth = opts.scatLinWidth; grid on; set(gca,'TickLength',[0.02 0.02]);
                    set(gca,'TickLength',[0.02 0.02]);
                    set(gca,'FontSize',opts.fontSizeNames+opts.fontSize)
                    pbaspect([2 1 1])
                   
                elseif ~isempty(intersect(ind,rw)) & isempty(intersect(ind,cw))
                    h{i,j} = histfit(dt(:,1),[],'kernel');
                    tmpx = fliplr(h{i,j}(2).XData);
                    tmpy = fliplr(h{i,j}(2).YData);
                    delete(h{i,j})
                    h{i,j} = plot(-tmpy,tmpx);
                    h{i,j}.Parent.XTickLabel = num2str(-1*str2double(h{i,j}.Parent.XTickLabel));
                    set(gca,'YAxisLocation','right')
                    h{i,j}.Color = c;
                    h{i,j}.LineWidth = opts.trendLineWidth;
                    ptch = patch(-tmpy,tmpx,'red','FaceColor',c,'FaceAlpha',opts.shadedAlpha);
                    ptch.EdgeColor = 'none';
                    ylabel(opts.lblsY{i})
                    xlabel('Density')
                    grid on
                    set(gca,'YTickLabels',t1)
                    set(gca,'YTick',t1)
                    ylim([t1(1) t1(end)])
                    try
                        xlim([-(min(tmpy)) -(max(tmpy))])
                    catch
                        xlim([-(max(tmpy)) -(min(tmpy))])
                    end
                    ax = gca; ax.LineWidth = opts.scatLinWidth; grid on; set(gca,'TickLength',[0.02 0.02]);
                    set(gca,'TickLength',[0.02 0.02]);
                    set(gca,'FontSize',opts.fontSizeNames+opts.fontSize)
                    pbaspect([1 2 1])
                end
            end
            
            if isempty(intersect(ind,rw)) & isempty(intersect(ind,cw))           
                if ~isempty(opts.txt)
                    annot{i,j} = annotation('textbox','String',opts.txt{j,i},'FitBoxToText','on','FontSize',opts.fontSizeNames+opts.fontSize,'EdgeColor','none','Color',opts.txtClr{j,i},'Position',[t.Children(1).Position(1)+0.021 t.Children(1).Position(2)+0.014 t.Children(1).Position(3) t.Children(1).Position(4)],'FontAngle','italic','HorizontalAlignment','right');
                    annot{i,j}.Position = [t.Children(1).Position(1) t.Children(1).Position(2)+0.0145 t.Children(1).Position(3) t.Children(1).Position(4)];
                    %annot{i,j}.Position = [t.Children(1).Position(1)+round(0.00053*length(txt{i,j}),3) t.Children(1).Position(2)+0.013 t.Children(1).Position(3) t.Children(1).Position(4)];
                end
            end
        end
    end
end
if opts.saveFig
    tmp = num2str(round(now,5));
    %saveas(f,[pwd '/correlogram_' tmp '.eps'],'epsc2');
    saveas(f,[pwd '/correlogram_' tmp '.svg'],'svg');
    saveas(f,[pwd '/correlogram_' tmp '.fig']);
    saveas(f,[pwd '/correlogram_' tmp '.png']);
end