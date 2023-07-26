function [P,A] = wta_softmax( U )
% 
% [P,A] = wta_softmax( U )
%
% 计算在第一维度上归一化的softmax函数。
% 安全的softmax功能，避免了有限浮点精度带来的问题。
%


   U_max =  max(U,[],1);      % 返回包含U每一列的最大值的行向量（本实验只有一列，故此处为一个数值）
   U_exp = exp( U - U_max );  % 返回指数 e^(U-U_max)
   A_n = sum(U_exp,1);        % 返回包含U_exp每一列总和的行向量（本实验只有一列，故此处直接对整列求和）
   P = U_exp./A_n;            % 得到P的公式   
   A = log( A_n ) + U_max;    % 得到A的公式
end
