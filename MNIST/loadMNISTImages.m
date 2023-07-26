function images = loadMNISTImages(filename)
% 加载MNISTI图像返回一个包含原始MNIST图像的28x28x[MNIST映像数]矩阵。
% 
% 用法：
%  images = loadMNISTImages('D:\synaptic-sampling-code\MNIST\data_set\t10k-images.idx3-ubyte')
%  save('D:\synaptic-sampling-code\MNIST\data_set\test_set_images.mat','images')
% 

    fp = fopen(filename, 'rb');
    assert(fp ~= -1, ['Could not open ', filename, '']);
    
    magic = fread(fp, 1, 'int32', 0, 'ieee-be');
    assert(magic == 2051, ['Bad magic number in ', filename, '']);
    
    numImages = fread(fp, 1, 'int32', 0, 'ieee-be');
    numRows = fread(fp, 1, 'int32', 0, 'ieee-be');
    numCols = fread(fp, 1, 'int32', 0, 'ieee-be');
    
    images = fread(fp, inf, 'unsigned char');
    images = reshape(images, numCols, numRows, numImages);
    images = permute(images,[2 1 3]);
    
    fclose(fp);
    
    % Reshape to #pixels x #examples
    images = reshape(images, size(images, 1) * size(images, 2), size(images, 3));
    % 转换为双精度并重新缩放为[0,1]
    images = double(images) / 255;

end