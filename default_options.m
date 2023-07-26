function options = default_options( varargin )
% 设置并返回网络和实验的默认选项。
%
% 更多详情见synaptic_sampling/snn_sample_ctsp_lognormal.m
%
   base_path = 'results/';  % 基础路径
   
   args = varargin;  
   
   if (mod(numel(varargin),2)==1) && iscell(varargin{end})  % 如果varargin的长度为奇数且最后一个元素是元胞数组
       args = { varargin{1:(end-1)}, varargin{end}{:} };    % 将arg的前(end-1)个元素设置为varargin的前(end-1)个元素，arg的最后一个元素设置为varargin的最后一个元素的所有元素重构成的列向量
   end
   
   % 处理传递给default_options函数的参数
   [base_path, args] = snn_process_options( args, 'base_path', base_path );  

   options =    { 'save_interval', 10000, ...       
                  'output_rate', 100, ...             % output rate per WTA circuit (Hz)           每个WTA电路的输出率(Hz)
                  'train_method', 'rs', ...           % continuous time batch update               连续时间批量更新
                  'tau_x_r', 0.002, ...               % rise time of feed-forward EPSP (s)         前馈EPSP的rise时间(s)
                  'tau_z_r', 0.002, ...               % rise time of lateral EPSP (s)              横向EPSP的rise时间(s)
                  'tau_x_f', 0.020, ...               % fall time of feed-forward EPSP (s)         前馈EPSP的fall时间(s)
                  'tau_z_f', 0.020, ...               % fall time of lateral EPSP (s)              横向EPSP的fall时间(s)
                  'tau_rf', 0.0100, ...               % fall time of refractory EPSP (s)           refractory EPSP的fall时间
                  'rec_delay', 0.005, ...             % delay on lateral synapses (s)              横向突触的延迟
                  'eta', 1E-4, ...                    % learn rate                                 学习率
                  'pretrain_ff_weights', false, ...   % pretrain feed-forward weights              预训练前馈权重
                  'update_on_spike', true, ...        % update right after spike event             峰值事件后立即更新
                  'regen_seqs', true, ...             % regenerate sequences in each epoch         在每个时期重新生成序列
                  'iw_track_speed', 0.001, ...        % speed of importance weight tracking        importance权重追踪的速度
                  'use_iw', false, ...                % use importance sampling                    使用importance抽样
                  'w_prior_mean',  0.5, ...           % synaptic weights prior                     突触权重的先验
                  'w_prior_sigma', 1.0, ...           % synaptic weights variance                  突触权重方差
                  'w_prior_N', 100, ...               % number of samples averaged over            平均样本数
                  'w_offs', 2, ...                    % weight offset (-log(alpha))                权重偏移(-log(alpha))
                  'theta_0', 3,  ...                  % synaptic parameter update                  突触参数更新
                  'w_rf', 0, ...                      % refractory amplitude                       不应期振幅
                  'w_r', -8, ...                      % depressing current                         抑制电流
                  'tau_r_r', 10, ...                  % rise time of depressing current            抑制电流的rise时间
                  'tau_r_f', 30, ...                  % fall time of depressing current            抑制电流的fall时间
                  'w_d_max', 5, ...                   % clip weight updates at this value*         在此值更新剪裁权重*
                  'sample_method', 'ctsp_lognormal', ...     % continuous time spiking structure plasticity  连续时间脉冲结构可塑性
                  'weight_prior_method', 'lognormal', ...    % weight prior method                           权重先验方法
                  args{:}                                    % 将args中的所有元素重构成一个列向量
                };
    % 删除的option——'free_run_time', 0.400, 

    %
    % *for numerical reasons (should never be a problem with sane parameters)
    % *出于数字原因(对于正常的参数来说，应该不成问题)
    % 
    
    
    if (exist('snn_options','file')==2) && isempty(snn_options( 'FileCache' ))  % 如果snn_options文件存在且snn_options中的FileCache为空
        snn_options( 'colors', [ 0.0, 0.0, 1.0; ...  % 设置颜色
                     0.0, 0.8, 0.0; ...
                     1.0, 0.4, 0.4; ...
                     0.8, 0.8, 0.0; ...
                     0.7, 0.7, 0.7; ...
                     0.8, 0.0, 0.8; ...
                     0.0, 0.6, 0.8; ...
                     0.8, 0.2, 0.2; ...
                     0.3, 0.6, 0.0; ...
                     0.4, 0.4, 0.4; ] );

        snn_options( 'FontName', 'Droid Sans' );  % 设置字体名字
        snn_options( 'FontSize', 8 );             % 设置字体大小
        snn_options( 'BasePath', base_path );     % 设置基础路径
        snn_options( 'FileCache', true );         % 设置文件缓存为ture
        snn_options( 'verbose', false );          % 设置为不输出日志信息
    end
end

