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
para_struct = struct('npcadiradd', 5, 'irecenter', 1);
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
eig_v_1 = meigvec(:,1);
pc1_minu2_data = vmean + eigv_1 .* pc1_minu2_stdev_score;
pc1_plus2_data = vmean + eigv_1 .* pc1_plus2_stdev_score;

% we should know which part is which in the data vector... 
% get this data and move forward.
s
