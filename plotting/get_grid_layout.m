function [fig,h] = get_grid_layout( varargin )
% 用于创建适合放置于网格布局中的一组轴
%
% h = get_layout( widths, heights, ... )
% 
% 该函数接受一系列输入参数，其中包括轴的宽度和高度，以及一些可选的参数，例如图表类型、边框尺寸和轴类型等。
% 函数的输出包括一个图形句柄和一个轴句柄数组，用于进一步定制和操作图形和轴。
%

    def_x_type = 'time';
    def_y_type = 'id';
    
    first_opt_arg = -1;
    
    if (nargin<1)
        error('not enought input arguments!');
    end
    
    if (nargin>=2) && isnumeric(varargin{2})
        widths = varargin{1};
        heights = varargin{2};
        first_opt_arg = 3;
    elseif (nargin==1) || ( (nargin>1) && ischar(varargin{2}) )
        widths = varargin{1};
        heights = varargin{1};
        first_opt_arg = 2;
    end
    
    if (nargin>=first_opt_arg)
        
        if ~ischar(varargin{first_opt_arg})
            error('expected string for argument %i!',first_opt_arg);
        end
        
        plot_type = varargin{first_opt_arg};
        first_opt_arg = first_opt_arg + 1;
        
        switch plot_type
            case {'bar','barv'}
                def_x_type = 'bar';
                def_y_type = '%';
            case 'barh'
                def_x_type = '%';
                def_y_type = 'bar';
            case 'plot'
                def_x_type = 't';
                def_y_type = 'id';
            case 'img'
                def_x_type = 'img';
                def_y_type = 'img';
            case 'id'
                def_x_type = 'id';
                def_y_type = 'id';
            case 'big'
                def_x_type = 'big';
                def_y_type = 'big';
            otherwise
                first_opt_arg = first_opt_arg - 1;
        end
    end
    
    if (nargin>=first_opt_arg)
        opt_args = { varargin{first_opt_arg:end} };
    else
        opt_args = {};
    end
    
    [ fig, ...
      left_border, ...
      right_border, ...
      top_border, ...
      bottom_border, ...
      plot_x_border, ...
      plot_y_border, ...
      border_all, ...
      x_type, ...
      y_type, ...
      dx, ...
      dy ] = ...
        snn_process_options( opt_args, ...
                             'figure', [], ...
                             'left_border', 32, ...
                             'right_border', 8, ...
                             'top_border', 24, ...
                             'bottom_border', 32, ...
                             'plot_x_border', 6, ...
                             'plot_y_border', 6, ...
                             'border', -1, ...
                             'x', def_x_type, ...
                             'y', def_y_type, ...
                             'dx', nan, ...
                             'dy', nan );

    if border_all>=0
        left_border = border_all;
        right_border = border_all;
        top_border = border_all;
        bottom_border = border_all;
    end

    if isnan(dx)
        dx = get_scale_val(x_type,1);
    end

    if isnan(dy)
        dy = get_scale_val(y_type,2);
    end
    
    if isempty(fig)
        fig = figure;
    end
    
    set( fig, 'Units', 'points' );
    
    if numel(plot_x_border) == 1
        plot_x_border = repmat(plot_x_border,1,(length(widths)-1));
    end

    if numel(plot_y_border) == 1
        plot_y_border = repmat(plot_y_border,1,(length(heights)-1));
    end
    
    plot_x_border = [plot_x_border(:);0];
    plot_y_border = [plot_y_border(:);0];
    
    plot_width = sum( widths )*dx + left_border + right_border + sum(plot_x_border);
    plot_height = sum( heights )*dy + top_border + bottom_border + sum(plot_y_border);
    
    pos = get( fig, 'Position' );    
    pos(3) = plot_width; pos(4) = plot_height;
    set( fig, 'Position', pos, 'Renderer', 'painters', 'Resize', 'off' );

    axis_grid = zeros( length(widths)*length(heights), 4 );
    
    i = 1;
    
    py = top_border;
    
    for j=1:length(heights)
        
        px = left_border;
        height = heights(j)*dy;
        
        for k=1:length(widths)
            
            width = widths(k)*dx;
            
            axis_grid(i,:) = [ px/plot_width, (plot_height-py-height)/plot_height, ...
                               width/plot_width, height/plot_height ];
            
            i = i+1;            
            px = px + width + plot_x_border(k);
        end
        
        py = py + height + plot_y_border(j);
    end

    [fig,h] = snn_plot( [], 'init', 'figure', fig, 'axis_grid', axis_grid );

    
    function sv = get_scale_val(scale_type,dim)
        switch scale_type
            case {'t','time'}
                sv = 200;
            case 'id'
                sv = 2;
            case '%'
                sv = 100;
            case 'bar'
                sv = 20;
            case 'img'
                sv = 5;
            case 'big'
                sv = 25;
            otherwise
                sv = 1;
        end
    end
end
