function handles = plot_arrow( x1,y1,x2,y2,varargin )
%
% plot_arrow——绘制指向当前绘图的箭头
%
% format:   handles = plot_arrow( x1,y1,x2,y2 [,options...] )
%
% input:    x1,y1   - 起始点
%           x2,y2   - 终止点
%           options - "property"和"value"成对出现，就像在“line”和“patch”控件中定义的那样，请参阅Matlab帮助以获取这些属性的列表。
%                     请注意，并非所有属性都被添加，可以在此文件末尾添加它们。
%                        
%                     其他选项包括: 
%                     'headwidth':  相对于完整箭头大小，默认值为0.07
%                     'headheight': 相对于完整箭头大小，默认值为0.15 
%                     (对于箭头很长的情况，编码的是像素的最大值)
%
% output:   handles - 构建arrow的图形元素的句柄
%
% Example:  plot_arrow( -1,-1,15,12,'linewidth',2,'color',[0.5 0.5 0.5],'facecolor',[0.5 0.5 0.5] );
%           plot_arrow( 0,0,5,4,'linewidth',2,'headwidth',0.25,'headheight',0.33 );
%           plot_arrow;   % 将启动demo

% =============================================
% 用于调试——demo——可以擦除
% =============================================
if (nargin==0)
    figure;
    axis;
    set( gca,'nextplot','add' );
    for x = 0:0.3:2*pi
        color = [rand rand rand];
        h = plot_arrow( 1,1,50*rand*cos(x),50*rand*sin(x),...
            'color',color,'facecolor',color,'edgecolor',color );
        set( h,'linewidth',2 );
    end
    hold off;
    return
end
% =============================================
% 调试结束
% =============================================


% =============================================
% 常数（可编辑）
% =============================================
alpha       = 0.15;   % head length
beta        = 0.07;   % head width
max_length  = 22;
max_width   = 10;

% =============================================
% 检查是否给出了head属性
% =============================================
% 如果比率总是固定的，这部分可以删除！
if ~isempty( varargin )
    for c = 1:floor(length(varargin)/2)
        try
            switch lower(varargin{c*2-1})
                % head属性——什么都不做，因为上面已经处理了
            case 'headheight',alpha = max( min( varargin{c*2},1 ),0.01 );
            case 'headwidth', beta = max( min( varargin{c*2},1 ),0.01 );
            end
        catch
            fprintf( 'unrecognized property or value for: %s\n',varargin{c*2-1} );
        end
    end
end

% =============================================
% 计算arrow head坐标
% =============================================
den         = x2 - x1 + eps;                                % 确保不会出现除零
teta        = atan( (y2-y1)/den ) + pi*(x2<x1) - pi/2;      % 箭头角度
cs          = cos(teta);                                    % 旋转矩阵
ss          = sin(teta);
R           = [cs -ss;ss cs];
line_length = sqrt( (y2-y1)^2 + (x2-x1)^2 );                % 尺寸
head_length = min( line_length*alpha,max_length );
head_width  = min( line_length*beta,max_length );
x0          = x2*cs + y2*ss;                                % 建立head坐标
y0          = -x2*ss + y2*cs;
coords      = R*[x0 x0+head_width/2 x0-head_width/2; y0 y0-head_length y0-head_length];

% =============================================
% 绘图箭头 (=line + 三角形的patch)
% =============================================
h1          = plot( [x1,x2],[y1,y2],'k' );
h2          = patch( coords(1,:),coords(2,:),[0 0 0] );
    
% =============================================
% 返回句柄
% =============================================
handles = [h1 h2];

% =============================================
% 检查是否需要设置样式
% =============================================
% 如果没有样式，则可以删除此部分！
if ~isempty( varargin )
    for c = 1:floor(length(varargin)/2)
        try
            switch lower(varargin{c*2-1})

             % 只有patch属性
            case 'edgecolor',   set( h2,'EdgeColor',varargin{c*2} );
            case 'facecolor',   set( h2,'FaceColor',varargin{c*2} );
            case 'facelighting',set( h2,'FaceLighting',varargin{c*2} );
            case 'edgelighting',set( h2,'EdgeLighting',varargin{c*2} );
                
            % 只有line属性   
            case 'color'    , set( h1,'Color',varargin{c*2} );
               
            % 共享属性   
            case 'linestyle', set( handles,'LineStyle',varargin{c*2} );
            case 'linewidth', set( handles,'LineWidth',varargin{c*2} );
            case 'parent',    set( handles,'parent',varargin{c*2} );
                
            % head属性——什么都不做，因为上面已经处理过了
            case 'headwidth',;
            case 'headheight',;
                
            end
        catch
            fprintf( 'unrecognized property or value for: %s\n',varargin{c*2-1} );
        end
    end
end
