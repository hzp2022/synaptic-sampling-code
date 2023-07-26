function plot_weight_evolution(epochs,nrn_idx,th)
%
% plot evolution of weights  绘制权重的演变图
%
% David Kappel
% 12.12.2014
%

    if nargin<1
        epochs = [0,650:1250:60000]*4;
    end
    if nargin<2
        nrn_idx = [1,2,6,7]; %[2,4,6,8];
    end
    if nargin<3
        th = 0.0;
    end
    
    sx = 28;
    sy = 28;
    
    W_all_epochs = nan(length(nrn_idx)*sy,length(epochs)*sx);
    theta_W_all_epochs = nan(length(nrn_idx)*sy,length(epochs)*sx);
    
    offs = 0;
    
    for j = 1:length(epochs)
        data_file_name = snn_locate_data_file(epochs(j),[],true);
        if isempty(data_file_name)
            continue;
        end
        data = load(data_file_name);
        W = data.net.W;
        theta_W = data.net.theta_W;
        
        for i = 1:length(nrn_idx)
            W_all_epochs(((i-1)*sy+1):(i*sy),((j-1)*sy+1):(j*sy)) = reshape( W(nrn_idx(i), 1:(28*28)), sy, sx )';
            theta_W_all_epochs(((i-1)*sy+1):(i*sy),((j-1)*sy+1):(j*sy)) = reshape( theta_W(nrn_idx(i), 1:(28*28)), sy, sx )' + offs;
        end
    end
    
     
    h = figure;
    subplot( 3, 1, 1 );
    imagesc(W_all_epochs,[0,3]);
    set(gca,'XTick',[],'YTick',[]);
    subplot( 3, 1, 2 );
    imagesc(theta_W_all_epochs>th);
    set(gca,'XTick',[],'YTick',[]);
    
    weight_hist = snn_load('weight_hist');
    
    show_synapses = 189;
    
    
    for i = show_synapses
        subplot( 3, 1, 3 );
        plot( weight_hist.time, weight_hist.theta_W(7*28*28+(i),:)' );
        xlim( [weight_hist.time(1), weight_hist.time(end)] );
        ylim( [-3,8] );
        title(int2str(i));
    end
    hold on;
    plot( [weight_hist.time(1),weight_hist.time(end)], [0,0], 'k-' );
    ylim([-2,5]);
    save_fig(h, 'weight_evolution')

    
    data = load(snn_locate_data_file, 'net');
    net = data.net;
    prior = @(w) 1./(net.w_prior_sigma*sqrt(2*pi)).*exp(-((w-net.w_prior_mean).^2)./(2*(net.w_prior_sigma^2)));

    w = -2:0.001:5;
    
    h = get_grid_layout(200,50,'id');
    plot( w, prior(w) );
    title( 'prior' );
    ylabel( 'p(w)' );
    xlabel( 'w' );
    xlim([-2,5]);

    save_fig(h, 'prior');
    
    data = load(snn_locate_data_file);
    h = figure; hist( data.net.W(data.net.theta_W>0), 100 );
    save_fig(h, 'weight_histogram_100bins');
    figure; hist( data.net.W(data.net.theta_W>0), 50 );
    save_fig(h, 'weight_histogram_50bins');
end
