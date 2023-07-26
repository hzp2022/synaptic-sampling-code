function [net, performance, train_set] = snn_train( net, train_data, test_set, varargin )
% snn_train: train the network with given train and test data  用给定的训练数据和测试数据训练网络
%
% [net, performance, train_set] = snn_train( net, train_data, test_data, ... )
% [net, performance, train_set] = snn_train( net, data )
%
% Trains a SNN network with given data.  用给定的数据训练一个SNN网络。
%
% input
%   net:              A SNN network or an integer number.  一个SNN网络或一个整数。
%                     If a number is passed a net is created with
%                     the given number of neurons.  如果通过一个数字，就会创建一个具有给定数量神经元的网络。
%                     See <a href="matlab:help snn_new">snn_new</a>.
%   train_data:       Training data or file pattern to load data.  训练数据或文件模式来加载数据。
%   test_data:        Test data or file pattern to load data.  测试数据或文件模式来加载数据。
%   data:             A string pointing to a directory containing
%                     train and test data.  一个字符串，指向包含训练和测试数据的目录。
%
% optional arguments
%   num_runs:         number of training runs through data set
%                     default is 1.  通过数据集进行训练的次数，默认为1。
%   step_size:        Number of samples that are trained before
%                     the performance is recalculated.  在重新计算性能之前，训练的样本数量。
%   figure:           figure to plot performance to. Doesn't plot
%                     anything if 0 is passed.  绘制性能的figure。如果传递0则不会绘制任何东西。
%   keep_data_order:  If false the training data is trained in random
%                     permutation (default), else the order is kept.
%                     如果是false，训练数据将以随机排列的方式进行训练（默认），否则将保持原有顺序。
%   auto_restore:     If an error occures during training the previous
%                     parameters are restored (default), else training
%                     continues without changes and the performance at
%                     current iteration is set to 'NAN'.
%                     true by default.
%                     如果在训练过程中发生错误，则恢复之前的参数（默认），
%                     否则继续训练，不做任何改变，当前迭代的性能被设置为'NAN'。
%                     默认情况下为true。
%   plot_rule:        Plot rule string for plotting data produced while
%                     training. See  snn_plot().
%                     用于绘制训练时产生的数据的绘图规则字符串。参见snn_plot()。
%   lead_in:          Number of samples that will be copied from previous
%                     train set.  
%                     将从以前的训练集中复制的样本数。
%   collect:          A string containing a list of fields that should
%                     be collected from the network structure.
%                     一个包含应从网络结构中收集的字段列表的字符串。
%                     The fields are collected after each block that was
%                     processed and stored in the data_out structure.
%                     这些字段在每个被处理的块之后被收集，并存储在data_out结构中。
%                     The string must have the format:  
%                     该字符串必须具有以下格式：
%                     '[<field1>,<field2>,...,<fieldN>]'
%   [net parameters]: If 'net' is given by an interger number additional
%                     parameters may be given that are passed on to
%                     <a href="matlab:help snn_new">snn_new</a>.
%                     如果'net'是由一个整数给定的，可以给定额外的参数，并传递给
%                     <a href="matlab:help snn_new">snn_new</a>。
%
% output
%   net:              The trained network.  训练好的网络
%   performance:      A matrix containing the performance information
%                     for each timestep.  一个包含每个时间段的性能信息的矩阵。
%   train_set:        The network training data sets.  网络训练数据集。
%
% see also
%   <a href="matlab:help snn_new">snn_new</a>
%   <a href="matlab:help snn_load_data">snn_load_data</a>
%
% David Kappel 14.08.2010
%

%% init

    if (nargin<2)
        error('Not enought input arguments!');
    end

    if ~isstruct( net ) &&  ~isnumeric( net )
        error('Unexpected argument type for ''net''!');
    end

    if (nargin<3)
        if ischar(train_data)
            test_set = fullfile( train_data, 'test*.mat' );
            train_data = fullfile( train_data, 'train*.mat' );
        else
            if ~isstruct( train_data )
                error('Unexpected argument type for ''train_data''!');
            end
           
            test_set = [];
        end
    end
    
    [ train_step_size, ...
      test_step_size, ...
      fig, ...
      num_runs, ...
      keep_data_order, ...
      auto_restore, ...
      plot_rule, ...
      lead_in, ...
      collect, ...
      varargin ] = ...
        snn_process_options( varargin, ...
                             'train_step_size', 1000, ...
                             'test_step_size', inf, ...
                             'figure', [], ...
                             'num_runs', 1, ...
                             'keep_data_order', false, ...
                             'auto_restore', true, ...
                             'plot_rule', '', ...
                             'lead_in', 0, ...
                             'collect', '' );
                         
    verbose = snn_options( 'verbose' );
    
    if isempty( verbose )
        verbose = true;
    end
        
    if ischar(test_set)
        if (verbose)
            disp('loading test-set:');
        end
        test_set = snn_load_data( test_set );
    end

    performance = [];
    
    stop_button = [];
    text_box = [];
    
    test_collectors = {};
    train_collectors = {};
    
    if ~isempty(collect)
        if ~isempty( test_set )
            test_collectors = snn_parse_args(collect);
        else
            train_collectors = snn_parse_args(collect);
        end
    end

%% train network
    if (verbose)
        disp('training network:');
    end
    
    if isempty( fig )
        fig = figure;
    end

    if (nargout>2)
        [net, train_set] = snn_process_data( net, @(net,data,ct)train_network(net,data,ct), ...
                                             train_data, train_step_size, num_runs, ...
                                             keep_data_order, lead_in, train_collectors );
    else
        net = snn_process_data( net, @(net,data,ct)train_network(net,data,ct), ...
                                train_data, train_step_size, num_runs, ...
                                keep_data_order, lead_in, train_collectors );
    end
    
    delete( stop_button );
    delete( text_box );
    
    drawnow;
    
    if (verbose)
        fprintf('\n')
    end

    
%% local functions    
    
    function make_gui( out_text )
    % Set up the GUI environment.  设置GUI环境。

        if isempty( stop_button )
            stop_button = uicontrol( 'Style', 'togglebutton', ...
                                     'String', 'stop',...
                                     'Position', [15 15 55 25] );

            text_box = uicontrol( 'Style', 'Text', ...
                                  'HorizontalAlignment', 'Left', ...
                                  'FontSize', 10, ...
                                  'BackgroundColor', get(fig,'Color'), ...
                                  'Position', [80 15 500 15]);
        end

        set( text_box, 'String', out_text );
    end


    function [net,Z,P] = train_network( net, data, ct )
    % Train the network  训练网络

        if isnumeric(net)
            net = snn_new( net, size(data.X,1), varargin{:} );            
        end
    
        out_text = sprintf( '  %02.0f:%02.0f.%03.0f  iteration: %u', ...
                            floor(net.train_time/60), floor(mod(net.train_time+eps,60)), ...
                            floor(mod(1000*net.train_time,1000)), net.iteration );

        net_tmp = net;

        [ net, Z, P ] = net.p_train_fcn( net, data, ct );

        if isfield( data, 'time' )
            net.train_time = net.train_time + ...
                             data.time(ct(end)) - ...
                             data.time(ct(1));
        else
            net.train_time = net.train_time + ...
                             data.time_range(end) - ...
                             data.time_range(1);
        end

        if ~isempty( test_set )

            sim_net = snn_alloc( net, net.p_sample_allocators, true );
            
            [sim_net, test_set_result] = snn_process_data( sim_net, net.p_sample_fcn, ...
                                                           test_set, test_step_size, 1, ...
                                                           true, lead_in, test_collectors );
                                     
            perf = snn_performance( sim_net, test_set_result );

            if isnan(perf) && auto_restore
                it = net.iteration;
                net = net_tmp;
                net.iteration = it;
                if (verbose)
                    disp('  training error - restoring previous parameters!');
                end
                if ( numel(performance)>0 )
                    perf = performance(1,end);
                end
            end

            performance = [ performance, [perf;net.iteration] ];

            out_text = strcat( out_text, sprintf( '  performance is: %f',  perf(1) ) );

            if ( fig > 0 )

                fig = snn_plot( test_set_result(1), [ plot_rule, '_' ], ...
                                'figure', fig, varargin{:} );

                make_gui( out_text );

                plot(performance(2,:), performance(1,:), '-b');
                title( 'training network' );
                xlabel('iteration');
                ylabel('performance');

                drawnow;
            end
        else
            if ~isempty( plot_rule ) && ( fig > 0 )

                fig = snn_plot( data, plot_rule, 'figure', fig, varargin{:} );                        
                make_gui( out_text );
                
                drawnow;
            end
        end

        if (verbose)
            disp( out_text );
        end

        if ~isempty( stop_button ) && get( stop_button, 'Value' )
            
            net.p_user_interupt = true;
            if (verbose)
                disp( 'User interrupt...' );
            end
        end
    end
end
