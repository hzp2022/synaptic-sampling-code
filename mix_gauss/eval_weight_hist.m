function weight_hist = eval_weight_hist(epochs,idx)
% eval_weight_hist(epochs,plot_other,data)
%
% 评估给定时期的网络权重历史。
%

    if nargin<1
        epochs = 'all';
    end
    
    epoch_files = snn_locate_data_file(epochs);

    data = load(snn_locate_data_file(epoch_files{1}));
    
    weight_hist = struct;
    weight_hist.W = nan(numel(data.net.W),length(epoch_files));
    weight_hist.V = nan(numel(data.net.V),length(epoch_files));
    weight_hist.theta_W = nan(numel(data.net.theta_W),length(epoch_files));
    weight_hist.theta_V = nan(numel(data.net.theta_V),length(epoch_files));
    
    time_stamp = zeros(1,length(epochs));
    cur_time = 0;
    
    if nargin<2
        rand_perm = randperm(numel(data.net.W));
        idx = rand_perm(1:10);
    end
    
    snn_progress('evaluating epochs');
    
    for i=1:length(epoch_files)
        
        snn_progress(i/length(epoch_files));
        
        data = load(snn_locate_data_file(epoch_files{i}));
        if isfield(data,'sim_train') && ~isempty(data.sim_train)
            cur_time = cur_time + data.sim_train.time(end);
        elseif isfield(data.net,'time')
            cur_time = data.net.time(end);
        else
            cur_time = cur_time + 1;
        end
        
        time_stamp(i) = cur_time;
            
        weight_hist.W(:,i) = data.net.W(:);
        weight_hist.V(:,i) = data.net.V(:);
        weight_hist.theta_W(:,i) = data.net.theta_W(:);
        weight_hist.theta_V(:,i) = data.net.theta_V(:);
    end

    snn_progress();
    
    weight_hist.time = time_stamp;
    weight_hist.idx = idx;
    
    snn_save('weight_hist',weight_hist);
        
    h = figure;
    plot( time_stamp, weight_hist.W(idx,:) );
    save_fig( h, 'weight_hist' );
end

