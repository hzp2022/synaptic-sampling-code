% main.m
%
% This setting realizes experiment 4 of:
%   D. Kappel, S. Habenschuss, R. Legenstein and W. Maass.
%   Network Plasticity as Bayesian Inference. PLOS Computational
%   Biology, 2015.
% 这个设置实现了论文中的实验4
%
%
% Institute for Theoretical Computer Science
% Graz University of Technology
%
% 31.08.2015
% David Kappel
% http://www.igi.tugraz.at/kappel/
%
%

% train a network EE-EE condition
ee_ee_path = run_experiment('exp_mode','ee-ee','input_std',0.3);

% train a network EE-SE condition   
% ee_se_path = run_experiment('exp_mode','ee-se','input_std',0.3);    

% evaluate the experimental results and plot them   
% eval_experiment(ee_ee_path, ee_se_path);
