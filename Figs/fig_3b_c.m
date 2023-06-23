clc; clear; close all;
load('L5_connectome.mat');

%% 
clc; close all; clearvars -except connectome

top = 100; % number of top edges
mouse = 1;

neurons = size(connectome{mouse,1},1);

all_edges = zeros(size(connectome,2),neurons*(neurons-1)/2); % rows are sessions, columns are all possible edges

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

inactive_edge_idx = find(all(all_edges==0));
all_edges = all_edges(:,any(all_edges)); % removing all the inactive edges (columns)
all_edges = all_edges(any(all_edges,2),:); % removing missing session (rows)

[coeff,score,latent,tsquared,explained] = pca(all_edges);

% For L2/3
% xx = [1 -1 -1 1 1 1 -1]; % correcting PC1 direction
% yy = [-1 -1 -1 -1 -1 1 1]; % correcting PC2 direction


% For L5
xx = [1 1 1 1 -1 -1 -1 1]; % correcting PC1 direction
yy = [-1 -1 -1 1 -1 -1 -1 -1]; % correcting PC2 direction

coeff(:,1) = coeff(:,1).*xx(mouse);
coeff(:,2) = coeff(:,2).*yy(mouse);

x = score(:,1)*xx(mouse); y = score(:,2)*yy(mouse);

%% Top PCs

PC1_all = [coeff(:,1), (1:size(coeff,1))'];
PC2_all = [coeff(:,2), (1:size(coeff,1))'];

PC1_all = sortrows(PC1_all,1,'descend');
PC2_all = sortrows(PC2_all,1,'descend');

pc1_pos = PC1_all(1:top,2);
pc1_neg = PC1_all(end-top+1:end,2);

pc2_pos = PC2_all(1:top,2);
pc2_neg = PC2_all(end-top+1:end,2);

subplot(221); %stdshade(all_edges(:,PC1_all(pc1_pos,2))',0.25,'g');
plot(mean(all_edges(:,pc1_pos),2),'LineWidth',2);
xlabel('Sessions'); ylabel('Partial Correlation');
% title(['Top Edges with Positive Loading - PC1 (n = ' num2str(length(pc1_pos)) ')']);
title('Top Edges with Positive Loading - PC1')
hold on;

subplot(222); %stdshade(all_edges(:,PC1_all(pc1_neg,2))',0.25,'r');
plot(mean(all_edges(:,pc1_neg),2),'LineWidth',2);
xlabel('Sessions'); ylabel('Partial Correlation');
% title(['Top Edges with Negative Loading - PC1 (n = ' num2str(length(pc1_neg)) ')']);
title('Top Edges with Negative Loading - PC1')
hold on;

subplot(223); %stdshade(all_edges(:,PC2_all(pc2_pos,2))',0.25,'g');
plot(mean(all_edges(:,pc2_pos),2),'LineWidth',2);
xlabel('Sessions'); ylabel('Partial Correlation');
% title(['Top Edges with Positive Loading - PC2 (n = ' num2str(length(pc2_pos)) ')']);
title('Top Edges with Positive Loading - PC2')
hold on;

subplot(224); %stdshade(all_edges(:,PC2_all(pc2_neg,2))',0.25,'r');
plot(mean(all_edges(:,pc2_neg),2),'LineWidth',2);
xlabel('Sessions'); ylabel('Partial Correlation');
% title(['Top Edges with Negative Loading - PC2 (n = ' num2str(length(pc2_neg)) ')']);
title('Top Edges with Negative Loading - PC2');