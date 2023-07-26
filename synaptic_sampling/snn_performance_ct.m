function [net, performance] = snn_performance_ct( net, data, ct )
% 归一化条件熵性能度量。
%
% [net, performance] = wta_performance_ce( net, data )
%
% 计算归一化条件熵的SNN性能方法。
%
% net:
%   A wta-network, see wta_new().
%
% data:
%   测试数据结构(测试数据集)
%

    % 计算测试数据的输出概率矩阵testTprob（每一列都代表一个输出脉冲时间下各输出神经元的发射概率）
    testTprob = double( min( 1, data.Pt(1:(end-1),:) ) );  
    
    % 如果测试数据中包含正确标签'T'，则将其转换为稀疏矩阵T，并且将其列向量化为targets
    if isfield(data, 'T')
        T = sparse( double( data.T ), 1:length(double( data.T )), 1 );
        targets = T(:,ceil(data.Pt(end,:)));  % 将矩阵T的每一列向量化为一个列向量，然后将这些列向量连接起来形成一个新的列向量targets。这样做是为了将T矩阵中的每个元素都作为一个类别进行处理
    else
        error('FIXME: Not implemented yet!!!');
    end
    
    % 计算条件概率分布probLT（表示当前输入脉冲情况下的输出神经元的发放概率（类别），即[p(Y=neuron1|X=x)，p(Y=neuron2|X=x)，p(Y=neuron3|X=x)]）
    probY = sum(targets,1);  % 计算targets矩阵的列和，表示每个类别在测试数据中出现的概率
    probLT = sparse(targets)*diag(probY)*testTprob';  % 使用稀疏矩阵乘法计算出条件概率分布probLT，它的大小为'类别数 × 测试数据的数量'
    probLT = probLT/sum(sum(probLT));  % 对probLT进行归一化，使其所有元素的和为1
    
    % 根据probLT计算出条件熵HLT、无条件熵HT和先验熵HL
    HLT=sum(sum(probLT.*log(max(eps,probLT))));  % 计算条件熵HLT，它是probLT的元素与其自然对数的乘积之和，其中eps是一个很小的数，用于避免出现log(0)的情况
    HT=sum(sum(probLT,1).*log(max(eps,sum(probLT,1))));  % 计算无条件熵HT（在对测试数据进行分类时，网络对每个类别的输出概率分布的不确定性），它是probLT每列的和与其自然对数的乘积之和
    HL=sum(sum(probLT,2).*log(max(eps,sum(probLT,2))));  % 计算类先验熵HL（在知道测试数据所属的类别前，每个类别的输出概率分布的不确定性），它是probLT每行的和与其自然对数的乘积之和
    
    % 计算SNN的性能度量值performance=(条件熵-无条件熵)/先验熵
%     performance = (HLT-HT)/HL;
    performance = -HLT;
end
