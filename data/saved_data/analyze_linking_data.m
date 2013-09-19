
% this function does PCA on a set of linking data
% data: each column vector is a curve
data = zeros(3664,40);
for i = 1:40
    file_name = strcat('data_vector/data_vector_' , int2str(i) , '.txt');
    x = load(file_name);
    data(:,i) = x;
end
para_struct = struct('npcadiradd', 5, 'irecenter', 0);
                     figure;
outstruct = scatplotSM(data,[],para_struct);
figure;
curvDatSM(data,para_struct)

