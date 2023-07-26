function spike_train = poisson_encoding(image, max_rate)
% 该函数将MNIST图像编码为泊松分布的脉冲序列，其发射率与像素的强度成比例。
% 
% Inputs:
%   - image: 表示MNIST图像的28x28矩阵
%   - max_rate: 输入神经元的最大发射率（默认值：63.75 Hz）
% 
% Output:
%   - spike_train: 表示脉冲序列的二进制矢量

    if nargin < 2
        max_rate = 63.75; % 默认的最大发射率
    end
    
    intensity = double(image(:))/4; % 将像素值转换为double并缩放像素强度
    firing_rate = intensity*max_rate/255; % 计算每个像素的发射率
    spike_train = rand(size(firing_rate)) < firing_rate/1000; % 基于泊松过程生成脉冲序列
    
    while sum(spike_train) < 5 % 如果生成的脉冲序列的脉冲数量少于5个，则增加最大发射率
        max_rate = max_rate + 32;
        firing_rate = intensity*max_rate/255;
        spike_train = rand(size(firing_rate)) < firing_rate/1000;
    end

end