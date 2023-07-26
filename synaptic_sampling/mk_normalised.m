function [M, z] = normalise(A, dim)
% NORMALISE使(多维)数组的entries之和为1
% [M, c] = normalise(A)
% c是归一化常数
%
% [M, c] = normalise(A, dim)
% 如果指定了维度dim，则只归一化指定的维度，否则归一化整个数组A

if nargin < 2
  z = sum(A(:));
  % 在除法之前将所有零设置为1
  % 这是有效的，因为c=0 => 如果对于所有的i，A(i)=0 =>答案应该是0/1=0
  s = z + (z==0);
  M = A / s;
elseif dim==1 
  z = sum(A);
  s = z + (z==0);
  %M = A ./ (d'*ones(1,size(A,1)))';
  M = A ./ repmatC(s, size(A,1), 1);
else
  % Keith Battocchi——非常慢，因为使用了 repmat 函数
  z=sum(A,dim);
  s = z + (z==0);
  L=size(A,dim);
  d=length(size(A));
  v=ones(d,1);
  v(dim)=L;
  %c=repmat(s,v);
  c=repmat(s,v');
  M=A./c;
end


