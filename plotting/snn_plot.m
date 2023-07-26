function [fig,h] = snn_plot( data, plot_rule, varargin )
% SNN_PLOT将实验数据以数据形式绘制成图。
%
% [fig,h] = snn_plot_data( data, plot_rule, ... )
%
% 将data中的实验数据绘制到一个图中。要绘制的数据字段由plot_rule参数确定。
% plot_rule是一个格式为[<field1>[<m11><m12>...<m1M>], ...,<fieldN>[<mN1><mN2>...<mNM]]的字符串，包含应绘制的所有字段的列表。
% 字段名称field1...fieldN可以是数据结构的任何数据字段。修饰符m11...mNM是调整绘图行为的可选参数。
%
% input:
%   data:          由snn_simulate()创建的snn数据结构
%   plot_rule:     定义绘制规则的一个字符串
%
% modifiers:
%   'b':           显示颜色条
%   'c':           根据值（value）对脉冲序列进行着色
%   'g':           显示网格
%   'i':           将矩阵绘制为像素图像
%   'l':           绘制标签
%   'o':           绘制带有偏移的曲线
%   'p':           绘制曲线
%   '?':           不绘制任何东西
%   's':           绘制脉冲序列
%   't':           绘制标签边框
%   'x':           对神经元进行排序
%   'y':           给Y轴添加标签。
%   'z':           根据值的大小调整脉冲序列的大小
%   [1-9]:         将图形划分成n个子图，并在其中绘制数据
%
% optional arguments:
%   figure:           使用具有给定id的图，而不是创建一个新的图。
%   numbering:        使用给定的绘图编号模式。可能的值是'alpha'、'num'或'none'。默认为 "alpha"。
%   show_x_labels:    显示X-轴的标签，默认为true
%   show_y_labels:    显示Y-轴的标签，默认为true
%   show_titles:      显示绘图的标题，默认为true
%   start_time:       图中包含的起始时间索引
%   end_time:         图中包含的结束时间索引
%   reset_start_time: 如果为true，则重置起始时间为0,默认为false
%   sort_fct:         一个函数句柄，指向一个排序函数，其格式为：sort_idx = sort_fct(data,field_name)
%   num_cols:         子图中的列数
%
%
% example:
%   data = snn_simulate( net, 'my_exp/test*' );
%   snn_plot_data( net, data(1), '[ X[2s], Z[rs], P[jb], T ]' );
%

    if isempty( data )
        data = struct();
    end

    if (nargin<2)
        error('Not enought input arguments!');
    end

    if ~isstruct( data )
        error('Unexpected argument type for ''data''!');
    end

    if ~ischar( plot_rule )
        error('Unexpected argument type for ''plot_rule''!');
    end

    
    [ fig, ...
      h, ...
      numbering, ...
      show_x_labels, ...
      show_y_labels, ...
      show_titles, ...
      start_time, ...
      end_time, ...
      reset_start_time, ...
      sort_fct, ...
      v_size, ...      
      num_cols, ...
      axis_grid, ...
      spike_shape, ...
      spike_size, ...
      hold_it, ...
      colors ] = ...
        snn_process_options( varargin, ...
                             'figure', [], ...
                             'axis', [], ...
                             'numbering', 'alpha', ...
                             'show_x_labels', true, ...
                             'show_y_labels', true, ...
                             'show_titles', true, ...
                             'start_time', inf, ...
                             'end_time', inf, ...
                             'reset_start_time', false, ...
                             'sort_fct', [], ...
                             'v_size', 5, ...
                             'num_cols', 1, ...
                             'axis_grid', [], ...
                             'spike_shape', '|', ...
                             'spike_size', 1, ...
                             'hold', 'off', ...
                             'colors', [ 0.0, 0.0, 1.0; ...
                                         0.0, 0.7, 0.0; ...
                                         1.0, 0.0, 0.0; ...
                                         0.9, 0.9, 0.0; ...
                                         0.0, 0.7, 0.7; ...
                                         0.7, 0.0, 0.7; ...
                                         0.7, 0.7, 0.7; ...
                                         0.8, 0.2, 0.2; ... 
                                         0.2, 0.8, 0.2; ...
                                         0.0, 0.0, 0.0; ] );
                                     
    tokens = snn_parse_args(plot_rule);
    
    num_plots = zeros(length( tokens ),1);
    args = cell(1,numel(tokens));
    field_names = cell(1,numel(tokens));
    
    for tok=1:length(tokens)
        
        token = tokens{tok};
        [arg,a_pos] = snn_parse_args(token);
        if isempty(arg)
            args{tok} = [];
            num_plots(tok) = 1;
        else
            args{tok} = arg{1};
            num_plots(tok) = 1 + sum( cell2mat( regexp( arg{1}, '[1-9]', 'match' ) )-'1' );
        end
        field_names{tok} = token(1:a_pos-1);
        
        if ~isfield( data, field_names{tok} ) && ~strcmp( field_names{tok}, '_' )
            error( 'Data field ''%s'' not found!', field_names{tok} );
        end
    end

    sub_id=1;
    
    if strmatch( plot_rule, 'init' )
        if isempty(h)
            num_axes = size(axis_grid,1);
        else
            num_axes = numel(h);
        end
        num_plots = ones(1,num_axes);
        tokens = zeros(1,num_axes);        
        args = cell(1,num_axes);
        field_names = cell(1,num_axes);
    end

    if isempty(h)
        
        h = zeros( length(tokens), 1 );

        if isempty(fig)
            fig = figure;
        else
            figure(fig);
        end
    end
    
    for tok=1:length(tokens)
        
        arg = args{tok};
        field_name = field_names{tok};
        plot_size = num_plots(tok);
        
        if isempty( axis_grid ) && ~h(tok)
            h(tok) = subplot(ceil( sum(num_plots)/num_cols ), ...
                                   num_cols, ...
                                   (sub_id:sub_id+plot_size-1) );
        elseif h(tok)
            axes( h(tok) );
        else
            h(tok) = axes( 'position', axis_grid(tok,:) );
        end
        
        set( h(tok), 'LineWidth', 0.8, 'FontName', snn_options( 'FontName' ), ...
                     'FontSize', snn_options( 'FontSize' ) );
        
        sub_id = sub_id+plot_size;
        
        if ~isempty(field_name) && ( field_name(end) == 't' )
            is_spike_train = true;
        else
            is_spike_train = false;
        end
        
        xl = '';
        yl = '';
        tl = field_name;

        % prepare title numbering  准备标题编号
        switch numbering
            case 'alpha'
                title_prefix = [ char('a'+tok-1) ') ' ];
            case 'num'
                title_prefix = [ char('1'+tok-1) ') ' ];
            case 'none'
                title_prefix = '';
        end
        
        % prepare axis scales  准备轴的刻度
        if isfield( data, 'time' )
            time = 1000*data.time; %(1:end-1);
        elseif isfield( data, 'X' )
            time = 1:size(data.X,2);
        end
        
        if ~( isempty(field_name) || strcmp( field_name, '_' ) )
        
            if  is_spike_train

                x_range = 1000*data.(field_name)(end,:);

                if isfield( data, [field_name, '_y_range'] )
                    y_range = data.([field_name, '_y_range']);
                else
                    y_range = minmax( double( data.(field_name)(1,:) ) );
                end

                x_lim = [time(1), time(end)];
            else
                if isfield( data, [field_name, '_y_range'] )
                    y_range = data.([field_name, '_y_range']);
                else
                    y_range = 1:size(data.(field_name),1);
                end

                if isfield( data, [field_name, '_x_range'] )
                    x_range = data.([field_name, '_x_range']);
                else
                    time_factor = (size(data.(field_name),2)/size(data.time,2));
                    xl = 'time [ms]';

                    if size(data.(field_name),2) == (size(data.time,2)-1)
                       x_range = time(1:end-1);              
                    else
                       x_range = ( 1:size(data.(field_name),2) )/time_factor;
                    end
                end

                x_lim = [x_range(1), x_range(end)];
            end

            % cut data filed time range  削减数据存档的时间范围
            start_t = start_time;
            end_t = end_time;

            start_p = find( x_range >= start_time, 1, 'first' );
            end_p = find( x_range >= end_time, 1, 'first' );

            if isempty(start_p)
                start_p = 1;
                start_t = x_range(1);
            end

            if isempty(end_p)
                end_p = size(x_range,2);
                end_t = x_range(end);
            end

            if (start_p > end_p)
                error( 'Start time must be smaller than end time!' );
            end

            x_range = x_range(start_p:end_p);

            if  is_spike_train
                data_field = data.(field_name)(1:(end-1),start_p:end_p);
            else
                data_field = data.(field_name)(:,start_p:end_p);
            end

            x_offset = 0;

            % reset start time to 0  将开始时间重置为0
            if reset_start_time

                x_offset = x_range(1);
                start_t = start_time - x_offset;
                end_t = end_time - x_offset;
                x_range = x_range - x_offset;
            end

            % prepare plot title  准备绘图标题
            if ~isempty( strfind( field_name, 'X' ) )
                tl = 'network input (raw spikes)';
            end
            if ~isempty( strfind( field_name, 'Z' ) )
                tl = 'network output';
            end
            if ~isempty( strfind( field_name, 'P' ) )
                tl = 'output probability';
            end
            if ~isempty( strfind( field_name, 'T' ) )
                tl = 'target output';
            end
            if ~isempty( strfind( field_name, 'L' ) )
                tl = 'network input';
            end

            % process plot modifiers  流程图修改器
            plot_mode = 'i';

            if ~isempty( strfind( arg, 'i' ) )
                plot_mode = 'i';
            end
            if ~isempty( strfind( arg, 's' ) )
                plot_mode = 's';
            end
            if ~isempty( strfind( arg, 'p' ) )
                plot_mode = 'p';
            end
            if ~isempty( strfind( arg, 'o' ) )
                plot_mode = 'o';
            end
            if ~isempty( strfind( arg, '?' ) )
                plot_mode = '?';
            end

            if ~isempty( strfind( arg, 'x' ) )

                if  is_spike_train

                    if isfield( data, 'idx' )
                        idx = data.idx;
                    else
                        if ~isempty(sort_fct)
                            idx = sort_fct(data,field_name);
                        else
                            idx = 1:length(data_field);
                            warning( 'No sorting function provided!' );
                        end
                    end

                    tmp_spikes = data_field(:,data_field(1,:)>0);

                    tmp_data = sparse( double( tmp_spikes(1,:) ), 1:length(tmp_spikes), 1, ...
                                       double( max(idx) ), ...
                                       length(tmp_spikes) );

                    [data_field_tmp,J,V] = find( tmp_data(idx,:) );

                    if ( size( data_field, 1 ) == 1 )
                        data_field = data_field_tmp';
                    else
                        data_field = [ data_field_tmp'; data_field(2:end,:) ];
                    end
                else
                    if isfield( data, 'idx' )
                        data_field = data_field(data.idx,:);
                    else
                        if ~isempty(sort_fct)
                            idx = sort_fct(data,field_name);
                            data_field = data_field(idx,:);
                        end
                    end
                end
            end


            % plot data field  绘制数据字段
            switch plot_mode
                case 's'
                    if  is_spike_train
                        I = data_field(1,:);
                        J = x_range;

                        if ( size( data_field, 1 ) == 2 )
                            C = data_field(2,:);
                        else
                            C = ones( size(I) );
                        end
                    else
                        [I,J,C] = find( data_field );
                        J = x_range(J);
                    end

                    %scatter( J, I , v_size, colors(C,:), 'filled' );
                    %scatter( J, I , v_size, C, 'filled' );

                    color_spike_trains = ~isempty( strfind( arg, 'c' ) );

                    col = colors(1,:);

                    hold(hold_it);

                    for cluster = unique( C )

                        c_I = I( C == cluster );
                        c_J = J( C == cluster );

                        if color_spike_trains
                            if ( cluster == -1 )
                                col = 'k';
                            else
                                col = colors(mod(cluster-1,size(colors,1))+1,:);
                            end
                        end

                        if ( spike_shape == '|' )
                            plot( reshape( [ c_J; c_J; nan(1,size(c_J,2)) ], 1, [] ), ...
                                  reshape( [ c_I-0.5; c_I+0.5; nan(1,size(c_I,2)) ], 1, [] ), ...
                                  'Color', col, 'LineWidth', spike_size );
                        else
                            plot( c_J, c_I, 'o', ...
                                  'MarkerEdgeColor', col, ...
                                  'MarkerFaceColor', col, ...
                                  'MarkerSize', spike_size );
                        end

                        hold on;
                    end

                    min_x_dist = 0.01;
                    min_y_dist = 0.02;

                    x_dist = 0.5;

                    x_diff = x_lim(end) - x_lim(1);

                    if x_dist/x_diff < min_x_dist
                        x_dist = min_x_dist*x_diff;
                    end

                    y_dist = 0.5;

                    if y_dist/y_range(end) < min_y_dist
                        y_dist = min_y_dist*y_range(end);
                    end

                    set(gca,'YDir','reverse');
                    set(gca,'Box','on');
                    set(gca,'Layer','top');
                    axis([x_lim(1)-x_dist, x_lim(end)+x_dist, y_range(1)-y_dist, y_range(end)+y_dist]);

                case 'i'
                    imagesc( x_range, y_range, 1-data_field );
                    set(gca, 'XLim', [x_lim(1), x_lim(end)]);

                    colormap gray;

                case 'p'
                    plot( x_range, data_field );
                    set(gca, 'XLim', [x_lim(1), x_lim(end)]);

                case 'o'
                    plot( x_range, 0.3*data_field + ...
                          repmat(y_range',1,size(data_field,2)), '-b' );
                    axis([x_lim(1), x_lim(end), y_range(1), y_range(end)]);
            end
        else
            tl = '';
            start_t = start_time;
            end_t = end_time;
            x_offset = 0;
        end
        
        if ~isempty( snn_options( 'FontName' ) )
            set( h(tok), 'FontName', snn_options( 'FontName' ) );
        end

        if ~isempty( snn_options( 'FontSize' ) )
            set( h(tok), 'FontSize', snn_options( 'FontSize' ) );
        end

        % show labels and title  展示标签和标题
        if show_x_labels
            xlabel(xl)
        end;

        if show_y_labels
            ylabel(yl)
        end;

        if show_titles && ~isempty(tl)
            title([title_prefix, tl]);
        end
        
        % process modifiers  流程修改器
        if ~isempty( strfind( arg, 'b' ) )
            colorbar;
        end
       
        if ~isempty( strfind( arg, 'g' ) )
            grid on;
        end
                
        % plot labels  绘制标签
        show_label_background = ~isempty( strfind( arg, 't' ) );
        show_label_caption = ~isempty( strfind( arg, 'l' ) );
                
        if ( show_label_background || show_label_caption ) && ...
           ( isfield( data, 'labels' ) || isfield( data, [field_name, '_labels'] ) )
            
            range = get(gca,'YLim');
            
            if isfield( data, [field_name, '_labels'] )
                all_labels = data.( [field_name, '_labels'] );
            else
                all_labels = data.labels;
            end
            
            if strcmp( get(gca,'YDir'), 'reverse' )
                y_t_pos = range(1);
            else
                y_t_pos = range(1) + range(end);
            end
            
            for l=1:length(all_labels)
                
                label = all_labels(l);

                if isfield( label, 'start_time' )
                    t_l = label.start_time*1000;
                else
                    t_l = time(label.start_sample) - x_offset;
                end
                
                if isfield( label, 'stop_time' )
                    t_s = label.stop_time*1000;
                else
                    t_s = time(label.stop_sample) - x_offset;
                end
                
                if isempty( t_l )
                    continue;
                end
                
                if isfield( label, 'range' )
                    l_range = label.range;
                else
                    l_range = range;
                end
                
                if isfield( label, 'color' ) && ~isempty( label.color ) && show_label_background
                    
                    vert = [t_l, l_range(1),   -1; ...
                            t_s, l_range(1),   -1; ...
                            t_s, l_range(end), -1; ...
                            t_l, l_range(end), -1 ];
                        
                    fac = [1,2,3; 1,3,4];
                    
                    tcolor = label.color;
                    
                    patch( 'Faces', fac, 'Vertices', vert, 'FaceVertexCData', tcolor, ...
                           'FaceColor', 'flat', 'EdgeColor', 'none' );
                end
                
                % plot label borders  绘制标签边框
                show_border = true;
                
                if isfield( label, 'show_border' )
                    show_border = label.show_border;
                end
                
                if isempty( show_border )
                    show_border = true;
                end
                
                border_col = [.6,.6,.6];

                if (t_l >= start_t) && (t_l <= end_t) && show_border && show_label_background
                    line( [t_l,t_l], [range(1),range(end)], 'Color', border_col, 'LineStyle', '-', 'LineWidth', 0.8 );
                end
                
                if (t_s >= start_t) && (t_s <= end_t) && show_border && show_label_background
                    line( [t_s,t_s], [range(1),range(end)], 'Color', border_col, 'LineStyle', '-', 'LineWidth', 0.8 );
                end
                
                % plot label text  绘制标签文本
                t_t = ( t_l + t_s )/2 - x_offset;
                
                descriptor = [];
                
                if isfield( label, 'descriptor' )
                    descriptor = label.descriptor;
                end
                
                if (t_t >= start_t) && (t_t <= end_t) && ~isempty(descriptor) && show_label_caption
                    h_t = text( double(t_t), y_t_pos, descriptor, ...
                          'HorizontalAlignment', 'center', ...
                          'FontName', snn_options( 'FontName' ), ...
                          'FontSize', snn_options( 'FontSize' ) );
                      
                    set( h_t, 'Units', 'points' );
                    pos = get( h_t, 'Position' );
                    pos(2) = pos(2) + 6;
                    set( h_t, 'Position', pos );
                end

            end
        end
        
        set( h(tok), 'LineWidth', 0.8 );
        
        drawnow;
    end
end
