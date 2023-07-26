function cur_performance = snn_performance_s(sim_test,net)
% 自己写的计算条件熵的函数。
% 

    % 计算当前模型性能（条件熵，仅能代表分类结果（测试数据被分类为某一类别）的不确定性）
    cur_performance = 0;  
    num_perf = 0;     
    for k = 1:length(sim_test)
        [net,perf_j] = net.p_performance_fcn( net, sim_test{k}, k );
        if isfinite(perf_j)
            cur_performance = cur_performance + perf_j;
            num_perf = num_perf+1;
        end
    end
    if (num_perf>0)
        cur_performance = cur_performance/num_perf;
    else
        cur_performance = nan;        
    end

end