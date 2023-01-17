function [colorMapInterp] = customColorMapInterpBars2(colorMap)
% This script will create a customized colormap by interpolating between
% two colorBars given by colorMap
% Alex Teghipco // alex.teghipco@uci.edu // 11/28/18

cb1 = size(colorMap{1},1);
cb2 = size(colorMap{2},1);

[mx,mv] = max([cb1 cb2]);
mv2 = setdiff([1 2],mv);
tmpMap = colorMap{mv2};

% if you do need to interpolate, you need to find out if the
% original colormap used 2 or 3 colors...to do this, first
% interpolate between edges of colormap, then see if middle lines
% up.
ends = customColorMapInterp([tmpMap(1,:) ; tmpMap(end,:)],size(tmpMap,1));
mdpt = ends(round(size(ends,1)/2),:);
if isequal(tmpMap(round(size(ends,1)/2),1),mdpt(1)) & isequal(tmpMap(round(size(ends,1)/2),2),mdpt(2)) & isequal(tmpMap(round(size(ends,1)/2),3),mdpt(3))
    cMap = customColorMapInterp([tmpMap(1,:) ; tmpMap(end,:)],mx);
else
    cMap1 = customColorMapInterp([tmpMap(1,:) ; tmpMap(round(size(ends,1)/2),:)],round(mx/2));
    cMap2 = customColorMapInterp([tmpMap(round(size(ends,1)/2),:) ; tmpMap(end,:)],mx - round(mx/2));
    cMap = [cMap1; cMap2];
end

cm(:,:,1) = colorMap{mv};
cm(:,:,2) = cMap;

colorMapInterp = ones(cb1,cb2,3);
try
    colorMapInterp(:,1,:) = cm(:,:,1);
    colorMapInterp(:,size(colorMap{mv2},1),:) = cm(:,:,2);
    for beti = 1:size(colorMapInterp,1)
        r(beti,:) = linspace(cm(beti,1,1), cm(beti,1,2),size(colorMap{mv2},1));
        g(beti,:) = linspace(cm(beti,2,1), cm(beti,2,2),size(colorMap{mv2},1));
        b(beti,:) = linspace(cm(beti,3,1), cm(beti,3,2),size(colorMap{mv2},1));
    end
    colorMapInterp(:,:,1) = r;
    colorMapInterp(:,:,2) = g;
    colorMapInterp(:,:,3) = b;
catch
    colorMapInterp(1,:,:) = cm(:,:,1);
    colorMapInterp(size(colorMap{mv2},1),:,:) = cm(:,:,2);
    for beti = 1:size(colorMapInterp,2)
        r(beti,:) = linspace(cm(beti,1,1), cm(beti,1,2),size(colorMap{mv2},1));
        g(beti,:) = linspace(cm(beti,2,1), cm(beti,2,2),size(colorMap{mv2},1));
        b(beti,:) = linspace(cm(beti,3,1), cm(beti,3,2),size(colorMap{mv2},1));
    end
    colorMapInterp(:,:,1) = r';
    colorMapInterp(:,:,2) = g';
    colorMapInterp(:,:,3) = b';
end
