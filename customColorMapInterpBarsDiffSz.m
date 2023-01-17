function [colorMapInterp] = customColorMapInterpBarsDiffSz(colorMap)
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
cm(:,:,2)= cMap;
[colorMapInterp] = customColorMapInterpBars2(cm,size(colorMap{mv},1),'same'); % 8 x 8 x 3



for i = 1:size(colorMapInterp,1)
    tmpMap = squeeze(colorMapInterp(i,:,:));
    ends = customColorMapInterp([tmpMap(1,:) ; tmpMap(end,:)],size(tmpMap,1));
    mdpt = ends(round(size(ends,1)/2),:);
    if isequal(tmpMap(round(size(ends,1)/2),1),mdpt(1)) & isequal(tmpMap(round(size(ends,1)/2),2),mdpt(2)) & isequal(tmpMap(round(size(ends,1)/2),3),mdpt(3))
        cMap = customColorMapInterp([tmpMap(1,:) ; tmpMap(end,:)],size(colorMap{mv2},1));
    else
        cMap1 = customColorMapInterp([tmpMap(1,:) ; tmpMap(round(size(ends,1)/2),:)],round(size(colorMap{mv2},1)/2));
        cMap2 = customColorMapInterp([tmpMap(round(size(ends,1)/2),:) ; tmpMap(end,:)],size(colorMap{mv2},1) - round(size(colorMap{mv2},1)/2));
        cMap = [cMap1; cMap2];
    end
    
    
    cMap = customColorMapInterp([tmpMap(1,:) ; tmpMap(end,:)],mx);%size(colorMap{mv2},1)
    
end






colorMapInterp(:,1,:) = colorMap(:,:,1);
colorMapInterp(:,colorBins,:) = colorMap(:,:,2);

for beti = 1:size(colorMapInterp,1)
    r(beti,:) = linspace(colorMap(beti,1,1), colorMap(beti,1,2),colorBins-2);
    g(beti,:) = linspace(colorMap(beti,2,1), colorMap(beti,2,2),colorBins-2);
    b(beti,:) = linspace(colorMap(beti,3,1), colorMap(beti,3,2),colorBins-2);
end

colorMapInterp(:,2:end-1,1) = r;
colorMapInterp(:,2:end-1,2) = g;
colorMapInterp(:,2:end-1,3) = b;




switch interpDir
    case 'same'
        
        for beti = 1:size(colorMapInterp,1)
            tmp1 = colorMap{1}(beti,:);
            tmp1r = repmat(tmp1,size(colorMapInterp,2),1);
            for beti2 = 1:size(colorMapInterp,2)
                tmp1 = colorMap{2}(beti2,:);
                
                for j = 1:3
                    
                    tmp2 =
                    
                    
                    tmp2 = repmat(colorMap(beti,j,2),size(tmp1));
                    
                    colorMapInterp(:,beti,j) = (tmp1+tmp2)./2;
                end
            end
        end

        
        
        colorMapInterp(:,1,:) = colorMap(:,:,1);
        colorMapInterp(:,colorBins,:) = colorMap(:,:,2);
        
        for beti = 1:size(colorMapInterp,1)
            r(beti,:) = linspace(colorMap(beti,1,1), colorMap(beti,1,2),colorBins-2);
            g(beti,:) = linspace(colorMap(beti,2,1), colorMap(beti,2,2),colorBins-2);
            b(beti,:) = linspace(colorMap(beti,3,1), colorMap(beti,3,2),colorBins-2);
        end
        
        colorMapInterp(:,2:end-1,1) = r;
        colorMapInterp(:,2:end-1,2) = g;
        colorMapInterp(:,2:end-1,3) = b;
        
        %figure; imshow(colorMapInterp);
        
    case 'different'
        
        for beti = 1:size(colorMapInterp,1)
            tmp1 = colorMap{1}(beti,:);
            tmp1r = repmat(tmp1,size(colorMapInterp,2),1);
            for beti2 = 1:size(colorMapInterp,2)
                tmp1 = colorMap{2}(beti2,:);
                
                for j = 1:3
                    
                    tmp2 =
                    
                    
                    tmp2 = repmat(colorMap(beti,j,2),size(tmp1));
                    
                    colorMapInterp(:,beti,j) = (tmp1+tmp2)./2;
                end
            end
        end

end