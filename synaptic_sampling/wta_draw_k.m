function [Z,k] = wta_draw_k( P )
%
% [Z,k] = wta_draw_k( P )
%
% 从分布P中绘制一个随机样本向量Z。
% 假设P在列方向上被标准化，因此为每列绘制一个样本。输出与P具有相同的维度。
% 

    k = find( cumsum(P,1) > rand(), 1 );  % 在(cumsum(P,1)>rand())中查找第一个非0元素的索引值
    
    if isempty(k)  
        k = size(P,1);
    end
    
    Z = sparse( k, 1, 1, size(P,1), 1 );  % 根据k、1和1三元组生成 size(P,1)×1 的稀疏矩阵 Z
end
