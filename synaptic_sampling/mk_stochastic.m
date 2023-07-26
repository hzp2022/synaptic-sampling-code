function [T,Z] = mk_stochastic(T)
% MK_STOCHASTIC 确保输入的矩阵T是随机矩阵，即最后一维的和是1
% [T,Z] = mk_stochastic(T)
%
% 如果输入的是一个向量，则通过调用 mk_normalised 函数来将向量归一化为概率分布
% 如果输入的是一个二维矩阵，则对每一行进行归一化操作，使其和为 1
% 如果输入的是一个三维或以上的多维数组，则首先将其展开成二维矩阵，对每一行进行归一化操作，然后再将其还原成原来的维度

% 除法前将零设置为1。这是有效的，因为对于所有j，S(J)=0当且仅当T(i，j)=0

% 向量
if (ndims(T)==2) & (size(T,1)==1 | size(T,2)==1) 
  [T,Z] = mk_normalised(T);
% 矩阵
elseif ndims(T)==2 
  Z = sum(T,2); 
  S = Z + (Z==0);
  norm = repmat(S, 1, size(T,2));
  T = T ./ norm;
% 多维数组
else 
  ns = size(T);
  T = reshape(T, prod(ns(1:end-1)), ns(end));
  Z = sum(T,2);
  S = Z + (Z==0);
  norm = repmat(S, 1, ns(end));
  T = T ./ norm;
  T = reshape(T, ns);
end
