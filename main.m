%% Example for using correlogram...note we will use the PDC toolbox

%% Load in data
data = readtable('LockedCerebellumData_healthy.csv');
% dataCon = data(:,[3 4 5 19 20]); 
% dataCorr = data(:,[75 76 77 107 108 109]);
data2 = readtable('LockedCerebellumData_stroke.csv');
% dataCon2 = data(:,[3 4 5 19 20]); 
% dataCorr2 = data(:,[75 76 77 107 108 109]);

data = data(:,[3 4 5 19 20 75 76 77 107 108 109]);
data2 = data2(:,[3 4 5 19 20 75 76 77 107 108 109]);

%% Fix idiosyncracies of this dataset...ignore this for your own data
data.daysPostStroke(:,1) = 0;
data.LesionSizeVoxels(:,1) = 0;

tmp = data.Properties.VariableNames;
data.Properties.VariableNames = {'Age'	'Sex'	'Race'	'DaysPostStroke'	'LesionSize'	'Total GMV'	'Left GMV'	'Right GMV'	'Total WMV'	'Left WMV'	'Right WMV'};
data2.Properties.VariableNames = {'Age'	'Sex'	'Race'	'DaysPostStroke'	'LesionSize'	'Total GMV'	'Left GMV'	'Right GMV'	'Total WMV'	'Left WMV'	'Right WMV'};

%% Colors for correlogram...we will interpolate between these to assign colors to individual scatterplots
c1 =  [0.0745098039215686         0.501960784313725         0.525490196078431];
c2 = [0.980392156862745         0.933333333333333         0.262745098039216];
c3 = [0.56         0.16                       0.48];

%% Get annotations to display with each scatterplot...in this case we want pearson correlation coefficient and distance correlation r and p values to display
% Computing pearson correlation coefficients
[r,p] = corr(table2array(data),'rows','pairwise');
[r2,p2] = corr(table2array(data2),'rows','pairwise');

% combine upper and lower triangles into one square matrix
rMat = combMats(r,r2,[]);
pMat = combMats(p,p2,0);

% computing distance correlations manually here...
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

% combine upper and lower triangles into one square matrix
drMat = combMats(dr,dr2,[]);
dpMat = combMats(dp,dp2,0);

% now lets get text for annotations that will be displayed on each
% scatterplot and lets also assign colors to text to code information about
% significance
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

[t,parts,parts2,h,h2] = correlogram(data,data2,'clrs',[c1; c2; c3],'histLine',true,'txt',tmpTxt,'txtClr',tmpTxtClr,'saveFig',false,'lblsX',data2.Properties.VariableNames(1:end),'lblsY',[],...
    'newFig',false,'scatLinWidth',2,'markSz',150,'bounds',{'functional','on'},...
    'markerAlpha',0.4,'shadedAlpha',0.9,'markFill',true,'trendLineWidth',4,...
    'box',true,'fontSizeNames',8,'fontSize',8);


%% now repeat with partial correlations...
clear r p r2 p2 rMat pMat txtClr txt drMat dpMat dr dr2 dp dp2
dataClean = table2array(data(:,6:end));
data2Clean = table2array(data2(:,6:end));
dataDe = table2array(data(:,1:3));
dataDe2 = table2array(data2(:,1:5));

[r,p] = partialcorr(dataClean,dataClean,dataDe,'rows','pairwise');
[r2,p2] = partialcorr(data2Clean,data2Clean,dataDe2,'rows','pairwise');

rMat = combMats(r,r2,[]);
pMat = combMats(p,p2,0);

for i = 1:size(dataClean,2)
    for j = 1:size(dataClean,2)
        [dr(i,j), dp(i,j), ~, ~, ~, ~] = pdc(dataClean(:,i), dataClean(:,j),dataDe,'distance',false);
    end
end
for i = 1:size(dataClean,2)
    for j = 1:size(dataClean,2)
        [dr2(i,j), dp2(i,j), ~, ~, ~, ~] = pdc(data2Clean(:,i), data2Clean(:,j),dataDe2,'distance',false);
    end
end
drMat = combMats(dr,dr2,[]);
dpMat = combMats(dp,dp2,0);

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
    %disp(txt{i})
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

%% now do the same with other vars
% GMV total, left right sym, wmv total, left, right sym CORR WITH wabtot,
% wabresp,wabcomp,wabrep
data = readtable('LockedCerebellumData_healthy.csv');
% dataCon = data(:,[3 4 5 19 20]); 
% dataCorr = data(:,[75 76 77 107 108 109]);
data2 = readtable('LockedCerebellumData_stroke.csv');
% dataCon2 = data(:,[3 4 5 19 20]); 
% dataCorr2 = data(:,[75 76 77 107 108 109]);

data = data(:,[3 4 5 19 20 75 76 77 107 108 109 78 110 21 22 23 24 25]);
data2 = data2(:,[3 4 5 19 20 75 76 77 107 108 109 78 110 21 22 23 24 25]);

%% Fix idiosyncracies of this dataset...ignore this for your own data
data.daysPostStroke(:,1) = 0;
data.LesionSizeVoxels(:,1) = 0;

tmp = data.Properties.VariableNames;
% data.Properties.VariableNames = {'Age'	'Sex'	'Race'	'DaysPostStroke'	'LesionSize'	'Total GMV'	'Left GMV'	'Right GMV' 'Total WMV'	'Left WMV'	'Right WMV'   'GMSym'	'WMSym' 'WAB Total' 'Spontaneous'  'Comprehension'  'Repetition'  'Naming'};
data2.Properties.VariableNames = {'Age'	'Sex'	'Race'	'DaysPostStroke'	'LesionSize'	'Total GMV'	'Left GMV'	'Right GMV' 'Total WMV'	'Left WMV'	'Right WMV'   'GMSym'	'WMSym' 'WAB Total' 'Spontaneous'  'Comprehension'  'Repetition'  'Naming'};

clear r p r2 p2 rMat pMat txtClr txt drMat dpMat dr dr2 dp dp2
% dataCleanX = table2array(data(:,6:end-5));
% dataCleanY = table2array(data(:,6+8:end));
% dataDe = table2array(data(:,1:3));

data2CleanX = table2array(data2(:,6:end-5));
labX = data2.Properties.VariableNames(6:end-5);
data2CleanY = table2array(data2(:,6+8:end));
labY = data2.Properties.VariableNames(6+8:end);
dataDe2 = table2array(data2(:,1:5));
idx = find(isnan(data2CleanY));
clear idx2
[idx2(:,1),idx2(:,2)] = ind2sub([size(data2CleanY,1),size(data2CleanY,2)],idx);
idx = unique(idx2);
data2CleanX(idx,:) = [];
data2CleanY(idx,:) = [];
dataDe2(idx,:) = [];

[r,p] = partialcorr(data2CleanX,data2CleanY,dataDe2,'rows','pairwise');
p = p/2;

% rMat = combMats(r,r2,[]);
% pMat = combMats(p,p2,0);

for i = 1:size(data2CleanX,2)
    for j = 1:size(data2CleanY,2)
        [dr2(i,j), dp2(i,j), ~, ~, ~, ~] = pdc(data2CleanX(:,i), data2CleanY(:,j),dataDe2,'distance',false);
    end
end
dp2 = dp2/2;

posp = [0.05 0.01 0.001 0.0001 0.00001];
for i = 1:numel(r)
    disp(num2str(i))
    rtmp = num2str(round(r(i).^2,2));
    drtmp = num2str(round(dr2(i),2));
    idx = find(p(i) <= posp);
    idx2 = find(dp2(i) <= posp);
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
    %disp(txt{i})
end
tmpTxt = reshape(txt,[size(data2CleanX,2),size(data2CleanY,2)]);
tmpTxtClr = reshape(txtClr,[size(data2CleanX,2),size(data2CleanY,2)]);

% now get residuals...
for i = 1:size(data2CleanX,2)
    mdl = fitlm(dataDe2,data2CleanX(:,i));
    dataXCleanRes(:,i) = mdl.Residuals.Raw;
end
for i = 1:size(data2CleanY,2)
    mdl = fitlm(dataDe2,data2CleanY(:,i));
    dataYCleanRes(:,i) = mdl.Residuals.Raw;
end

% color scratch...will work!
% clrs = distinguishable_colors(13,{'w','k'});
% clrsX = clrs(1:8,:);
% clrsY = clrs(9:end,:);
% figure; t = tiledlayout(8,5,'TileSpacing','tight','Padding','compact');
% for i = 1:8
%     for j = 1:5
%         nexttile
%         m = mean([clrsX(i,:); clrsY(j,:)]);
%         h = imagesc([ones(8,5)]);
%         colormap(h.Parent,m)
%     end
% end

% alternative is to use colorbars -- rows = cool, cols = summer
 parts = quickScatter(dataXCleanRes(:,1),dataYCleanRes(:,j),'cmap',clrs(1,:),'newFig',false,'scatLinWidth',2,'markSz',150,'bounds',{'functional','on'},...
                'markerAlpha',0.4,'shadedAlpha',0.9,'colorIndex',2,'perfectY',false,'xlab','none','ylab','none','markFill',true,'annot',false,'trendLineWidth',4,...
                'box',true,'xlab','x','ylab','y','fontSizeNames',6,'fontSize',6,'patchTop',true,'withHist',true);

[t,parts,parts2,h,h2,annot] = correlogram(dataXCleanRes,dataYCleanRes,'clrs',[c1; c2; c3],'histLine',true,'txt',tmpTxt,'txtClr',tmpTxtClr,'saveFig',false,'lblsX',labX,'lblsY',labY,...
    'newFig',false,'scatLinWidth',2,'markSz',150,'bounds',{'functional','on'},...
    'markerAlpha',0.4,'shadedAlpha',0.9,'markFill',true,'trendLineWidth',4,...
    'box',true,'fontSizeNames',8,'fontSize',8);
