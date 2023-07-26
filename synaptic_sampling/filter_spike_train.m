function [result,num_spikes] = filter_spike_train(St, idx, samples, filter_type, varargin)
% 用指定的过滤器filter_type过滤给定的脉冲序列St。
%
% usage:
% result = filter_spike_train(St, idx, samples, 'gauss', sigma)
% result = filter_spike_train(St, idx, samples, 'dblexp', tau_r, tau_f)
%
%

    % 根据filter_type选择正确的内联函数（小型的、只用一次的函数，这里用inline生成关于时间t和可变参数varargin的函数）
    switch filter_type
        case 'gauss'
            assert(nargin==5,'not enought input arguments');
            fil = inline('exp( -(t.^2)./(2*args{1}^2) )', 't', 'args');
        case 'dblexp'
            assert(nargin==6,'not enought input arguments');
            fil = inline('exp(-max(0,t)/args{2}) - exp(-max(0,t)/args{1})', 't', 'args');
        case 'alpha'
            assert(nargin==6,'not enought input arguments');
            fil = inline('max(0,t).*(exp(-max(0,t)/args{2}) - exp(-max(0,t)/args{1}))', 't', 'args');
        otherwise
            error('unknown filter type!');
    end

    % 初始化result（每行代表符合索引条件的脉冲的滤波器输出）
    result = zeros( length(idx), length(samples) );
    % 初始化num_spikes（每个元素代表相应行中符合条件的脉冲数目）
    num_spikes = zeros( length(idx), 1 );
    
    for i = 1:size( St, 2 )
        j = find(St(1,i)==idx);  % 找到满足St矩阵第一行元素等于idx向量对应元素的索引j
        if isempty(j)
            continue;
        end
        % 计算与该脉冲相关的滤波器输出值并将其累加到result(j,:)中
        result(j,:) = result(j,:) + fil( samples - St(2,i), varargin );  
        num_spikes(j) = num_spikes(j) + 1;
    end
end
