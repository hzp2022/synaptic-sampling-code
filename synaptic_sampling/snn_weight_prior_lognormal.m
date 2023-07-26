function W = snn_weight_prior_lognormal( net, data, ct )
% evaluate a lognormal weight prior on the given network
% 在给定的网络上评估一个对数正态权重先验
%
% W = snn_weight_prior_lognormal( net, data, ct )
%
% Evaluates the update function for the given set of network weights.
% If 'sample' is passed for argument ct, a sample form a the lognoral
% distribution is generated. If 'lambda' is passed a lamda function
% for the weight udpates is returned.
% 评估给定网络权重集的更新函数。如果为参数ct传递了“sample ”,则会生成一
% 个对数正态分布的样本。如果传递了“lambda ”,则返回权重更新的lamda函数。
%
% @parameters:
%   w_prior_mean           1.00     synaptic weights prior  突触权重的先验
%   w_prior_sigma          0.50     synaptic weights std  突触权重的Std
%   w_prior_alpha          1.00     synaptic weights alpha scale  突触权重的α标度
%   w_prior_d_max         10.00     maximum derivative  最大导数
%   w_prior_rate           1.00     update rate for prior  先前的更新率
%   w_prior_init_mean      ''       mean initial weight  平均初始重量
%   w_prior_init_sigma     ''       initial weight std  初始权重std
%   w_prior_b_min          0.02     min learning rate  最小学习率
%
% David Kappel
% 11.03.2014
%
%

    if ischar( ct ) && strcmp( ct, 'sample' )
        % 返回从前一个W ~ p( W)中抽取的scaled samples
        if isempty(net.w_prior_init_mean)
            init_mean = net.w_prior_mean;
        else
            init_mean = net.w_prior_init_mean;
        end
        if isempty(net.w_prior_init_sigma)
            init_sigma = net.w_prior_sigma;
        else
            init_sigma = net.w_prior_init_sigma;
        end
        W = init_mean + init_sigma*randn( data );
    elseif ischar( ct ) && strcmp( ct, 'psi' ) 
        % 返回先前引起的权重变化的lambda函数，即d/dW log p( W)
        W = @(w)  min( net.w_prior_d_max, ( 1 + 1/(net.w_prior_sigma^2).*( net.w_prior_mean - log(max(eps,w)) ) )./max(eps,w) );
    elseif ischar( ct ) && strcmp( ct, 'eta' )
        % 返回学习率的λ函数，即\eta( W)
        W = @(w) max( net.w_prior_b_min, w.^2 );
    elseif ischar( ct ) && strcmp( ct, 'prior' )
        % 返回学习率的λ函数，即\eta( W)
        W = @(w) 1./(w.*net.w_prior_sigma*sqrt(2*pi)).*exp(-((log(w)-net.w_prior_mean).^2)./(2*(net.w_prior_sigma^2)));
    else
        % 返回由先验引起的权重变化，即d/dW log p( W )
        W = min( net.w_prior_d_max, -( (log(max(eps,data)) - net.w_prior_mean)./(net.w_prior_sigma.^2) + 1 )./max(eps,data) );
    end
end
