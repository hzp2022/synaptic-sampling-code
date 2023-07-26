function session_path = run_experiment(varargin)  
% run_experiment.m
% 
% 使用具有变化的输入分布的突触采样来训练WTA电路。
%

%% init

run snn8.15/snn_include.m                                     % 将SNN工具箱路径添加到matlab路径中
snn_include( 'synaptic_sampling', 'plotting', 'mix_gauss','MNIST' );  % 将synaptic_sampling, plotting, plotting文件夹添加到SNN的搜索目录中（搜索目录是用来定位SNN方法的）
generate_target_data_set();  % 加载数据集到工作区（为保持类别均衡，将训练集进行分组，重新排列）

% 处理传递给run_expriment函数的参数（指定各个参数，对于未指定的参数将其设为默认参数，对于不使用的参数添加至default_params）
[ num_it_p1, ...      % 阶段1（网络暴露在SE）生成的模式（脉冲序列）个数
  num_it_p2, ...      % 阶段2（网络暴露在EE）生成的模式（脉冲序列）个数
  num_it_p3, ...      % 阶段3（来自SE(EE-SE条件)或EE(EE-EE条件)的样本又被展示）生成的模式（脉冲序列）个数
  save_interval, ...  % 2个保存文件之间的迭代次数
  num_dim, ...        % 数据空间的维度
  exp_mode, ...       % 感觉模式
  input_std, ...      % 输入的标准差
  groups, ...         % WTA电路
  default_params ] = snn_process_options( default_options(varargin{:}), ... 
                                          'num_it_p1', [], ...              
                                          'num_it_p2', [], ...               
                                          'num_it_p3', 0, ...                
                                          'save_interval', 10000, ...          
                                          'num_dim', 784, ...                  
                                          'exp_mode', 'costom', ...         
                                          'input_std', 0.1, ...              
                                          'num_neurons', 400 );               




pattern_length = 0.2;            % 模式时长0.2s即200ms（每个感觉体验都是由1000个输入神经元的200ms长的脉冲活动来模拟的）
                                      
h = 3600/pattern_length;         % 每个小时生成的模式个数

if strcmp(exp_mode,'ee-se')      % 如果感觉模式为ee-se
    num_it_p1 = 3.0*h;           % 阶段1生成的模式个数（网络暴露在标准环境3小时）
    num_it_p2 = 1.0*h;           % 阶段2生成的模式个数（网络暴露在丰富环境1小时）
    num_it_p3 = 5.0*h;           % 阶段3生成的模式个数（网络再次暴露在标准环境5小时）
elseif strcmp(exp_mode,'ee-ee')  % 如果感觉模式为ee-ee(√)
    num_it_p1 = 0*h;             % 阶段1生成的模式个数（网络暴露在标准环境3小时）
    num_it_p2 = 0.25*h;          % 阶段1生成的模式个数（网络暴露在丰富环境6小时）
    num_it_p3 = 0*h;             % 阶段3生成的模式个数（网络继续暴露在丰富环境0小时）
elseif isempty(num_it_p1) || isempty(num_it_p2)  % 如果阶段1和阶段2生成的模式个数为空
    error('costom time limits must be set');     % 抛出错误并显示消息：必须设置自定义时间限制
end
    
fprintf('running experimental setup mode: %s ...\n', exp_mode); % 打印:运行实验设置模式:ee-ee

snn_switch_session( 'exp-mix-gauss' ); % 将会话切换到实验结果的保存路径：D:\synaptic-sampling-code\results\exp-mix-gauss\2023-03-14-15-42-09\.


%% train the network

% 生成由给定长度速率模式组成的脉冲序列（初始化train_set_generator）
train_set_generator = generate_mnist_pattern_sequence_nd( 'init', ...                          
                                                              'pattern_length', pattern_length, ...  
                                                              'pattern_padding_length', 0.00, ...    
                                                              'pattern_rate', 80, ...                
                                                              'num_dim', num_dim, ...                
                                                              'input_std', input_std );


% 所有训练数据的标签id
% filename = 'D:\synaptic-sampling-code\MNIST\data_set\train-labels.idx1-ubyte';
% filename = 'MNIST\data_set\train-labels.idx1-ubyte';
% seq_id_schedule = loadMNISTLabels(filename)'+1;
seq_id_schedule = snn_load_data( 'MNIST\data_set\train_set_labels.mat' ).train_labels+1;

% 给train_set_generator添加字段（键—值）
train_set_generator.num_it_p1 = num_it_p1;              
train_set_generator.num_it_p2 = num_it_p2;              
train_set_generator.num_it_p3 = num_it_p3;              
train_set_generator.exp_mode = exp_mode;                
train_set_generator.seq_id_schedule = seq_id_schedule;  


% 模型学习
do_learning_task( default_params{:}, ...                             % 默认参数
                  'seq_ids', seq_id_schedule, ...                    % 所示bar patterns的角度
                  'num_neurons', sum(groups), ...                    % WTA神经元的数量
                  'save_interval', save_interval, ...                % 2个保存文件之间的迭代次数
                  'use_lateral_weights', false, ...                  % 关闭横向权重
                  'num_train_sets', length(seq_id_schedule), ...  % 训练集的数量
                  'num_inputs', train_set_generator.num_inputs, ...  % 输入神经元的数量
                  'train_set_generator', train_set_generator, ...    % 训练集生成器
                  'collect', {'Pt','Xt','Zt','At','R','T','seq_id','labels','Lt','time'} );        % 字段收集器field_collectors：一个元胞数组字符串，用于保存从net结构中收集的字段名称。

% eval_weight_hist;

% eval_turnover;                          

% plot_weight_evolution;                  

session_path = snn_get_session_path();  

end