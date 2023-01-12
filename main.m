
%% Load in data
data = readtable('LockedCerebellumData_healthy.csv');
% dataCon = data(:,[3 4 5 19 20]); 
% dataCorr = data(:,[75 76 77 107 108 109]);
data2 = readtable('LockedCerebellumData_stroke.csv');
% dataCon2 = data(:,[3 4 5 19 20]); 
% dataCorr2 = data(:,[75 76 77 107 108 109]);

data = data(:,[3 4 5 19 20 75 76 77 107 108 109]);
data2 = data2(:,[3 4 5 19 20 75 76 77 107 108 109]);

%% Fix idiosyncracies of this dataset
data.daysPostStroke(:,1) = 0;
data.LesionSizeVoxels(:,1) = 0;

tmp = data.Properties.VariableNames;
data.Properties.VariableNames = {'Age'	'Sex'	'Race'	'DaysPostStroke'	'LesionSize'	'Total GMV'	'Left GMV'	'Right GMV'	'Total WMV'	'Left WMV'	'Right WMV'};
data2.Properties.VariableNames = {'Age'	'Sex'	'Race'	'DaysPostStroke'	'LesionSize'	'Total GMV'	'Left GMV'	'Right GMV'	'Total WMV'	'Left WMV'	'Right WMV'};

%% Colors for correlogram
c1 =  [0.0745098039215686         0.501960784313725         0.525490196078431];
c2 = [0.980392156862745         0.933333333333333         0.262745098039216];
c3 = [0.56         0.16                       0.48];

%% R and p values to display on scatterplot
[r,p] = corr(table2array(data),'rows','pairwise');
[r2,p2] = corr(table2array(data2),'rows','pairwise');

ut = triu(r);
lt = tril(r2);
rMat = ut + tril(lt,-1);

ut = triu(p);
lt = tril(p2);
pMat = ut + tril(lt,-1);
pMat(find(eye(size(pMat)))) = 0;

for i = 1:size(data,2)
    for j = 1:size(data,2)
        [dr(i,j), dp(i,j), ~, ~] = bcdistcorr(table2array(data(:,i)), table2array(data(:,j)));
    end
end
for i = 1:size(data2,2)
    for j = 1:size(data2,2)
        [dr2(i,j), dp2(i,j), ~, ~] = bcdistcorr(table2array(data2(:,i)), table2array(data2(:,j)));
    end
end

ut = triu(dr);
lt = tril(dr2);
drMat = ut + tril(lt,-1);

ut = triu(dp);
lt = tril(dp2);
dpMat = ut + tril(lt,-1);

posp = [0.05 0.01 0.001 0.0001 0.00001];
for i = 1:numel(rMat)
    disp(num2str(i))
    rtmp = num2str(round(rMat(i).^2,2));
    drtmp = num2str(round(drMat(i),2));
    idx = find(pMat(i) <= posp);
    idx2 = find(dpMat(i) <= posp);
    if ~isempty(idx) && ~isempty(idx2)
       txtClr{i} = [1 0 0];
       ptmp = ['<' num2str(posp(max(idx)))];
       dptmp = ['<' num2str(posp(max(idx2)))];
    end
    if isempty(idx) && ~isempty(idx2)
       txtClr{i} =  [0         0.447058823529412         0.741176470588235];
       ptmp = ['>0.05'];
       dptmp = ['<' num2str(posp(max(idx2)))];
    end
    if ~isempty(idx) && isempty(idx2)
       txtClr{i} = [0.0509803921568627         0.788235294117647                         0];
       ptmp = [' <' num2str(posp(max(idx)))];
       dptmp = ['>0.05'];
    end
    if isempty(idx) && isempty(idx2)
       txtClr{i} = [0 0 0];
       ptmp = ['>0.05'];
       dptmp = ['>0.05'];
    end
    
    txt{i} = ['r^{2}=' rtmp ',p' ptmp ';dc=' drtmp ',p' dptmp];   
    disp(txt{i})
end
tmpTxt = reshape(txt,[size(data,2),size(data,2)]);
tmpTxtClr = reshape(txtClr,[size(data,2),size(data,2)]);

[t,parts,parts2,h,h2] = correlogram(data,data2,[c1; c2; c3],true,tmpTxt,tmpTxtClr,true,data2.Properties.VariableNames(1:end));


%% now repeat with partial correlations...
clear r p r2 p2 rMat pMat dr dr2 drMat dpMat txtClr txt
dataClean = table2array(data(:,6:end));
data2Clean = table2array(data2(:,6:end));
dataDe = table2array(data(:,1:3));
dataDe2 = table2array(data2(:,1:5));
[r,p] = partialcorr(dataClean,dataClean,dataDe,'rows','pairwise');
[r2,p2] = partialcorr(data2Clean,data2Clean,dataDe2,'rows','pairwise');

ut = triu(r);
lt = tril(r2);
rMat = ut + tril(lt,-1);

ut = triu(p);
lt = tril(p2);
pMat = ut + tril(lt,-1);
pMat(find(eye(size(pMat)))) = 0;

for i = 1:size(dataClean,2)
    for j = 1:size(dataClean,2)
        [dr(i,j), dp(i,j)] = pdc(dataClean(:,i), dataClean(:,j),dataDe);
    end
end
for i = 1:size(dataClean,2)
    for j = 1:size(dataClean,2)
        [dr2(i,j), dp2(i,j)] = pdc(data2Clean(:,i), data2Clean(:,j),dataDe2);
    end
end

ut = triu(dr);
lt = tril(dr2);
drMat = ut + tril(lt,-1);

ut = triu(dp);
lt = tril(dp2);
dpMat = ut + tril(lt,-1);

posp = [0.05 0.01 0.001 0.0001 0.00001];
for i = 1:numel(rMat)
    disp(num2str(i))
    rtmp = num2str(round(rMat(i).^2,2));
    drtmp = num2str(round(drMat(i),2));
    idx = find(pMat(i) <= posp);
    idx2 = find(dpMat(i) <= posp);
    if ~isempty(idx) && ~isempty(idx2)
       txtClr{i} = [1 0 0];
       ptmp = ['<' num2str(posp(max(idx)))];
       dptmp = ['<' num2str(posp(max(idx2)))];
    end
    if isempty(idx) && ~isempty(idx2)
       txtClr{i} =  [0         0.447058823529412         0.741176470588235];
       ptmp = ['>0.05'];
       dptmp = ['<' num2str(posp(max(idx2)))];
    end
    if ~isempty(idx) && isempty(idx2)
       txtClr{i} = [0.0509803921568627         0.788235294117647                         0];
       ptmp = [' <' num2str(posp(max(idx)))];
       dptmp = ['>0.05'];
    end
    if isempty(idx) && isempty(idx2)
       txtClr{i} = [0 0 0];
       ptmp = ['>0.05'];
       dptmp = ['>0.05'];
    end
    
    txt{i} = ['r^{2}=' rtmp ',p' ptmp ';dc=' drtmp ',p' dptmp];   
    disp(txt{i})
end
tmpTxt = reshape(txt,[size(data2Clean,2),size(data2Clean,2)]);
tmpTxtClr = reshape(txtClr,[size(data2Clean,2),size(data2Clean,2)]);

% now get residuals...
for i = 1:size(dataClean,2)
    mdl = fitlm(dataDe,dataClean(:,i));
    dataCleanRes(:,i) = mdl.Residuals.Raw;

    mdl = fitlm(dataDe2,data2Clean(:,i));
    dataCleanRes2(:,i) = mdl.Residuals.Raw;
end

[t,parts,parts2,h,h2] = correlogram(dataCleanRes,dataCleanRes2,[c1; c2; c3],true,tmpTxt,tmpTxtClr,true,data2.Properties.VariableNames(6:end));




%% scratch work

n = size(data,2);
tot =((nchoosek(n,2))*2)+n;%n;
c1 =  [0.0745098039215686         0.501960784313725         0.525490196078431];
c2 = [0.980392156862745         0.933333333333333         0.262745098039216];
c3 = [0.56         0.16                       0.48];
[cMap] = customColorMapInterp([c1; c2; c3],n+3)
cMap(round(size(cMap,1)/2),:) = [];
cMap(round(size(cMap,1)/2)+1,:) = [];
cMap(round(size(cMap,1)/2)-1,:) = [];

%[cMap,~,~,~,~] = colormapper([1:n+2],'colormap','curl','colorBins',n+2);
%load('/Users/alex/Documents/GitHub/brainSurfer-v2/colormaps/ForCorrel.mat')
%cMap = customColor;
%cMap(1,:) = [];
%cMap(end,:) = [];
%cMap = cMap(1:end-2,:);
%cMap = flipud(cMap);

rw = 1:n:tot;
cw = rw(end):tot;
rw(1) = rw(1) + 1;
dw = 1:n+1:tot;
%k = [rw cw];

figure; t = tiledlayout(n,n,'TileSpacing','tight','Padding','compact');
for i = 1:n
    mni = fix(min([table2array(data2(:,i)); table2array(data(:,i))]));
    mxi = ceil(max([table2array(data2(:,i)); table2array(data(:,i))]));
    t1 = round(linspace(mni,mxi,5),2);
    %xticks([0 5 10])
    
    for j = 1:n
        nexttile
        c = cMap(min([i j]),:);
        c2 = c+0.1; id = find(c2 > 1);c2(id) = 1;
        ind = ((11*i)-11)+j;
        
        mnj = fix(min([table2array(data2(:,j)); table2array(data(:,j))]));
        mxj = ceil(max([table2array(data2(:,j)); table2array(data(:,j))]));
        t2 = round(linspace(mnj,mxj,5),2);
        
        if j < i
            %subplot(n,n,ind)
            parts{i,j} = quickScatter(table2array(data2(:,i)),table2array(data2(:,j)),'cmap',c,'newFig',false,'scatLinWidth',2,'markSz',150,'bounds',{'functional','on'},...
                'markerAlpha',0.2,'shadedAlpha',0.9,'colorIndex',2,'perfectY',false,'xlab','none','ylab','none','markFill',true,'annot',false,'trendLineWidth',1,...
                'box',true,'xlab',data2(:,j).Properties.VariableNames{1},'ylab',data2(:,i).Properties.VariableNames{1},'fontSizeNames',6,'fontSize',6,'patchTop',true);
            ylim(gca,[mni mxi]);
            xlim(gca,[mnj mxj]);
            xticks(t2);
            yticks(t1);
            
        elseif j > i
            %subplot(n,n,ind)
            parts2{i,j} = quickScatter(table2array(data(:,i)),table2array(data(:,j)),'cmap',c2,'newFig',false,'scatLinWidth',2,'markSz',150,'bounds',{'functional','on'},...
                'markerAlpha',0.2,'shadedAlpha',0.9,'colorIndex',2,'perfectY',false,'xlab','none','ylab','none','markFill',true,'annot',false,'trendLineWidth',1,...
                'box',true,'xlab',data(:,j).Properties.VariableNames{1},'ylab',data(:,i).Properties.VariableNames{1},'fontSizeNames',6,'fontSize',6,'patchTop',false);
            ylim(gca,[mni mxi]);
            xlim(gca,[mnj mxj]);
            xticks(t2);
            yticks(t1);
            
        elseif j == i
           %subplot(n,n,ind)
           un = unique(table2array(data2(:,i)));
           un2 = unique(table2array(data(:,i)));
           un = [un; un2];
           if length(un) > 2 && length(un) >= 25
               un2 = unique(table2array(data(:,i)));
               e = linspace(min(un),max(un),25);
           elseif length(un) < 25 && length(un) > 2
               un2 = unique(table2array(data(:,i)));
               e = linspace(min(un),max(un),length(un));
           else
               e = [1 2];
           end
           
           h{i,j} = histogram(table2array(data2(:,i)),e);
           h{i,j}.FaceColor = c2;
           h{i,j}.FaceAlpha = 0.5;
           h{i,j}.EdgeColor = 'none';
           hold on
           h2{i,j} = histogram(table2array(data(:,j)),e);
           h2{i,j}.FaceColor = c;
           h2{i,j}.FaceAlpha = 0.5;
           h2{i,j}.EdgeColor = 'none';
           
           ax = gca; ax.LineWidth = 2; grid on; set(gca,'TickLength',[0.02 0.02]);
           xlabel(data2(:,i).Properties.VariableNames{1})
           ylabel('Density')
           set(gca,'FontSize',12)
        end
        
        if isempty(intersect(ind,cw)) && isempty(intersect(ind,dw))
            xlabel('')
            set(gca,'Xticklabel',[])
        else 
           
        end
        if isempty(intersect(ind,rw)) && isempty(intersect(ind,dw))
            ylabel('')
            set(gca,'Yticklabel',[])
        else

        end
    end
end

for i = 1:length(t.Children)
    t.Children(i).Layout.TileSpan = [2 1];
end

