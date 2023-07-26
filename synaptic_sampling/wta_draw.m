function Z = wta_draw( P )
%
% Z = wta_draw( P )
%
% 从分布P中绘制一个随机样本向量Z。假定P在列上已归一化，因此对于每列，绘制一个样本。输出具有与P相同的维数。
%

    P_size = size(P);  % 返回一个行向量，其元素是P的相应维度的长度
    P_size(1) = 1;     % 将行向量P_size的第一个元素(行的长度)设为1

    Z = cumsum( cumsum(P,1) >= repmat(rand(P_size),[size(P,1),ones(1,ndims(P)-1)]) ) == 1;  %得到随机样本向量Z 
end
