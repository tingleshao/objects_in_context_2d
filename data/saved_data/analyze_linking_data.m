addpath('BatchAdjust', 'General', 'Smoothing');

% this function does PCA on a set of linking data
% data: each column vector is a curve
data = zeros(3664,40);
close all;
for i = 1:40
    file_name = strcat('data_vector/data_vector_' , int2str(i) , '.txt');
    x = load(file_name);
    data(:,i) = x;
end
color_mat = repmat([0,0,1],40,1);
% color pc1 "outlier" as red
color_mat(13,:) = [1,0,0];
% color pc2 "outlier" as green
color_mat(7,:) = [0,1,0];
para_struct = struct('npcadiradd', 5, 'irecenter', 1,'icolor', color_mat);
pca_para_struct = struct('npc', 5, 'irecenter', 1, 'viout', [1 1 1 0 1]);
figure;
outstruct = pcaSM(data,pca_para_struct);
scatplotSM(data,[],para_struct);
figure;
curvDatSM(data,para_struct)

mpc = outstruct.mpc; % this thing is in order of data vector
meigvec = outstruct.meigvec;
vmean = outstruct.vmean; 
% we can recover data with vmean + mpc(i) * eigenvector
% pc1 scores 
pc1 = mpc(1,:);
pc1_mean = mean(pc1);
pc1_stdev = std(pc1);

% get the score number of plus / minus 2 stdev
pc1_minu2_stdev_score = pc1_mean - 2 * pc1_stdev;
pc1_plus2_stdev_score = pc1_mean + 2 * pc1_stdev;

% get the data vector associated with theses two scores
eigv_1 = meigvec(:,1);
pc1_minu2_data = vmean + eigv_1 .* pc1_minu2_stdev_score;
pc1_plus2_data = vmean + eigv_1 .* pc1_plus2_stdev_score;

% the extended link length data is from 3108 to 3386 in the data vector
pc1_minu2_data_extend_link_len = pc1_minu2_data(3108:3386);
pc1_plus2_data_extend_link_len = pc1_plus2_data(3108:3386);

% asking how many has length < 0
pc1_minu2_data_num_length_less_than_zero = size(find(pc1_minu2_data_extend_link_len < 0),1);
pc1_plus2_data_num_length_less_than_zero = size(find(pc1_plus2_data_extend_link_len < 0),1);
disp(strcat('for u-2*stdev, # of entries < 0: ', num2str(pc1_minu2_data_num_length_less_than_zero)));
disp('they are:');
disp(find(pc1_minu2_data_extend_link_len < 0));
disp(strcat('for u+2*stdev, # of entries < 0: ', num2str(pc1_plus2_data_num_length_less_than_zero)));
disp('they are:');
disp(find(pc1_plus2_data_extend_link_len < 0));
% asking which spoke is the shortest:
pc1_minu2_small_len_index = find(min(pc1_minu2_data_extend_link_len)==pc1_minu2_data_extend_link_len);
pc1_plus2_small_len_index = find(min(pc1_plus2_data_extend_link_len)==pc1_plus2_data_extend_link_len);
disp(strcat('for u-2*stdev, index of shortest spoke: ', num2str(pc1_minu2_small_len_index)));
disp(strcat('for u+2*stdev, index of shortest spoke: ', num2str(pc1_plus2_small_len_index)));

% asking number of data points has projection score more than 2 stdev
num_of_data_greater_than_2_stdev = size(find(abs(pc1) > pc1_stdev * 2),1);
disp('index of data has pc1 score > 2 stdev:');
disp(find(abs(pc1) > pc1_stdev * 2));
% asking how many of them has at least one negative spoke length
recovered_data = zeros(3664,40);
for i = 1:40,
    recovered_data(:,i) = vmean + pc1(i) .* eigv_1;
end
recovered_extended_spoke_length = recovered_data(3109:3386,:); 
count = 0;
for i = 1:40,
 if find(recovered_extended_spoke_length(:,i) < 0)
     count = count +1;
 end
end

disp(strcat('# of data has at least 1 spoke len < 0: ',num2str(count)));

% asking the data index that has the largest score on pc 2
% and compute how many spokes on that projection on pc2 are negative
pc2 = mpc(2,:);
pc2_max_index = find(pc2==max(pc2));
% project it on pc2 dir 
eigv2 = meigvec(:,2);
proj_on_pc2 = vmean + max(pc2) * eigv2;
% count how many are smaller than 0;
proj_on_pc2_extended_spokes_len = proj_on_pc2(3109:3386,:);
num_of_less_than_zero = size(find(proj_on_pc2_extended_spokes_len < 0),1);
disp(strcat('# of extended spoke len < 0 that proj on pc2: ',num2str(num_of_less_than_zero)));

