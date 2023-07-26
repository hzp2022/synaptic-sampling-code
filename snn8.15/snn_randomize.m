function snn_randomize()
%
% init random seeds  初始化随机种子
%
% David Kappel
% 18.12.2014
%

    rand_seed = snn_options( 'RandSeed' );
    randn_seed = snn_options( 'RandNSeed' );
    
    if isempty(rand_seed)
        rand_seed = 100*sum(clock);
    end

    if isempty(randn_seed)
        randn_seed = 100*sum(clock);
    end
    
    snn_options( 'RandSeedInit', rand_seed );
    snn_options( 'RandNSeedInit', randn_seed );
    
    rand('seed',rand_seed);
    randn('seed',randn_seed);
end
