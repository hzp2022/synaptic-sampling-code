function performance = snn_performance( net, data )
% snn_performance: get performance measure for given net  获取给定网络的性能度量
%
% performance = snn_performance( net, data )
% 
% 获取给定网络的性能度量。使用网络性能方法计算性能。
%
% input
%   net:         由<a href="matlab:help snn_new">snn_new</a>创建的SNN网络
%   data:        指向数据文件的测试数据结构或字符串。
%
% output
%   performance: 对整个数据集计算的性能指标。
%
% see also
%   <a href="matlab:help snn_new">snn_new</a>
%   <a href="matlab:help snn_list_methods">snn_list_methods</a>
%

    % 检查输入参数是否正确，如果输入参数不正确，则抛出相应的错误信息
    if ( nargin < 2 )        
        error( 'Not enough input arguments!' );
    end
    
    if ~isstruct( net )
        error( 'Unexpected argument type for ''net''!' );
    end
    
    % 如果data是字符串类型，就调用snn_load_data函数来加载该字符串所指的数据文件，将加载得到的数据存储到data中
    if ischar( data )
        data = snn_load_data( data );
    end
    
    if ~isstruct( data )
        error( 'Unexpected argument type for ''data''!' );
    end
    
    performance = 0;  % performance存储整个数据集的性能指标，是所有测试样本的性能指标的加和
    num_perf = 0;     % num_perf存储可用于计算性能指标的测试样本数量
    
    % 遍历整个测试数据集，并对每个数据点（data(j)）调用snn_performance_ct得到该数据点上的性能度量perf_j和更新后的net
    for j=1:length(data)

        [net,perf_j] = net.p_performance_fcn( net, data(j), j );
        
        % 对于每个性能度量，如果其是有限值，则将其累加到总的性能度量performance中，并增加已经计算过的性能度量的数量num_perf
        if isfinite(perf_j)
            performance = performance + perf_j;
            num_perf = num_perf+1;
        end
    end

    % 如果计算出的性能度量数量（num_perf）大于0，则将累加后的总性能度量除以计算出的性能度量数量，得到整个数据集上的性能度量performance，否则将performance设置为NaN
    if (num_perf>0)
        performance = performance/num_perf;
    else
        performance = nan;        
    end
end
