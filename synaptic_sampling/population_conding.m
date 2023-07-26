function pcode = population_conding( Y, num_bins, min_max_range )
%
% Generate population coding of Y.
% 生成Y的群编码（将输入矩阵Y转化为稀疏矩阵pcode）
% 使用 num_bins 参数指定每个维度的离散级别数量，将 Y 中的每个元素通过 min_max_range 参数的归一化操作
% 将其范围映射到 [0,1] 之间，然后按照 num_bins 的离散级别数对映射后的值进行离散化，得到 Y_i。最后，将
% Y_i 中的每个值转化为一个稀疏矩阵的元素，其中行表示 Y_i 的值，列表示输入的维度，元素为 1 表示输入矩阵
% Y 中对应位置的元素属于该行表示的值所代表的区间。
    
    % 若没有提供min_max_range参数，则获取Y的最大最小值并作为默认值
    if nargin<3
        min_max_range = minmax(Y);
    end
    
    [N,M] = size(Y);  % 获取数据集的大小N和M
    
    % 处理num_bins的格式（一个1xN的向量，其中第i个元素表示第i个特征被划分成的bin的数量）
    if size(num_bins,2)==1
        num_bins = repmat(num_bins,1,N);
    end
    
    % 处理min_max_range的格式（一个Nx1的矩阵，其中第i行表示第i个特征的范围，第一列是最小值，第二列是最大值）
    if size(min_max_range,1)==1
        min_max_range = repmat(min_max_range,N,1);
    end
    
    num_bins = num_bins';  % 将num_bins转置为Nx1的列向量
    
    pcode = sparse( sum(num_bins), M );  % 创建一个行数为所有bin的数目之和、列数为M的全零稀疏矩阵pcode

    for i=1:N
        
        % 将 Y 中的每个元素通过min_max_range参数的归一化操作将其范围映射到[0,1]之间
        Y_i = (Y(i,:)-min_max_range(i,1))/(min_max_range(i,2)-min_max_range(i,1));
        
        % 按照num_bins的离散级别数对映射后的值进行离散化，得到Y_i
        Y_i = max( Y_i, zeros(1,M) );
        Y_i = min( Y_i, ones(1,M) );
        Y_i = floor(Y_i*(num_bins(i)-1))+1;
        
        % 将Y_i中的每个值转化为一个稀疏矩阵的元素，其中行表示Y_i的值，列表示输入的维度，元素为1表示输入矩阵Y中对应位置的元素属于该行表示的值所代表的区间
        pcode(sum(num_bins(1:i-1))+1:sum(num_bins(1:i)),:) = ...
            sparse( Y_i, 1:M, ones( M, 1 ), num_bins(i), M );
    end
end
