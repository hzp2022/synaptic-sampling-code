function idx = sort_neurons_ct( data, field_name )
% 为给定的数据data中的神经元生成排序索引，排序依据是神经元的坐标轴中的最大值。
% 
% 输入：
%   data：数据 data 
%   field_name：数据中用于排序的字段名称field_name
% 
% 输出：
%   idx：神经元的排序索引idx
% 

    P = [];
    
    % 遍历data结构体数组中的每个元素，将它们的Pt字段的前end-1行转置后拼接到P矩阵中
    for i=1:length(data)
        P = [ P, data(i).Pt(1:end-1,:) ];
    end

    [v,a] = max(P,[],2);  % 通过max函数找到P中每行的最大值和其对应的坐标，即每个神经元在P中的位置
    [v,idx] = sort(a);    % 通过sort函数按照坐标位置的大小将神经元排序，并将排序后的索引存储在变量idx中
end
