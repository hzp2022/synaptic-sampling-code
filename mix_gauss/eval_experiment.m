function eval_experiment( session_ee_ee_all, session_ee_se_all )
% eval_experiment( ee_ee_session_paths, ee_se_session_paths )
% 评估神经元之间突触连接的形成和存活情况
% 
% 输入参数：
%   session_ee_ee_all：EE-EE模式的神经元会话路径
%   session_ee_se_all：EE-SE模式的神经元会话路径
% 
% 处理逻辑：
%   1.检查传递给函数的参数是否为单个字符串或字符串数组，如果不是，则将它们包装为单元格数组。
%   2.始化一些变量并定义一个时间序列，该序列用于评估突触形成和存活情况。 
%   3.对于每个EE-EE会话路径，它加载四个时刻的神经元网络状态数据，并计算每个时间间隔中新形成突触的百分比以及每个时间间隔中存活的突触的百分比。
%   4.对于每个EE-SE会话路径，它加载两个时刻的神经元网络状态数据，并计算每个时间间隔中存活的突触的百分比。
%   5.生成一个包含多个子图的图表，显示评估结果，例如新形成突触和存活突触的百分比。
%

%% evalute turnover 
    if ~iscell(session_ee_ee_all)
        session_ee_ee_all = { session_ee_ee_all };
    end

    if ~iscell(session_ee_se_all)
        session_ee_se_all = { session_ee_se_all };
    end

    h3 = 4.0;
    eval_times = h3:0.5:7;

    spine_formation = zeros(length(session_ee_ee_all),2);
    spine_survival_ee = zeros(length(session_ee_ee_all),length(eval_times));
    spine_survival_se = zeros(length(session_ee_se_all),length(eval_times));

    for f_id = 1:length(session_ee_ee_all)
        snn_switch_session(session_ee_ee_all{f_id});

        h = 3600/0.2; % number of iterations per hour

        t1 = round(2.5*h);
        t2 = round(3.0*h);
        t3 = round(3.5*h);
        t4 = round(4.0*h);

        data = load(snn_locate_data_file(t1));
        active_1 = (data.net.theta_W > 0);

        data = load(snn_locate_data_file(t2));
        active_2 = (data.net.theta_W > 0);

        data = load(snn_locate_data_file(t3));
        active_3 = (data.net.theta_W > 0);

        data = load(snn_locate_data_file(t4));
        active_4 = (data.net.theta_W > 0);

        spine_formation(f_id,:) = [ 100*sum( active_2(:) > active_1(:) )/sum(active_1(:)), 100*sum( active_4(:) > active_3(:) )/sum(active_2(:)) ];

        t2 = round(3.5*h);
        t3 = round(h3*h);

        spine_survival = zeros(1,length(eval_times));

        data = load(snn_locate_data_file(t2));
        active_2 = (data.net.theta_W > 0);

        data = load(snn_locate_data_file(t3));
        active_3 = (data.net.theta_W > 0);

        sp_active = active_3 > active_2;
        spine_survival(1) = sum(sp_active(:));

        for i=2:length(spine_survival)
            data = load(snn_locate_data_file(eval_times(i)*h));
            sp_active = and( sp_active, data.net.theta_W > 0 );    
            spine_survival(i) = sum(sp_active(:));
        end

        spine_survival_ee(f_id,:) = 100*spine_survival./spine_survival(1);
    end

    for f_id = 1:length(session_ee_se_all)
        snn_switch_session(session_ee_se_all{f_id});

        data = load(snn_locate_data_file(t2));
        active_2 = (data.net.theta_W > 0);

        data = load(snn_locate_data_file(t3));
        active_3 = (data.net.theta_W > 0);

        spine_survival = zeros(1,length(eval_times));

        sp_active = active_3 > active_2;
        spine_survival(1) = sum(sp_active(:));

        for i=2:length(spine_survival)
            data = load(snn_locate_data_file(eval_times(i)*h));
            sp_active = and( sp_active, data.net.theta_W > 0 );    
            spine_survival(i) = sum(sp_active(:));
        end

        spine_survival_se(f_id,:) = 100*spine_survival./spine_survival(1);
    end

    snn_switch_session(session_ee_ee_all{1});

%% plot results
    close all; drawnow;

    h1 = figure;
    subplot(1,3,1);

    bar( mean(spine_formation,1), 0.5 );
    hold on;
    if size(spine_formation,1)>1
        errorbar( mean(spine_formation,1), std(spine_formation,1), '.k' );
    end
    set(gca,'XTick',[1,2],'XTickLabel',{'SE','EE'});
    ylabel('spine formation (%)');
    save_fig( h1, 'spine-formation-se-ee' );

    spine_survival_ee_mean = mean(spine_survival_ee,1);
    spine_survival_ee_std = std(spine_survival_ee,1);
    spine_survival_se_mean = mean(spine_survival_se,1);
    spine_survival_se_std = std(spine_survival_se,1);

    subplot(1,3,2:3);

    y1 = spine_survival_se_mean;
    y2 = spine_survival_ee_mean;
    plot( eval_times, y1, 'b.', eval_times, y2, 'r.' );
    ylabel('formation of new synapses (%)');
    xlabel('time (hours)');
    legend('EE-SE','EE-EE');
    ylim([0,100]);

    [f,gof1] = fit(eval_times',y1','exp2');
    plot( f, eval_times, y1, 'b.' );
    hold on;
    if size(spine_survival_se,1)>1
        errorbar( eval_times, spine_survival_se_mean, spine_survival_se_std, '.b' );
    end

    [f,gof2] = fit(eval_times',y2','exp2');
    plot( f, eval_times, y2, 'r.' );
    ylim([0,100]);
    hold on;
    if size(spine_survival_ee,1)>1
        errorbar( eval_times, spine_survival_ee_mean, spine_survival_ee_std, '.r' );
    end
    xlim([eval_times(1),eval_times(end)]);
    ylabel( 'survival of new synapses (%)' );
    xlabel( 'time since exposure to EE (hours)' );
    legend( 'data EE-SE', 'fitted curve EE-SE', 'data EE-EE', 'fitted curve EE-EE' ); 
    
    save_fig( h1, 'spine-survival-se-ee' );

end
