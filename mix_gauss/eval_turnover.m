function turnover_rate = eval_turnover(epochs,weight_th)
% eval_turnover(pochs,weight_th)
%
% 评估周转率。
%

    if nargin<1
        epochs = 'all';
    end
    if nargin<2
        weight_th = 0;
    end

    turnover_rate = struct;

    turnover_rate.V_in = nan(1,length(epochs));
    turnover_rate.V_out = nan(1,length(epochs));
    turnover_rate.W_in = nan(1,length(epochs));
    turnover_rate.W_out = nan(1,length(epochs));
    time_stamp = zeros(1,length(epochs));

    epoch_files = snn_locate_data_file( epochs );
    
    data = load(snn_locate_data_file(epoch_files{1}));
    
    V_map = (data.net.theta_V(data.net.N_map>0,data.net.N_map>0) > weight_th);
    W_map = (data.net.theta_W(data.net.N_map>0,:) > weight_th);
    
   
    snn_progress( 'evaluating turnover rate' );
    
    
    for i=2:length(epoch_files)
        
        snn_progress(i/length(epoch_files));
        
        data = load(snn_locate_data_file(epoch_files{i}));

        V_map_new = (data.net.theta_V(data.net.N_map>0,data.net.N_map>0) > weight_th);
        W_map_new = (data.net.theta_W(data.net.N_map>0,:) > weight_th);
        
        turnover_rate.V_in(i) = sum( (V_map(:) - V_map_new(:)) > 0 );
        turnover_rate.V_out(i) = sum( (V_map(:) - V_map_new(:)) < 0 );
        turnover_rate.W_in(i) = sum( (W_map(:) - W_map_new(:)) > 0 );
        turnover_rate.W_out(i) = sum( (W_map(:) - W_map_new(:)) < 0 );
        
        V_map = V_map_new;
        W_map = W_map_new;

        if isfield(data,'sim_train') && ~isempty(data.sim_train)
            time_stamp(i) = time_stamp(i-1) + data.sim_train.time(end);
        end
    end
    
    snn_progress();
    
    turnover_rate.time_stamp = time_stamp;
    turnover_rate.pps_in = ( (turnover_rate.W_in(2:end)+turnover_rate.V_in(2:end)) ./ diff( turnover_rate.time_stamp ) )./(numel(data.net.V)+numel(data.net.W));
    turnover_rate.pps_out = ( (turnover_rate.W_out(2:end)+turnover_rate.V_out(2:end)) ./ diff( turnover_rate.time_stamp ) )./(numel(data.net.V)+numel(data.net.W));
    
    snn_save( 'turnover_rate', turnover_rate );

    h1 = figure;
    plot( time_stamp(2:end), turnover_rate.pps_in*60*100, 'b-', time_stamp(2:end), turnover_rate.pps_out*60*100, 'r-' );
    xlabel('time [minutes]');
    ylabel('number of synapses');
    save_fig(h1,'turnover_rate');
end

