clc; clear; close all;
load('L5_connectome.mat');

%% 
clc; close all; clearvars -except connectome

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

all_edges = all_edges(:,any(all_edges)); % removing all the inactive edges (columns)
all_edges = all_edges(any(all_edges,2),:); % removing missing sessions (rows)

[coeff,score,latent,tsquared,explained] = pca(all_edges);

% For L2/3
xx = [1 -1 -1 1 1 1 -1]; % correcting PC1 direction
yy = [-1 -1 -1 -1 -1 1 1]; % correcting PC2 direction


% For L5
% xx = [1 1 1 1 -1 -1 -1 1]; % correcting PC1 direction
% yy = [-1 -1 -1 1 -1 -1 -1 -1]; % correcting PC2 direction
%% Plot
x = score(:,1)*xx(mouse); y = score(:,2)*yy(mouse);
scatter(x, y, 80, 1:length(x), 'filled');
hold on
plot(x, y,'k--'); colorbar;

xlabel(['PC1 (' num2str(round(explained(1),2)) '%)']);
ylabel(['PC2 (' num2str(round(explained(2),2)) '%)']);