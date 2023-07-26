function net = snn_sample_ctsp_lognormal( net, data, ct )
% Draws a spike from sem network - continuous time spiking hmm sems with structure plasticity.
% 从SEM网络中提取一个脉冲——连续时间HMM SEMs具有结构可塑性。
% 
% [net,Z,P] = snn_sample_ct( net, data, ct )
%
% Generates the output of a given wta-network by drawing
% a winner neuron from the current output probabilities
% (standard version).
% 通过从当前输出概率(标准版本)中提取winner神经元来生成给定WTA网络的输出。
%
% inputs:
%   net:  A network, see: snn-new()
%   data: A data structure to be simulated.  要模拟的数据结构。
%   ct:   Current time index.  当前时间索引（用于定位脉冲序列的第一个脉冲时间和最后一个脉冲时间）
%
% output:
%   net:      The (modified) network structure  (修改后的)网络结构
%
% @parameters:
%   num_neurons            10         number of output neurons  输出神经元的数量
%   num_inputs             10         number of input neurons   输入神经元的数量
%   tau_x_r                0.002      time constant of epsp window rise    EPSP窗口rise的时间常数
%   tau_z_r                0.002      time constant of epsp window rise    EPSP窗口rise的时间常数
%   tau_x_f                0.02       time constant of epsp window fall    EPSP窗口fall的时间常数
%   tau_z_f                0.02       time constant of epsp window fall    EPSP窗口fall的时间常数
%   tau_rf                 0.005      time constant of refractory window   不应期窗口时间常数
%   tau_r_r                8.0        time constant of adaptation current  自适应电流时间常数
%   tau_r_f                10.0       time constant of adaptation current  自适应电流时间常数
%   output_rate            200        network spike rate per WTA group     每个WTA组的网络脉冲发射率
%   groups                 ''         assignment of neurons to groups      将神经元分配到组
%   temperature            0          sampling temperature                 采样温度
%   iw_mode                'exact'    method to calculate importance weights     一种计算importance权重的方法
%   use_lateral_weights    false      use lateral weights                        使用横向权重
%   update_on_spike        false      update weights when spike occurs           在出现峰值时更新权重
%   fix_num_spikes         false      fix number of output spikes                固定输出尖峰的数量
%   clipped_w_for_learning false      use clipped weights for learning           使用剪裁的权重进行学习
%   use_prior              true       use prior for learning                     使用先验进行学习
%   w_offs                 3          shift constant for weights (-log(alpha))   权重的shift常数(-log(alpha))
%   w_noise                1          std of brownian noise on synapitc weights  布朗噪声对突触权重的std
%   w_rf                  -10         strength of refractory window              不应期窗口的强度
%   w_r                   -100        adaptation weight                          适配权重
%   theta_w_min           -5          minimum value of synaptic parameters       突触参数的最小值  
%   weight_prior_method    lognormal  method for weight prior distribution       一种权重先验分配方法
%   record_w               ''         record feedforward weights                 记录前馈权重
%   record_v               ''         record lateral weights                     记录侧向权重
%   clip_weights           ''         clip weights to zero at this value         在该值下将权重剪裁为零
%   theta_0                3          offset of synaptic weight prameter         突触权重参数偏移量
%   rec_delay              0.005      delay on recurrent synapses                recurrent突触的延迟
%   w_d_max                10         clip weight updates at this value          剪贴权重以该值更新
%   w_prior_N              100        number of samples parameter                samples数量参数
%   output_spike_times     ''         times points of the network to spike       网络脉冲的时间点
%   p_required_methods     [weight_prior]
%
% @fields:
%   W_map    ones           [num_neurons,num_inputs]    mapping for feedforward weights   前馈权重的映射 
%   V_map    ones           [num_neurons,num_neurons]   mapping between lateral weights   横向权重之间的映射 
%   N_map    ones           [1,num_neurons]             mapping for neurons               神经元映射 
%   W        zeros          [num_neurons,num_inputs]    feedforward network weights       前馈网络权重
%   V        zeros          [num_neurons,num_neurons]   recurrent network weights         recurrent网络权重
%   theta_W  weight_prior   [num_neurons,num_inputs]    feedforward network weights       前馈网络权重
%   theta_V  weight_prior   [num_neurons,num_neurons]   recurrent network weights         recurrent网络权重
%   rec_spikes    zeros  [0,0]             recurrent spike events       recurrent脉冲事件
%   last_spike_t  zeros  [num_neurons,1]   last output spike times      最后一次输出尖峰时间
%   hX    zeros   [num_inputs,2]    feedforward PSPs                    前馈PSPs
%   hZ    zeros   [num_neurons,2]   recurrent PSPs                      recurrent突触后电位
%   hR    zeros   [num_neurons,2]   adaptation current                  适应电流
%   R     zeros   [1,1]             current importance weight (log)     当前的importance权重(log)
%   num_o zeros   [num_neurons,1]   number of output spikes per neuron  每个神经元的输出脉冲数
%   Pt    zeros   [0,0]             history of output prob.             输出概率的历史
%   Ut    zeros   [0,0]             history of membrane potentials.     膜电位的历史
%   Wt    zeros   [0,0]             history of synaptic weights         突触权重的历史
%   Vt    zeros   [0,0]             history of synaptic weights         突触权重的历史
%   Zt    zeros   [2,0]             history of output spike             输出脉冲的历史
%   At    szeros  [2,0]             log activity of network at spike times               记录脉冲时刻的网络活动  
%   A_w   zeros   [2,0]             log activity at feedforward synapses at spike times  记录在脉冲时间前馈突触的活动
%   A_v   zeros   [2,0]             log activity at recurrent synapses at spike times    记录在脉冲时间recurrent突触的活动
%   It    zeros   [0,0]             inhibitory current at spike times                    脉冲时间的抑制性电流
%
%
% David Kappel
% 24.05.2011
%
%


%% 准备工作

%     t = data.time(ct(1));  % 当前输出脉冲的发射时刻t（初始化为0）
    t = data.time(1);
    
%     time_range = data.time(ct(end))-data.time(ct(1));  % 时间范围（模式时间长度-0）
    time_range = data.time(end-1)-data.time(1);
    
    % 为net设置一个由10个神经元组成的group
    if isempty(net.groups)
        net.groups = net.num_neurons;
    end
    
    % 获取输出脉冲时刻序列spike_times和输出脉冲个数num_spikes
    if ~isempty(net.output_spike_times)  
        spike_times = net.output_spike_times;  
        num_spikes = length(spike_times);      
    else  
        if net.fix_num_spikes
            num_spikes = round( length(net.groups)*net.output_rate*time_range );
        else
            num_spikes = poissrnd( double( length(net.groups)*net.output_rate*time_range ) );  % lambda为输出神经元一个模式时间长度内发射脉冲的个数期望（均值）
        end

        spike_times = sort( time_range*rand( 1, num_spikes ) );  % 将输出脉冲的发射过程建模为随机发射（得到排序后的脉冲发射时间序列）
    end
    
    delta_t = double( diff([0,spike_times]) );  % 两两输出脉冲发射的时间间隔(0-1,1-2,...,(n-1)-n)
    
    rec_spikes = double([ net.rec_spikes, [zeros(1,num_spikes);spike_times+net.rec_delay] ]);  % recurrent脉冲序列（第一行为全0（暂时不知道是哪个神经元发射的脉冲），第二行为(输出脉冲时刻+recurrent突触延迟)）
    num_rs = size(net.rec_spikes,2);  % recurrent脉冲个数（初始化）
    
    % net字段初始化
    net.Zt = zeros(3, num_spikes, 'single');                  % 输出脉冲的历史（第一行记录当前输出脉冲由哪个输出神经元发射，第二行记录当前输入的标签，第三行记录发射时间，一列一列进行记录）
    net.Pt = zeros(net.num_neurons+1, num_spikes, 'single');  % 输出概率的历史（记录各输出神经元发射当前输出脉冲的概率，最后一行记录输出脉冲时间，一列一列进行记录）
    net.Ut = zeros(net.num_neurons+1, num_spikes, 'single');  % 膜电位的历史（记录在各输出脉冲时间的输出神经元膜电位，最后一行记录输出脉冲时间（直接一次性添加整行），一列一列进行记录）
    net.At = zeros(2,num_spikes, 'single');                   % 记录脉冲时间的网络活动（记录各输出脉冲时间的抑制性电流It，最后一行记录输出脉冲时间，一列一列进行记录）
    
    net.Ut(end,:) = spike_times;  % 将net的膜电位历史的最后一行设置为各输出脉冲序列的发射时刻
    
    hX = net.hX;  % 从net中获取上一次处理后的前馈PSPs
    hZ = net.hZ;  % 从net中获取上一次处理后的recurrent突触后电位
    
    hX_all = zeros(net.num_inputs,num_spikes);   % 突触前神经元i在时间t的EPSPs之和的权重归一化值x_i(t)（记录所有时间t，初始化为全0）
    hZ_all = zeros(net.num_neurons,num_spikes);  % 突触后神经元k在时间t的EPSPs之和的权重归一化值z_k(t)（记录所有时间t，初始化为全0）
    A_v = zeros(1,num_spikes);                   % 记录在脉冲时间recurrent突触的抑制性电流（由于本实验不使用精确的importance权重计算方法，故用不上该变量）
    A_w = zeros(1,num_spikes);                   % 记录在脉冲时间前馈突触的抑制性电流（由于本实验不使用精确的importance权重计算方法，故用不上该变量）

    % init wta groups 初始化WTA电路
    chosen_group = randi(1,num_spikes,1,length(net.groups));  % 用于选择输出脉冲的神经元所在的group（本实验只使用一个group，故设置为num_spikes个1）

    group_idx = [ 0, cumsum( net.groups ) ];  % 各group的神经元索引边界（这里只有一个group故为(0,10]）
    active_neurons = find(net.N_map>0);       % 找出net中的活跃神经元（神经元映射N_map(全1的逻辑数组)>0的索引号(神经元)）
    nrn_idx = cell(1,length(net.groups));     % 各group中活跃神经元的索引（这里只有一个group，故初始化为1x1的cell）

    % 遍历每一个group得到各组活跃神经元的索引号
    for g = 1:length(net.groups)
        nrn_idx{g} = intersect(active_neurons, (group_idx(g)+1):(group_idx(g+1)) );  % 第g组神经元中活跃神经元的索引
        if isempty(nrn_idx{g})
            keyboard;
            error('empty group found!');
        end
    end
    last_update_time = repmat( data.time(ct(1)), 1, length(net.groups) );  % 各group的最后一次更新时间（初始化为0）
   
    use_exact_iw = net.use_iw && strcmp( net.iw_mode, 'exact' );  
    do_assertions = snn_options('assert'); 
    
    net.num_o(:) = 0;  % 每个输出神经元的输出脉冲数（初始化&重置为全0）
    
    W_map = ( net.W_map > 0 );                          % 前馈权重的映射（得到10x1000的全1逻辑数组）
    V_map = ( net.use_lateral_weights*net.V_map > 0 );  % 横向权重之间的映射（得到10x10的全0逻辑数组,本实验不使用横向权重）
    
    if ~isempty(net.record_w)  
        net.Wt = nan(numel(net.record_w)+1,num_spikes);  
    end
    if ~isempty(net.record_v) 
        net.Vt = nan(numel(net.record_v)+1,num_spikes);  
    end

    % 权重剪裁值的设置
    if ~isempty(net.clip_weights)
        clip_weights = net.clip_weights;
    else
        clip_weights = exp(-net.theta_0);  % 实际权重由max{0,W-clip_weights}给出，即在该值下将权重剪裁为零
    end

    prior_rate = net.use_prior/net.w_prior_sigma^2;  % prior_rate为先验概率密度函数的超参数之一，用于控制先验分布的形状（这里设为突触权重方差的倒数：1）
    
    num_sp_z = diff( [0; sum( repmat(rec_spikes(2,:),num_spikes,1) < repmat(spike_times',1,size(rec_spikes,2)), 2)] );  % 各输出脉冲时间间隔(0-1,1-2,...,(n-1)-n)内recurrent脉冲的个数（按列排序）
    num_sp_x = diff( [0; sum( repmat(data.Xt(2,:),num_spikes,1) < repmat(spike_times',1,size(data.Xt,2)), 2) ] );       % 各输出脉冲时间间隔(0-1,1-2,...,(n-1)-n)内输入脉冲的个数（按列排序）
    
    i = 1;
    l = 1;

%% 参数更新(0-1,1-2,2-3,(n-1)-n时间间隔内的输入脉冲和recurrent脉冲对net的影响)

    % 遍历所有输出脉冲
    for j = 1:num_spikes

        t = spike_times(j);         % 当前输出脉冲时间
        l_r = l+(1:num_sp_z(j))-1;  % 当前输出脉冲与上一个输出脉冲的时间间隔内recurrent脉冲的索引范围（全局情况下的发射顺序号）
        i_r = i+(1:num_sp_x(j))-1;  % 当前输出脉冲与上一个输出脉冲的时间间隔内输入脉冲的索引范围（全局情况下的发射顺序号）
        
        % 计算突触后神经元k在时间t的EPSPs之和的权重归一化值z_k(t)的局部公式
        hZ(:,1) = hZ(:,1).*exp(-(delta_t(j))/net.tau_z_r) + ...
                  sum( sparse(rec_spikes(1,l_r),1:num_sp_z(j),exp( -double(t-rec_spikes(2,l_r))/net.tau_z_r ),net.num_neurons,num_sp_z(j)), 2 );
        hZ(:,2) = hZ(:,2).*exp(-(delta_t(j))/net.tau_z_f) + ...
                  sum( sparse(rec_spikes(1,l_r),1:num_sp_z(j),exp( -double(t-rec_spikes(2,l_r))/net.tau_z_f ),net.num_neurons,num_sp_z(j)), 2 );
        
        % 计算突触前神经元i在时间t的EPSPs之和的权重归一化值x_i(t)的局部公式
        hX(:,1) = hX(:,1).*exp(-(delta_t(j))/net.tau_x_r) + ...
                  sum( sparse(double(data.Xt(1,i_r)),1:num_sp_x(j),exp( -double(t-data.Xt(2,i_r))/net.tau_x_r ),net.num_inputs,num_sp_x(j)), 2 );
        hX(:,2) = hX(:,2).*exp(-(delta_t(j))/net.tau_x_f) + ...
                  sum( sparse(double(data.Xt(1,i_r)),1:num_sp_x(j),exp( -double(t-data.Xt(2,i_r))/net.tau_x_f ),net.num_inputs,num_sp_x(j)), 2 );
        
        l=l+num_sp_z(j);  % 将l更新为下一个时间间隔内的recurrent脉冲的起始序号（全局情况下的发射顺序号）
        i=i+num_sp_x(j);  % 将r更新为下一个时间间隔内的输入脉冲的起始序号（全局情况下的发射顺序号）
        
        % 计算神经元k在时间t的适应电流β_k(t)的局部公式
        net.hR(:,1) = net.hR(:,1).*exp(-double(delta_t(j))/net.tau_r_r);
        net.hR(:,2) = net.hR(:,2).*exp(-double(delta_t(j))/net.tau_r_f); 

        d_hX = diff(hX,1,2);  % 突触前神经元i在时间t的EPSPs之和的权重归一化值x_i(t)（由hX的第二列减第一列得到）
        d_hZ = diff(hZ,1,2);  % 突触后神经元k在时间t的EPSPs之和的权重归一化值z_k(t)（由hZ的第二列减第一列得到）

        hX_all(:,j) = d_hX;  % 给存储所有时刻x_i(t)的hX_all添加当前时刻的x_i(t)（添加一列）
        hZ_all(:,j) = d_hZ;  % 给存储所有时刻z_k(t)的hZ_all添加当前时刻的z_k(t)（添加一列）

        % update membrane potential  更新膜电位
        u_rf = net.w_rf*exp(-double(t-net.last_spike_t)/net.tau_rf);  % 计算不应期窗口产生的膜电位（w_rf为不应期振幅，tau_rf为不应期窗口时间常数）

        grp_nrns = nrn_idx{chosen_group(j)};  % group内的神经元

        % ou process on synaptic parameters  突触参数的OU过程
        if net.eta>0

            drift_rate = ((t-last_update_time(chosen_group(j)))*net.eta*prior_rate);             % drift_rate控制确定性漂移的幅度
            std_wiener = net.temperature*sqrt(2*net.eta*(t-last_update_time(chosen_group(j))));  % std_wiener控制Wiener过程产生的随机性漂移的离散程度
            
            % 更新前馈网络权重theta_W
            net.theta_W(grp_nrns,:) = max( net.theta_w_min, net.theta_W(grp_nrns,:) + ...
                                           drift_rate*(net.w_prior_mean-net.theta_W(grp_nrns,:)) + ...
                                           std_wiener*randn(length(grp_nrns),net.num_inputs) );
            % 更新recurrent网络权重theta_V
            net.theta_V(grp_nrns,:) = max( net.theta_w_min, net.theta_V(grp_nrns,:) + ...
                                           drift_rate*(net.w_prior_mean-net.theta_V(grp_nrns,:)) + ...
                                           std_wiener*randn(length(grp_nrns),net.num_neurons) );
 
            last_update_time(chosen_group(j)) = t;  % 将group的最后一次更新时间设为当前时间t（每次循环都做这样的设置，循环结束后记录的便是最后一次更新时间）
            
            % 将前馈网络权重和recurrent网络权重根据指数函数w_i=exp(θ_i-θ_0)映射到w参数空间
            W = W_map(grp_nrns,:).*exp(net.theta_W(nrn_idx{chosen_group(j)},:) - net.theta_0);  % 前馈网络权重
            V = V_map(grp_nrns,:).*exp(net.theta_V(nrn_idx{chosen_group(j)},:) - net.theta_0);  % recurrent网络权重
            
            if net.clipped_w_for_learning
                W = max(0,W-clip_weights);
                V = max(0,V-clip_weights);
            end
                
            net.W(grp_nrns,:) = W;  % 将更新后的前馈网络权重记录到net
            net.V(grp_nrns,:) = V;  % 将更新后的recurrent网络权重记录到net
        else
            W = W_map(grp_nrns,:).*net.W(grp_nrns,:);  
            V = V_map(grp_nrns,:).*net.V(grp_nrns,:);  
        end
        
        % 对当前的权重进行剪裁（实际权重由max{0,W-clip_weights}给出）
        if ~net.clipped_w_for_learning
            W = max(0,W-clip_weights);
            V = max(0,V-clip_weights);
        end

        U_w = W*d_hX;  % 前馈EPSPs产生的膜电位（不考虑适应电流β_k(t)）
        U_v = V*d_hZ + u_rf(grp_nrns) + net.w_r*diff(net.hR(grp_nrns,:),1,2);  % recurrent脉冲事件产生的膜电位（考虑适应电流β_k(t)）

        U = U_w + U_v;  % 每个输出神经元的总膜电位

        P_t = zeros(net.num_neurons,1);  % 输出神经元发射脉冲的概率（初始化为全0）

        [P_t(grp_nrns),A] = wta_softmax( U );  % 对输出神经元膜电位做softmax归一化得到各输出神经元发射脉冲的概率P_t和时间t的网络活动 A = log(sum(exp( U - U_max )))+(U_max)（这里使用A代表整个网络的活动，A包含了所有输出神经元的膜电位信息，不太恰当的描述：做了一个softmax逆操作）

        % draw spike  绘制脉冲
        [Z_i,k] = wta_draw_k(P_t);  % 根据P_t随机抽取一个输出神经元发射脉冲（这里得到记录该神经元位置的稀疏矩阵Z_i和该神经元的索引）

        net.Zt(:,j) = [k;data.seq_id;t];         % 往net的输出脉冲历史中添加一条记录
        net.Pt(:,j) = [P_t;t];       % 往net的输出概率历史中添加一条记录
        net.Ut(grp_nrns,j) = U;      % 往net的膜电位历史中添加一条记录
        rec_spikes(1,j+num_rs) = k;  % 记录当前recurrent脉冲是由哪个输出神经元发射的

        net.num_o(k) = net.num_o(k)+1;  % 第k个神经元的输出脉冲数+1（num_o每次处理新的脉冲序列都会先重置为全0）

        net.last_spike_t(k) = t;  % 将第k个神经元的最后一个脉冲时间更新为当前遍历到的输出脉冲时间（每次都进行更新，最后得到的便是各输出神经元的最后一个脉冲时间，最后一个脉冲时间肯定不会是原来的输出脉冲时间，因为recurrent脉冲是在输出脉冲时间上+了一个rec_delay）
        net.hR(k,:) = net.hR(k,:)+1;  % 将第k个神经元的rise窗口和fall窗口的适应电流均+1

        net.At(:,j) = [A,t];  % 记录时间t的网络活动A（It）  

        if do_assertions
            if length(net.groups) == 1
                [P_t_2,A_2] = wta_softmax( U );
                snn_assert_equal( P_t, P_t_2 );
                snn_assert_equal( A, A_2 );
            end
            
            l=l-num_sp_z(j); i=i-num_sp_x(j);
            
            if j==1
                hX_gd = net.hX;
                hZ_gd = net.hZ;
                last_input_spikes = repmat(data.time(ct(1)), net.num_inputs, 1);
                last_output_spikes = repmat(data.time(ct(1)), net.num_neurons, 1);
            end
            
            % update feedforward synapses
            while (i < size(data.Xt,2)) && (t > data.Xt(2,i))

                n_id = data.Xt(1,i);
                sp_t = data.Xt(2,i);

                hX_gd(n_id,1) = hX_gd(n_id,1)*exp(-double(sp_t-last_input_spikes(n_id))/net.tau_x_r) + 1;
                hX_gd(n_id,2) = hX_gd(n_id,2)*exp(-double(sp_t-last_input_spikes(n_id))/net.tau_x_f) + 1;

                last_input_spikes(n_id) = sp_t;
                i = i+1;
            end

            % update lateral synapses
            while (l < size(rec_spikes,2)) && (t > rec_spikes(2,l))

                n_id = rec_spikes(1,l);
                sp_t = rec_spikes(2,l);

                hZ_gd(n_id,1) = hZ_gd(n_id,1)*exp(-double(sp_t-last_output_spikes(n_id))/net.tau_z_r) + 1;
                hZ_gd(n_id,2) = hZ_gd(n_id,2)*exp(-double(sp_t-last_output_spikes(n_id))/net.tau_z_f) + 1;

                last_output_spikes(n_id) = sp_t;
                l = l+1;
            end
            
            hZ_gd(:,1) = hZ_gd(:,1).*exp(-double(t-last_output_spikes)/net.tau_z_r);
            hZ_gd(:,2) = hZ_gd(:,2).*exp(-double(t-last_output_spikes)/net.tau_z_f);
            hX_gd(:,1) = hX_gd(:,1).*exp(-double(t-last_input_spikes)/net.tau_x_r);
            hX_gd(:,2) = hX_gd(:,2).*exp(-double(t-last_input_spikes)/net.tau_x_f);
            
            last_input_spikes(:) = t;
            last_output_spikes(:) = t;
            
            snn_assert_equal( hZ, hZ_gd );
            snn_assert_equal( hX, hX_gd );            
        end
        
        if use_exact_iw
            [P_t_v,A_v(j)] = wta_softmax( U_v );
            [P_t_w,A_w(j)] = wta_softmax( U_w );

            A = A - A_v(j) - A_w(j);

            if do_assertions
                [P_t_h,A_h] = wta_softmax( log( mk_stochastic( exp(U_v) ) ) + ...
                                           log( mk_stochastic( exp(U_w) ) ) );
                snn_assert_equal( P_t, P_t_h );
                snn_assert_equal( A, A_h );
            end
        end
        
        if any(isnan(P_t))
            if snn_options('NoKeyboard')
                error('encountered numerical stability issue!');
            else
                fprintf('encountered numerical stability issue! dropping to keyboard...\n');
                keyboard;
            end
        end

        % recurrent脉冲事件对网络权重的影响
        if net.eta>0 
             % 计算局部公式W_exp_k和V_exp_k
             W_exp_k = exp( double( net.W(k,:) - net.w_offs ) );  % 将第k个输出神经元（recurrent神经元）与输入神经元之间的所有权重根据指数函数W_exp=exp(W-w_offs)做计算得到W_exp_k
             V_exp_k = exp( double( net.V(k,:) - net.w_offs ) );  % 将第k个输出神经元（recurrent神经元）与输出神经元之间的所有权重根据指数函数W_exp=exp(W-w_offs)做计算得到V_exp_k
        
             net.theta_W(k,:) = net.theta_W(k,:) + net.w_prior_N*net.eta*(net.W(k,:).*(d_hX'-min(net.w_d_max,W_exp_k)));  % 更新第k个输出神经元的所有前馈网络权重
             net.theta_V(k,:) = net.theta_V(k,:) + net.w_prior_N*net.eta*(net.V(k,:).*(d_hZ'-min(net.w_d_max,V_exp_k)));  % 更新第k个神经元的所有recurrent网络权重
        end
        
        if ~isempty(net.record_w)
            net.Wt(:,j) = [net.W(net.record_w), t];
        end

        if ~isempty(net.record_v)
            net.Vt(:,j) = [net.V(net.record_v), t];
        end
    end
    
%% 参数更新(n-end时间间隔内的输入脉冲和recurrent脉冲对net的影响)

    delta_t = double(data.time(ct(end))-t);  % 将delta_t设为(模式时间长度-最后一个输出脉冲时间)
    t = data.time(ct(end));                  % 将t设为模式时间长度
    
    num_sp_z = sum( (spike_times(l:end) + net.rec_delay) < t, 2 );  % 将num_sp_z设为最后一个输入脉冲到模式时间长度之间的recurrent脉冲个数
    num_sp_x = sum( data.Xt(2,i:end) < t, 2 );                      % 将num_sp_x设为最后一个输入脉冲到模式时间长度之间的输入脉冲个数
    
    l_r = l+(1:num_sp_z)-1;  % 最后一个输入脉冲到模式时间长度之间的recurrent脉冲的索引范围（全局情况下的发射顺序号）
    i_r = i+(1:num_sp_x)-1;  % 最后一个输入脉冲到模式时间长度之间的输入脉冲的索引范围（全局情况下的发射顺序号）

    % 计算最后一个输入脉冲到模式时间长度之间的突触后神经元k在时间t的EPSPs之和的权重归一化值z_k(t)的局部公式
    hZ(:,1) = hZ(:,1).*exp(-(delta_t)/net.tau_z_r) + ...
              sum( sparse(rec_spikes(1,l_r),1:num_sp_z,exp( -double(t-rec_spikes(2,l_r))/net.tau_z_r ),net.num_neurons,num_sp_z), 2 );
    hZ(:,2) = hZ(:,2).*exp(-(delta_t)/net.tau_z_f) + ...
              sum( sparse(rec_spikes(1,l_r),1:num_sp_z,exp( -double(t-rec_spikes(2,l_r))/net.tau_z_f ),net.num_neurons,num_sp_z), 2 );
    
    % 计算最后一个输入脉冲到模式时间长度之间的突触前神经元i在时间t的EPSPs之和的权重归一化值x_i(t)的局部公式
    hX(:,1) = hX(:,1).*exp(-(delta_t)/net.tau_x_r) + ...
              sum( sparse(double(data.Xt(1,i_r)),1:num_sp_x,exp( -double(t-data.Xt(2,i_r))/net.tau_x_r ),net.num_inputs,num_sp_x), 2 );
    hX(:,2) = hX(:,2).*exp(-(delta_t)/net.tau_x_f) + ...
              sum( sparse(double(data.Xt(1,i_r)),1:num_sp_x,exp( -double(t-data.Xt(2,i_r))/net.tau_x_f ),net.num_inputs,num_sp_x), 2 );

    l=l+num_sp_z;  
    
    % 最后一个输出脉冲时刻的突触参数的ou过程
    if net.eta>0
        % ou process on synaptic parameters  突触参数的ou过程
        drift_rate = (delta_t*net.eta*prior_rate);  % drift_rate控制确定性漂移的幅度
        std_wiener = net.temperature*sqrt(2*net.eta*delta_t);  % std_wiener控制Wiener过程产生的随机性漂移的离散程度
        net.theta_W = net.theta_W + drift_rate*(net.w_prior_mean-net.theta_W) + std_wiener*randn(size(net.theta_W));  % 更新前馈网络权重theta_W
        net.theta_V = net.theta_V + drift_rate*(net.w_prior_mean-net.theta_V) + std_wiener*randn(size(net.theta_V));  % 更新recurrent网络权重theta_V

        % update weights  更新权重
        net.W = W_map.*exp(net.theta_W - net.theta_0);  % 根据w_i=exp(θ_i-θ_0)将前馈网络权重theta_W映射到w参数空间
        net.V = V_map.*exp(net.theta_V - net.theta_0);  % 根据w_i=exp(θ_i-θ_0)将recurrent网络权重theta_V映射到w参数空间
    end


%% 更新net字段

    net.rec_spikes = rec_spikes(:,l:end); 
    net.rec_spikes(2,:) = net.rec_spikes(2,:)-t;
    net.last_spike_t = net.last_spike_t - t;
    
    net.R = mean( net.At(1,:) );
    
    net.A_v = A_v;
    net.A_w = A_w;
    
    if use_exact_iw
        net.It = [ net.At(1,:)+A_v+A_w; net.At(2,:)  ];
    else
        net.It = net.At;
    end
    
    net.hX = hX;
    net.hZ = hZ;
    net.hX_all = hX_all;
    net.hZ_all = hZ_all;
end
