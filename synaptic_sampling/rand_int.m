function result = rand_int(n,m,min_v,max_v)
% 生成介于最小值和最大值之间的随机整数
    result = floor( rand(n,m)*(max_v-min_v+1)+min_v );
end
