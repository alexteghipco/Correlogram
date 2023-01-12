function varargout=shadedErrorBar(x,y,errBar,varargin)
% generate continuous error bar area around a line plot
%
% function H=shadedErrorBar(x,y,errBar, ...)
%
% Purpose 
% Makes a 2-d line plot with a pretty shaded error bar made
% using patch. Error bar color is chosen automatically.
%
%
% Inputs (required)
% x - vector of x values [optional, can be left empty]
% y - vector of y values or a matrix of n observations by m cases
%     where m has length(x);
% errBar - if a vector we draw symmetric errorbars. If it has a size
%          of [2,length(x)] then we draw asymmetric error bars with
%          row 1 being the upper bar and row 2 being the lower bar
%          (with respect to y). ** alternatively ** errBar can be a
%          cellArray of two function handles. The first defines which
%          statistic the line should be and the second defines the
%          error bar.
%
% Inputs (optional, param/value pairs)
% 'lineProps' - ['-k' by default] defines the properties of
%             the data line. e.g.:    
%             'or-', or {'-or','markerfacecolor',[1,0.2,0.2]}
% 'transparent' - [true  by default] if true, the shaded error
%               bar is made transparent. However, for a transparent
%               vector image you will need to save as PDF, not EPS,
%               and set the figure renderer to "painters". An EPS 
%               will only be transparent if you set the renderer 
%               to OpenGL, however this makes a raster image.
%
%
% Outputs
% H - a structure of handles to the generated plot objects.
%
%
% Examples:
% y=randn(30,80); 
% x=1:size(y,2);
%
% 1)
% shadedErrorBar(x,mean(y,1),std(y),'lineprops','g');
%
% 2)
% shadedErrorBar(x,y,{@median,@std},'lineprops',{'r-o','markerfacecolor','r'});
%
% 3)
% shadedErrorBar([],y,{@median,@(x) std(x)*1.96},'lineprops',{'r-o','markerfacecolor','k'});
%
% 4)
% Overlay two transparent lines:
% clf
% y=randn(30,80)*10; 
% x=(1:size(y,2))-40;
% shadedErrorBar(x,y,{@mean,@std},'lineprops','-r','transparent',1);
% hold on
% y=ones(30,1)*x; y=y+0.06*y.^2+randn(size(y))*10;
% shadedErrorBar(x,y,{@mean,@std},'lineprops','-b','transparent',1);
% hold off
%
%
% Rob Campbell - November 2009



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Parse input arguments
narginchk(3,inf)

params = inputParser;
params.CaseSensitive = false;
params.addParameter('lineProps', 'black')%@(x) ischar(x) | iscell(x));
params.addParameter('transparent', true, @(x) islogical (x) || x==0 || x==1);
params.addParameter('patchSaturation', 0.2, @(x) isnumeric(x) && x>=0 && x<=1);

params.parse(varargin{:});

%Extract values from the inputParser
lineProps =  params.Results.lineProps;

if ~iscell(lineProps), lineProps={lineProps}; end
lineProps =  params.Results.lineProps;
if ~isempty(varargin), lineProps = varargin{2}; end
transparent =  params.Results.transparent;
patchSaturation = params.Results.patchSaturation;

%Process y using function handles if needed to make the error bar
%dynamically
if iscell(errBar) 
    fun1=errBar{1};
    fun2=errBar{2};
    errBar=fun2(y);
    y=fun1(y);
else
    y=y(:).';
end

if isempty(x)
    x=1:length(y);
else
    x=x(:).';
end

%Process y using function handles if needed to make the error bar dynamically
if iscell(errBar) 
    fun1=errBar{1};
    fun2=errBar{2};
    errBar=fun2(y);
    y=fun1(y);
else
    y=y(:).';
end

if isempty(x)
    x=1:length(y);
else
    x=x(:).';
end

%Make upper and lower error bars if only one was specified
if length(errBar)==length(errBar(:))
    errBar=repmat(errBar(:)',2,1);
else
    s=size(errBar);
    f=find(s==2);
    if isempty(f), error('errBar has the wrong size'), end
    if f==2, errBar=errBar'; end
end

if length(x) ~= length(errBar)
    error('length(x) must equal length(errBar)')
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot to get the parameters of the line
if strcmp(lineProps,'-lightGrey') == 1
    H.mainLine = plot(x,y,'Color',[0.8,0.8,0.8]);
elseif strcmp(lineProps,'-darkGrey') == 1
    H.mainLine = plot(x,y,'Color',[0.5,0.5,0.5]);
elseif strcmp(lineProps,'-brightCyan') == 1
    H.mainLine = plot(x,y,'Color',[0.5,0.8,0.8]);
elseif strcmp(lineProps,'-brightPurple') == 1
    H.mainLine = plot(x,y,'Color',[0.8,0.5,0.8]);
elseif strcmp(lineProps,'-brightGreen') == 1
    H.mainLine = plot(x,y,'Color',[0.2,0.8,0.5]);
elseif strcmp(lineProps,'-brightOrange') == 1
    H.mainLine = plot(x,y,'Color',[0.9,0.4,0]);
elseif strcmp(lineProps,'-darkRed') == 1
    H.mainLine = plot(x,y,'Color',[0.64,0.08,0.18]);
elseif strcmp(lineProps,'-red') == 1
    H.mainLine = plot(x,y,'Color',[1,0,0]);
elseif strcmp(lineProps,'-gold') == 1
    H.mainLine = plot(x,y,'Color',[0.93,0.69,0.13]);
elseif strcmp(lineProps,'-brightYellow') == 1
    H.mainLine = plot(x,y,'Color',[1,1,0]);
elseif strcmp(lineProps,'-blue') == 1
    H.mainLine = plot(x,y,'Color',[0,0,1]);
else
    %H.mainLine=plot(x,y,lineProps);
    H.mainLine=plot(x,y,'Color',lineProps);
end

% Work out the color of the shaded region and associated lines.
% Here we have the option of choosing alpha or a de-saturated
% solid colour for the patch surface.

col=get(H.mainLine,'color');
H.mainLine.LineWidth = 1;
edgeColor=col+(1-col)*0.55;
patchSaturation=0.15; % How de-saturated or transparent to make patch
if transparent
    faceAlpha=patchSaturation;
    patchColor=col;
else
    faceAlpha=1;
    patchColor=col+(1-col)*(1-patchSaturation);
end


%Calculate the error bars
%uE=y+errBar(1,:);
%lE=y-errBar(2,:);
uE=errBar(1,:);
lE=errBar(2,:);

%Add the patch error bar
holdStatus=ishold;
if ~holdStatus, hold on,  end


%Make the patch
yP=[lE,fliplr(uE)];
xP=[x,fliplr(x)];

%remove nans otherwise patch won't work
xP(isnan(yP))=[];
yP(isnan(yP))=[];


H.patch=patch(xP,yP,1,'facecolor',patchColor, ...
              'edgecolor','none', ...
              'facealpha',faceAlpha);


%Make pretty edges around the patch. 
H.edge(1)=plot(x,lE,'-','color',edgeColor);
H.edge(2)=plot(x,uE,'-','color',edgeColor);


%Now replace the line (this avoids having to bugger about with z coordinates)
uistack(H.mainLine,'top')


if ~holdStatus, hold off, end

if nargout==1
    varargout{1}=H;
end
