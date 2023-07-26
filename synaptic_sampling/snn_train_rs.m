function net = snn_train_rs( net, data, ct )
% 脉冲EM学习——连续时间脉冲HMM SEMs——拒绝采样
%
% net = snn_train_ct( net, data, ct )
%
%
% @parameters:
%   eta                 0.005    learn rate  学习率
%   sample_method       'ct'     default sample method  默认采样方法
%   performance_method  'ct'     default performance method  默认performance方法
%   self_inhibition     0        fix value of self-recurrent weights  固定self-recurrent权重的值
%   use_iw              true     use importance weight  使用importance权重
%   resample            true     resample path if rejected  如果被拒绝，重新取样路径
%   iw_track_speed      0.000001 speed of tracking importance weight mean  追踪importance权重平均值的速度
%   num_samples_min     10       min aspired number of samples  最小期望样本数
%   num_samples_max     10       max aspired number of samples  最大期望样本数
%   p_requirements      [batch_mode,continuous_time]
%
% @fields:
%   SW_new   zeros          [num_neurons,num_inputs]  new weight mean  新的权重平均值
%   QW_new   ones           [num_neurons,num_inputs]  new weight variance  新的权重方差
%   SV_new   zeros          [num_neurons,num_neurons] new weight mean  新的权重平均值
%   QV_new   ones           [num_neurons,num_neurons] new weight variance  新的权重方差
%   r_mean   rand[-3]       [1,1]                     current estimate of iw norm. (log)  目前对iw norm的估计。(log)
%   biased_it       zeros   [0,0]                     iterations that were biased  有偏差的迭代   
%   asp_num_samples rand[num_samples_min,num_samples_max] [1,1]  aspired number of resamples  期望的resample数 
%
%
% David Kappel
% 24.05.2011
%

    % 每次更新网络只执行该语句块
    if net.update_on_spike
        net.got_sample = true;  % 将got_sample标志置为ture（该动作执行162001次）
        net.iteration = net.iteration + 1;  % 将计数器iteration+1（该动作执行162001次）
        return;
    end

    if ~isfield(net,'p_r_mean_init')
        net.p_r_mean_init = net.r_mean;
    end

    if net.use_iw && (net.asp_num_samples > 0)
        R_n = wta_draw( exp( double([ data(:).R ]') + net.r_mean ) );
        
        net.got_sample = any(R_n);

        if net.got_sample
            net.r_mean = net.r_mean - net.asp_num_samples*net.iw_track_speed;
            
            if ( sum(  exp( double([ data(:).R ]') + net.r_mean ) ) > 1 )
                warning('run is biased!');
                net.biased_it = [ net.biased_it, net.iteration+1 ];
            end

        else
            net.r_mean = net.r_mean + net.iw_track_speed;
        end
    else
        R_n = true(length(data),1);
        net.got_sample = true;
    end
    
    for i = find( R_n )'
        
        net.iteration = net.iteration + 1;

        if net.clip_weights
            net.W = max(-5,net.W + data(i).d_W);
            net.V = max(-5,net.V + data(i).d_V);
        else
            net.W = net.W + data(i).d_W;
            net.V = net.V + data(i).d_V;
        end
                
        if ~isnan( net.self_inhibition )
            net.V(eye(net.num_neurons) > 0) = net.self_inhibition;
        end
        
        if net.use_variance_tracking
            net.SW = data(i).SW_new;
            net.QW = data(i).QW_new;
            net.SV = data(i).SV_new;
            net.QV = data(i).QV_new;
        end

        net.IW = R_n;
    end
end
