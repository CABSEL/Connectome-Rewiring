clc; clear; close all;

% Specify mouse (L23: Layer 2/3, L5: Layer 5 of M1)
mouse = 'L23-7';
edge_activity = readtable("rewarded_trials.xlsx",'Sheet',['Mouse ', mouse]);

%% Create surface plot of cue-to-reward times over PC1 + PC2
clc; close all;
PC1 = edge_activity.PC1;
PC2 = edge_activity.PC2;
T = edge_activity.Time;
Session = edge_activity.Session;

S = createFit(PC1, PC2, T);
figure;
h1 = plot(S);
xlabel('PC1','FontSize',16);
ylabel('PC2','FontSize',16);
zlabel ('Cue to Reward Time (sec)', 'FontSize',16);
zlim([0 4]);
grid on
view( 134.0, 21.3 );

hold on 
zData = feval(S,[PC1,PC2]);
h2 = scatter3(PC1,PC2,zData,40,Session,'filled');
uistack(h2,'top')
alpha(h1,0.5)
set(h1,'FaceColor','k')
title(['Mouse ',num2str(mouse)],'FontSize',18)
view( -130, 25 );

%% Surface curve fitting 
function [fitresult, gof] = createFit(x, y, T)
[xData, yData, zData] = prepareSurfaceData( x, y, T );

% Set up fittype and options.
ft = fittype( 'lowess' );
opts = fitoptions( 'Method', 'LowessFit' );
opts.Robust = 'LAR';
opts.Span = 0.3;

% Fit model to data.
[fitresult, gof] = fit( [xData, yData], zData, ft, opts );

end
