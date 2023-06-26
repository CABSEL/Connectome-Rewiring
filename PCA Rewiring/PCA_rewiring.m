clc; clear; close all;

% Load functional connectomes
% Functional connectomes were computed using FARCI 
% http://www.github.com/cabsel/FARCI
load('./L5_connectome.mat');

%% PCA of Connectome Rewiring
% Set mouse index
mouse = 1;

% Initialize feature vector
neurons = size(connectome{mouse,1},1);
all_edges = zeros(size(connectome,2),neurons*(neurons-1)/2); % rows are sessions, columns are all possible edges

% Prepare connectome feature vector
for session = 1:size(connectome,2)

    adj = connectome{mouse,session};
    if ~isempty(adj)

        adj(isnan(adj)) = 0;
        adj(adj==0) = eps;
        adj = triu(adj,1);  
        idx = adj ~= 0;
        adj = adj(idx);
        adj(adj==eps) = 0;

        all_edges(session,:) = adj';

    end
end

all_edges = all_edges(:,any(all_edges)); % removing all the inactive edges (columns)
all_edges = all_edges(any(all_edges,2),:); % removing missing sessions (rows)


% PCA of Functional Connectomes
[coeff,score,latent,tsquared,explained] = pca(all_edges);

% Rotation of PC axes for L2/3
%xx = [1 -1 -1 1 1 1 -1]; 
%yy = [-1 -1 -1 -1 -1 1 1]; 

% Rotation of PC axes for L2/3
xx = [1 1 1 1 -1 -1 -1 1]; 
yy = [-1 -1 -1 1 -1 -1 -1 -1]; 

% PCA plot
x = score(:,1)*xx(mouse); y = score(:,2)*yy(mouse); %rotation
figure
scatter(x, y, 80, 1:length(x), 'filled');
plot(x, y,'k--'); colorbar;

xlabel(['PC1 (' num2str(round(explained(1),2)) '%)']);
ylabel(['PC2 (' num2str(round(explained(2),2)) '%)']);

%% Analysis of Learning Trajectories
top = 100; % set the number of top edges (highest PCA loadings)

PC1_all = [coeff(:,1), (1:size(coeff,1))'];
PC2_all = [coeff(:,2), (1:size(coeff,1))'];

PC1_all = sortrows(PC1_all,1,'descend');
PC2_all = sortrows(PC2_all,1,'descend');

pc1_pos = PC1_all(1:top,2);
pc1_neg = PC1_all(end-top+1:end,2);

pc2_pos = PC2_all(1:top,2);
pc2_neg = PC2_all(end-top+1:end,2);

figure
hold on

subplot(221); 
plot(mean(all_edges(:,pc1_pos),2),'LineWidth',2);
xlabel('Sessions'); ylabel('Partial Correlation');
title('Top Edges with Positive Loading - PC1')

subplot(222); 
plot(mean(all_edges(:,pc1_neg),2),'LineWidth',2);
xlabel('Sessions'); ylabel('Partial Correlation');
title('Top Edges with Negative Loading - PC1')

subplot(223); 
plot(mean(all_edges(:,pc2_pos),2),'LineWidth',2);
xlabel('Sessions'); ylabel('Partial Correlation');
title('Top Edges with Positive Loading - PC2')

subplot(224); 
plot(mean(all_edges(:,pc2_neg),2),'LineWidth',2);
xlabel('Sessions'); ylabel('Partial Correlation');
title('Top Edges with Negative Loading - PC2');