function generate_target_data_set()
% 为保持类别均衡，将训练集进行分组，重新排列。
    
%% 训练集的处理
    train_labels_0 = loadMNISTLabels('MNIST\data_set\train-labels.idx1-ubyte');
    num_per_label = 5000;  % 训练集共6w个，这里考虑类别均衡问题，只考虑5w个样本（每个标签的样本各5000个）
    train_labels = repmat(0:9, 1, num_per_label);
    indices = zeros(1, num_per_label*10);
    
    j = 1;
    for i = 1:numel(train_labels)
        target = train_labels(i);
        locs = find(train_labels_0 == target);
        target_loc = locs(mod(j-1, numel(locs))+1);  % 找到target在 train_labels_0 中第 j 次出现的位置
        indices(i) = target_loc;
        if mod(i,10) == 0
            j = j+1;
        end
    end
    save('MNIST\data_set\train_set_labels.mat','train_labels');

    train_images = loadMNISTImages('MNIST\data_set\train-images.idx3-ubyte');
%     train_images = repmat(train_images(:, indices),1,2); % 按照idx对image进行排序
    train_images = train_images(:, indices); % 按照idx对image进行排序
    save('MNIST\data_set\train_set_images.mat','train_images');

%% 测试集的处理
    test_labels = loadMNISTLabels('MNIST\data_set\t10k-labels.idx1-ubyte');
    save('MNIST\data_set\test_set_labels.mat','test_labels');
    test_images = loadMNISTImages('MNIST\data_set\t10k-images.idx3-ubyte');
    save('MNIST\data_set\test_set_images.mat','test_images');   
end