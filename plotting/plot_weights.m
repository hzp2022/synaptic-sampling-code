function [all_W, all_V, all_V0, eta_W, eta_V, eta_0] = plot_weights( path, num_iter )
% 从指定路径加载模型训练的数据，绘制出 feedforward weights (W)、lateral weights (V) 和 
% bias weights (V0) 的变化曲线，并返回这些变量的值。
% 
% 输入：
%   path:     字符串，指定文件路径，其中存储了神经网络的参数数据。
%   num_iter: 整数，指定迭代次数。默认值为all_files数组的长度（即存储参数的文件数量），表示将读取所有文件。
% 
% 输出：
%   all_W： 大小为(num_neurons * num_inputs) x num_iter的矩阵，其中num_neurons表示神经元数量，num_inputs表示输入数量。该矩阵包含了所有迭代步骤中的前向权重矩阵W的数据。
%   all_V： 大小为(num_neurons * num_neurons) x num_iter的矩阵，包含了所有迭代步骤中的侧向权重矩阵V的数据。
%   all_V0：大小为num_neurons x num_iter的矩阵，包含了所有迭代步骤中的偏置向量V0的数据。
%   eta_W： 大小为(num_neurons * num_inputs) x num_iter的矩阵，包含了所有迭代步骤中的前向权重矩阵W的学习速率。
%   eta_V： 大小为(num_neurons * num_neurons) x num_iter的矩阵，包含了所有迭代步骤中的侧向权重矩阵V的学习速率。
%   eta_0： 大小为num_neurons x num_iter的矩阵，包含了所有迭代步骤中的偏置向量V0的学习速率。
% 

    all_files = dir( [ path, '*.mat'] );
    
    if isempty( all_files )
        all_W = []; all_V = []; all_V0 = [];
        return;
    end

    data = load( [ path, all_files(1).name ] );

    num_neurons = data.net.num_neurons;
    num_inputs = data.net.num_inputs;

    if ( nargin < 2 )
        num_iter = length( all_files );
    end

    all_W = zeros( num_neurons*num_inputs, num_iter );
    all_V = zeros( num_neurons*num_neurons, num_iter );
    all_V0 = zeros( num_neurons, num_iter );

    eta_W = zeros( num_neurons*num_inputs, num_iter );
    eta_V = zeros( num_neurons*num_neurons, num_iter );
    eta_0 = zeros( num_neurons, num_iter );
    
    fprintf( 'loading data sets...  0%%' );

    for i=1:num_iter;

        data = load( [ path, all_files(i).name ] );
        
        fprintf('%c%c%c%c%3d%%',8,8,8,8,round(100*i/num_iter))

        all_W(:,i) = data.net.W(:);
        all_V(:,i) = data.net.V(:);
        all_V0(:,i) = data.net.V0(:);

        eta_W(:,i) = data.net.eta_W(:);
        eta_V(:,i) = data.net.eta_V(:);
        eta_0(:,i) = data.net.eta_0(:);

    end
    
    figure; plot( all_W' ); title( 'feedforward weights (W)' );
    figure; plot( all_V' ); title( 'lateral weights (V)' );
    figure; plot( all_V0' ); title( 'bias weights (V0)' );

    fprintf('%c%c%c%cdone.\n',8,8,8,8);
    
end
