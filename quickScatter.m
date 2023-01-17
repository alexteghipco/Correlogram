function [parts] = quickScatter(y,yh,varargin)
% cmap: raw colormap to use, will default to thermal
% colorIndex: which color from the colormap should we use? There will be 12
% bins...
% group: does the scatter plot contain groups? Yes if not empty...
% gradient: use a different colormap for each group (if true)
% gradMaps: cell structure of gradient maps to use for each group
% gradMapsCall: use text to define which grad maps will be used...
% err: should we add error bars? Yes if not empty...
% useWholeMap: if true, then each point will get a unique color from the
% colormap...
% pointNames: if cell array, will put text next to each point
% fontSizeNames: size for font of text that goes next to each point (base
% font size)
% fontSize: how much to increase base font size (fontSizeNames) for labels
% etc
% offscaleFactor1: offscale factor for point names; higher = closer to dot
% (in x-dim)
% offscaleFactor2: offscale factor for point names; higher = closer to dot
% (in y-dim)
% jitter: some number 0-1 that randomly jitters text (offscaleFactor2)
% randomOffset: if true, we jitter above AND below true y-value
% distinctSamples
% markerAlpha: alpha for scatter plot dots and connected lines
% shadedAlpha: alpha for all elements of the shadded plot (note, the actual
% shading will be shadedAlpha/2)

% a,s,sh,p2,errY,errYh,t
%opts.cmap,opts.colorIndex,opts.group,opts.gradient,opts.gradMaps,opts.err,opts.useWholeMap,opts.pointNames)

% setup outputs
parts.annot = []; parts.scat = [];parts.shaded = [];parts.trend = [];parts.perfect = [];parts.connects = [];parts.errY = [];parts.errYh = [];parts.text = [];

% setup defaults
opts = struct('cmap',[],'colorIndex',4,'group',[],'gradient',false,'gradMaps',[],'bounds',{{'functional','off'}},'annot',true,...
    'gradMapsCall',{{'Purples';'Oranges';'Blues';'Greens';'Reds';'Greys'}},'err',[],'useWholeMap',false,'pointNames',[],'trendLineWidth',5,...
    'fontSizeNames',12,'fontSize',8,'offscaleFactor1',100,'offscaleFactor2',70,'jit',0.2,'randomOffset',true,'annotPos',[0.15 0.2 0.3504 0.0631],...
    'distinctSamples',false,'perfectY',true,'connectPerfect',false,'connectColors','consistent','extraData',[],...
    'markerAlpha',0.8,'shadedAlpha',0.4,'excludeExtremes',2,'pointNamesColor','consistent','newFig',true,'xlab',[],'ylab',[],'markFill',true,...
    'scatLinWidth',0.01,'markSz',400,'box','on','patchTop',false,'withHist',false);
optsNm = fieldnames(opts);

% Check inputs
if length(varargin) < 0
    error('You are missing an argument')
end
if length(varargin) > (length(fieldnames(opts))*2)
    error('You have supplied too many arguments')
end  
 
% remove NaNs...
idx = find(isnan(y));
y(idx) = []; yh(idx) = [];
if ~isempty(opts.err)
    opts.err(idx,:) = [];
end
if ~isempty(opts.pointNames)
    opts.pointNames(idx,:) = [];
end
if ~isempty(opts.cmap)
    opts.cmap(idx,:) = [];
end

idx = find(isnan(yh));
y(idx) = []; yh(idx) = [];
if ~isempty(opts.err)
    opts.err(idx,:) = [];
end
if ~isempty(opts.pointNames)
    opts.pointNames(idx,:) = [];
end
if ~isempty(opts.cmap)
    opts.cmap(idx,:) = [];
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

% check that group is not empty
if isempty(opts.group)
    opts.group = ones(size(y));
end

% check that too many args not passed in...
if (opts.gradient + opts.distinctSamples + opts.useWholeMap) > 1
    error('Select either to create distinct samples, assign each individual color in a colormap to each sample, OR have group gradients')
end

% create colors for each sample/point
un = unique(opts.group);
n = length(un);
if opts.gradient % if seperate colormap per group...
    if isempty(opts.gradMaps)
        for jj = 1:n
            nc = length(find(opts.group == un(jj)));
            tmp = cbrewer('seq',opts.gradMapsCall{jj},nc+opts.excludeExtremes);
            opts.gradMaps{jj} = tmp(opts.excludeExtremes+1:end,:);
        end
    end
    clrs = vertcat(opts.gradMaps{:});
elseif opts.distinctSamples
    clrs = distinguishable_colors(length(y),{'w','k'});
    clrs = clrs+0.1;
    idx = find(clrs > 1); clrs(idx) = 1;
    %clrs = distinguishable_colors(length(y)*2);
    %clrs = clrs(1:2:length(clrs),:);
else
    if isempty(opts.cmap) && ~opts.useWholeMap
        opts.cmap = cmocean('thermal',12);
    elseif isempty(opts.cmap) && opts.useWholeMap
        opts.cmap = cmocean('thermal',length(y));
    end
    
    if ~opts.useWholeMap
        if size(opts.cmap,1) == 1
           opts.colorIndex = 1;
        end
        clrs = opts.cmap(opts.colorIndex,:);
        clrs = repmat(clrs,[length(y),1]);
    else
        if size(opts.cmap,1) < length(y)
            error('Supplied colormap does not have enough colors for each sample')
        else
            clrs = opts.cmap(1:length(y),:);
        end
    end
end

ofsc = (abs(min(yh))+abs(max(yh)))/opts.offscaleFactor1;

if opts.newFig
    figure;
end
if opts.markFill
    if ~opts.withHist
        parts.scat = scatter(yh,y,opts.markSz,clrs(1:length(y),:),'filled','MarkerFaceAlpha',opts.markerAlpha,'LineWidth',opts.scatLinWidth); hold on
    else
        parts.scat = scatterhist(yh,y,'kernel','on','LineWidth',opts.scatLinWidth,'Direction','out'); hold on
        un = unique(clrs(1:length(y),:),'rows');
        parts.scat(1).Children.MarkerSize = opts.markSz/17;
        
        if size(un,1) == 1
            parts.scat(1).Children.Color = un;
            parts.scat(1).Children.MarkerFaceColor = un;
        else
            error('You cannot plot a scatter + histogram figure with varied sample colors')
        end        
    end
else
    parts.scat = scatter(yh,y,opts.markSz,clrs(1:length(y),:),'MarkerFaceAlpha',opts.markerAlpha,'LineWidth',opts.scatLinWidth); hold on
end

if ~isempty(opts.err)
    if opts.markerAlpha < 1
        disp('Error bars alpha cannot be set directly...we will try a hack but it may not work. I recommend setting markerAlpha to 1');
        al = opts.markerAlpha/1.3;
    end
    
    for ii = 1:length(y)
        parts.errY{ii} = errorbar(yh(ii),y(ii),opts.err(ii,1), 'LineStyle','none','Color',clrs(ii,:),'LineWidth',3);
        parts.errYh{ii} = errorbar(yh(ii),y(ii),opts.err(ii,2),'horizontal','LineStyle','none','Color',clrs(ii,:),'LineWidth',3);
        
        if opts.markerAlpha < 1
            set([parts.errY{ii}.Bar, parts.errY{ii}.Line], 'ColorType', 'truecoloralpha', 'ColorData', [parts.errY{ii}.Line.ColorData(1:3); 255*al])
            set([parts.errYh{ii}.Bar, parts.errYh{ii}.Line], 'ColorType', 'truecoloralpha', 'ColorData', [parts.errYh{ii}.Line.ColorData(1:3); 255*al])
            
            set(parts.errY{ii}.Cap, 'EdgeColorType', 'truecoloralpha', 'EdgeColorData', [parts.errY{ii}.Cap.EdgeColorData(1:3); 255*al])
            set(parts.errYh{ii}.Cap, 'EdgeColorType', 'truecoloralpha', 'EdgeColorData', [parts.errYh{ii}.Cap.EdgeColorData(1:3); 255*al])
        end
    end
end

if ~isempty(opts.pointNames)
    for ii = 1:length(y)
        ofscmp = randi([opts.offscaleFactor2-(opts.offscaleFactor2*opts.jit) opts.offscaleFactor2+(opts.offscaleFactor2*opts.jit)]);
        ofsc2 = (abs(min(y))+abs(max(y)))/ofscmp;
        if opts.randomOffset
            if randi([0,1]) == 0
                ofsc2=-1*ofsc2;
            end
        end
        
        if isa(opts.pointNamesColor,'double')
            tmpc = opts.pointNamesColor;
        else
            tmpc = clrs(ii,:);
        end
        
        if ~isempty(opts.err)
            parts.text(ii) = text(yh(ii)+opts.err(ii,1)+ofsc,y(ii)+ofsc2,opts.pointNames{ii},'Color',tmpc,'FontSize',opts.fontSizeNames);
        else
            parts.text(ii) = text(yh(ii)+ofsc,y(ii)+ofsc2,opts.pointNames{ii},'Color',tmpc,'FontSize',opts.fontSizeNames);
        end
    end
end

if size(y,1) < size(y,2)
    y=y';
end
if size(yh,1) < size(yh,2)
    yh=yh';
end

x1 = linspace(min(yh),max(yh));[tmp,gof] = fit(yh,y,'poly1');%,'Robust','Bisquare');
parts.trend = plot(tmp,yh,y); parts.trend(2).Color = [mean(clrs) opts.shadedAlpha]; parts.trend(1).Visible = 'off'; parts.trend(2).LineWidth = opts.trendLineWidth;
[ci,ytmp] = predint(tmp,x1,0.95,opts.bounds{:});
parts.shaded = shadedErrorBar(x1,ytmp,ci,'lineprops',mean(clrs));
%legend off; 
delete(legend)
if ~isempty(parts.shaded.patch)
    parts.shaded.patch.FaceAlpha = opts.shadedAlpha/2; parts.shaded.edge(1).LineWidth = 5; parts.shaded.edge(2).LineWidth = 5; parts.shaded.edge(1).Color = [mean(clrs) opts.shadedAlpha]; parts.shaded.edge(2).Color = [mean(clrs) opts.shadedAlpha];
    parts.shaded.edge(1).Visible = 'off';parts.shaded.edge(2).Visible = 'off'; parts.shaded.mainLine.Visible = 'off'; parts.shaded.mainLine.LineStyle = '--';
    parts.shaded.edge(1).LineStyle = ':'; parts.shaded.edge(2).LineStyle = ':';
end

if isempty(opts.xlab)
    xlabel('predicted');
elseif strcmpi(opts.xlab,'none')
    xlabel('');
else
    xlabel(opts.xlab);
end
 
if isempty(opts.ylab)
    ylabel('observed');
elseif strcmpi(opts.ylab,'none')
    ylabel('');
else
    ylabel(opts.ylab);
end

[rV,pV] = corr(yh,y);
if opts.annot
    parts.annot = annotation('textbox','String',['r2 = ' num2str(rV.^2) ' , p = ' num2str(pV)],'FitBoxToText','on','FontSize',opts.fontSizeNames+opts.fontSize,'EdgeColor','none');
    parts.annot.Position = opts.annotPos;
end

if opts.box
    box on
else
    box off
end

set(gcf,'color','w'); ax = gca; ax.LineWidth = 2; grid on; set(gca,'TickLength',[0.02 0.02]); set(gca,'FontSize',opts.fontSizeNames+opts.fontSize)

if opts.connectPerfect
    for i = 1:length(y)
        if isa(opts.connectColors,'double')
            tmpc = [opts.connectColors opts.markerAlpha/2];
        else
            tmpc = [clrs(i,:) opts.markerAlpha];
        end
        %parts.connects(i) = plot([yh(i) yh(i)],[yh(i) y(i)],'LineWidth',4,'Color',tmpc);
        parts.connects(i) = plot([y(i) yh(i)],[y(i) y(i)],'LineWidth',4,'Color',tmpc);
    end
end

h1 = findobj(gca,'Type','Line');
h2 = findobj(gca,'Type','Scatter');
h3 = findobj(gca,'Type','Patch');
h4 = findobj(gca,'Type','ErrorBar');
h5 = findobj(gca,'Type','Text');
if opts.patchTop
    ax.Children = [h5; h1; h3; h2; h4];
else
    ax.Children = [h5; h2; h1; h3; h4];
end


if opts.perfectY
    parts.perfect = plot(y,y,'LineWidth',5,'Color',[0 0 0]);
end

