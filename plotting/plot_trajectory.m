function data_set = plot_trajectory( data_set, varargin )
% 接受一个数据结构作为输入并绘制该数据结构的轨迹。如果输入是字符串，则函数将从该字符串所指向的文件中加载数据结构。
% 
% 输入：
%   data_set：  包含要绘制的数据的结构体或指向数据结构体的文件名字符串。
% 
% 可选输入（使用键值对的方式传递）：
%   axes：      绘图所使用的Axes对象。如果没有指定，则创建一个新的Figure对象并返回其Axes对象。
%   show_trace：一个布尔值，指示是否显示神经元的轨迹。默认值为false。
%   smoothing： 平滑程度。这是一个介于0和1之间的值，表示绘制轨迹时的平滑程度。默认值为0.25。
%   time_range：一个包含要绘制的时间范围的向量，格式为[start_time, end_time]。默认情况下，将绘制所有时间点的数据。
%   group_id：  要绘制的神经元组的ID。默认值为空，表示绘制所有神经元。
% 
% 输出： 
%   data_set：  更新后的数据结构体。
% 

    % 检查输入是否是字符串，如果是，则从指定的文件中加载数据结构
    if ischar( data_set )
        data_set = load( data_set );
    end
    
    % 解析可选输入参数
    [ h, ...
      show_trace, ...
      smoothing, ...
      time_range, ...
      group_id ] = snn_process_options( varargin, ...
                                        'axes', [], ...
                                        'show_trace', false, ...
                                        'smoothing', 0.25, ...
                                        'time_range', [], ...
                                        'group_id', [] );
    
    % 确定用于绘图的颜色
    colors = snn_options( 'colors' );

    % 计算要绘制的神经元组的索引
    g_idx = [0,cumsum( data_set.net.groups )];

    if isempty(h)
        figure;
    else
        axes(h);
    end
    
    % 在Axes对象中绘制每个神经元组的轨迹
    for i=1:size(data_set.psps_evoced,1)
        
        % 对于每个神经元组，首先从数据结构中提取与该组相关的I值（神经元ID）和pc值（表示神经元组的形状）
        if isempty(group_id)
            I_g = data_set.I;
            nneur = data_set.net.num_neurons;
        else
            I_g = data_set.I(and( data_set.I>g_idx(group_id), data_set.I<=g_idx(group_id+1) ));
            nneur = data_set.net.groups(group_id);
        end
        
        pc = [sin((0:(nneur-1))*(2*pi/(nneur-1)));cos((0:(nneur-1))*(2*pi/(nneur-1)))];
        
        % 然后，从数据结构中提取与该组相关的psp值，并通过pc值将其映射到二维空间中
        for j=1:25
            
            % 移除前几个样本。它们非常相似，因为初始条件是相同的，并且会篡改结果。
            
            if isempty(time_range)
                t_r = 1:size(data_set.psps_evoced{i,j},2);
            else
                t_r = time_range;
            end
            
            tmp_psp = data_set.psps_evoced{i,j};
            data_set.psps_evoced{i,j} = tmp_psp(:,t_r);            
        end
        
        % 最后，使用ashape函数将数据平滑化，并使用patch函数在Axes对象中绘制轨迹
        psp = [data_set.psps_evoced{i,1:25}];
        poj = pc*psp(I_g,:);
        p = ashape(poj(1,:),poj(2,:),smoothing,'-g');
        patch( p.x( p.apatch{1} ), p.y( p.apatch{1} ), colors(i,:) );        
        hold on;
        drawnow;
    end
    
    % 如果show_trace参数设置为true，则该函数将绘制神经元的轨迹。它使用相同的方法计算神经元的轨迹，并使用plot函数在Axes对象中绘制
    if show_trace
        
        if isempty(group_id)
            I_g = data_set.I;
            nneur = data_set.net.num_neurons;
        else
            I_g = data_set.I(and( data_set.I>g_idx(group_id), data_set.I<=g_idx(group_id+1) ));
            nneur = data_set.net.groups(group_id);
        end
        
        pc = [sin((0:(nneur-1))*(2*pi/(nneur-1)));cos((0:(nneur-1))*(2*pi/(nneur-1)))];
        psp = data_set.psps_evoced{1,1};
        poj = pc*psp(I_g,:);
        plot( poj(1,:),poj(2,:), '.', 'MarkerFaceColor', colors(i,:), 'MarkerSize', 1 );
        hold on;
    end
    
end
