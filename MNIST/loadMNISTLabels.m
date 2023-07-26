function labels = loadMNISTLabels(filename)
% load MNIST Labels返回一个[number of MNIST images]x1矩阵，该矩阵包含MNIST图像的标签。
% 
% 用法：
%   labels = loadMNISTLabels('D:\synaptic-sampling-code\MNIST\data_set\t10k-labels.idx1-ubyte')
%   save('D:\synaptic-sampling-code\MNIST\data_set\test_set_labels.mat','labels')
% 

fp = fopen(filename, 'rb');
assert(fp ~= -1, ['Could not open ', filename, '']);

magic = fread(fp, 1, 'int32', 0, 'ieee-be');
assert(magic == 2049, ['Bad magic number in ', filename, '']);

numLabels = fread(fp, 1, 'int32', 0, 'ieee-be');

labels = fread(fp, inf, 'unsigned char');

assert(size(labels,1) == numLabels, 'Mismatch in label count');

fclose(fp);

end