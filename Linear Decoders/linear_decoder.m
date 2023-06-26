clc; clear; close all;

% load the date
load('neuron_groups.mat'); % neuron groupings (Core, EP, LP, O neurons)
load('all_spikes.mat'); % neuronal spike data
load('trial_frames.mat'); % frame indices for trials
load('lever_force.mat'); % lever movement data

%% Linear decoders of Core, EP, LP, and O neurons
clc; close all; clearvars -except Core NP EP O all_spikes trial_frames lever_position 

rng('default');
test_size = 0.2;

rho_Core = [];
rho_NP = [];
rho_EP = [];
rho_O = [];

stage = [];

for mouse = [1 2 3 4 5 7]

    for session = 1:14
        
        if ~isempty(trial_frames{mouse,session})
    
            spikes = all_spikes{mouse,session};
            spikes(isnan(spikes)) = 0;
            spikes = movmean(spikes,5,2);
    
            trials = length(trial_frames{mouse,session});
            
            rand_idx = randperm(trials);
    
            test_idx = rand_idx(1:round(trials*test_size));
            train_idx = rand_idx(round(trials*test_size)+1:end);
    
            kk = 0;
            X = {};
            Y = [];
    
            for t = train_idx
    
                kk = kk +1;
                frames = trial_frames{mouse,session}{t};              
    
                X{kk} = spikes(:,frames);
    
                Y = [Y;lever_position{mouse,session}(frames)];
    
            end
       
            % Session decoder
            X_Core_all = [];
            X_NP_all = [];
            X_EP_all = [];
            X_O_all = [];
            k = 0;
            for t = train_idx
                k = k + 1;
    
                X_Core_all = [X_Core_all; X{k}(Core{mouse},:)'];
                X_NP_all = [X_NP_all; X{k}(NP{mouse},:)'];
                X_EP_all = [X_EP_all; X{k}(EP{mouse},:)'];
                X_O_all = [X_O_all; X{k}(O{mouse},:)'];
    
            end
    
            mdl_Core = fitlm(X_Core_all,Y);
            mdl_NP = fitlm(X_NP_all,Y);
            mdl_EP = fitlm(X_EP_all,Y);
            mdl_O = fitlm(X_O_all,Y);
    
            % Individual trial
            k = 0;
            for t = test_idx
                k = k+1;

                stage = [stage, session];
        
                frames = trial_frames{mouse,session}{test_idx(k)};
                
                y = lever_position{mouse,session}(frames);
    
                x = spikes(Core{mouse},frames);
                y_hat = predict(mdl_Core,x');
                rho_Core = [rho_Core; corr(y,y_hat)];
                
                x = spikes(NP{mouse},frames);
                y_hat = predict(mdl_NP,x');
                rho_NP = [rho_NP; corr(y,y_hat)];
                
                x = spikes(EP{mouse},frames);
                y_hat = predict(mdl_EP,x');
                rho_EP = [rho_EP; corr(y,y_hat)];
                
                x = spikes(O{mouse},frames);
                y_hat = predict(mdl_O,x');
                rho_O = [rho_O; corr(y,y_hat)];
            end
            
        end
        
    end

end

idx1 = ismember(stage,1:2); idx2 = ismember(stage,3:5); idx3 = ismember(stage,6:9); idx4 = ismember(stage,10:14);

%Figure 11a
figure
plot([mean(rho_Core(idx1)), mean(rho_Core(idx2)), mean(rho_Core(idx3)), mean(rho_Core(idx4))]); hold on;
plot([mean(rho_NP(idx1)), mean(rho_NP(idx2)), mean(rho_NP(idx3)), mean(rho_NP(idx4))]);
plot([mean(rho_EP(idx1)), mean(rho_EP(idx2)), mean(rho_EP(idx3)), mean(rho_EP(idx4))]);
plot([mean(rho_O(idx1)), mean(rho_O(idx2)), mean(rho_O(idx3)), mean(rho_O(idx4))]);

legend({'Core', 'NP', 'EP', 'O'}, 'Location','northwest'); ylabel('Movement correlation'); title 11a
xticks([1 2 3 4])
xticklabels({'1-2','3-5','6-9','10-14'})

%% Predicting movements in naive session using linear decoders from expert
clc; clearvars -except Core NP EP O all_spikes trial_frames lever_position 

rho_Core = [];
rho_EP = [];
rho_NP = [];
rho_O = [];

for mouse = [1 2 3 4 5 7]

    % Training
    kk = 0;
    
    X_Core = {}; X_EP = {}; X_NP = {}; X_O = {}; Y = [];
    
    for session = 10:14
        
        if ~isempty(trial_frames{mouse,session})
    
            spikes = all_spikes{mouse,session};
            spikes(isnan(spikes)) = 0;
            spikes = movmean(spikes,5,2);
    
            trials = length(trial_frames{mouse,session});
    
            for t = 1:trials
    
                kk = kk + 1;
                frames = trial_frames{mouse,session}{t};
                
                X_Core{kk} = spikes(Core{mouse},frames)';
                X_NP{kk} = spikes(NP{mouse},frames)';
                X_EP{kk} = spikes(EP{mouse},frames)';
                X_O{kk} = spikes(O{mouse},frames)';
    
                Y = [Y;lever_position{mouse,session}(frames)];
    
            end
    
        end
    end
    
    
    mdl_Core = fitlm(vertcat(X_Core{:}),Y);
    mdl_NP = fitlm(vertcat(X_NP{:}),Y);
    mdl_EP = fitlm(vertcat(X_EP{:}),Y);
    mdl_O = fitlm(vertcat(X_O{:}),Y);
    
    % Testing
    
    for session = 1:3
        spikes = all_spikes{mouse,session};
        spikes(isnan(spikes)) = 0;
        spikes = movmean(spikes,5,2);
        for t = 1:length(trial_frames{mouse,session})
    
            frames = trial_frames{mouse,session}{t};
            y = lever_position{mouse,session}(frames);
    
            x = spikes(Core{mouse},frames);
            y_hat = predict(mdl_Core,x');
            rho_Core = [rho_Core; corr(y,y_hat)];
    
            x = spikes(NP{mouse},frames);
            y_hat = predict(mdl_NP,x');
            rho_NP = [rho_NP; corr(y,y_hat)];
    
            x = spikes(EP{mouse},frames);
            y_hat = predict(mdl_EP,x');
            rho_EP = [rho_EP; corr(y,y_hat)];
    
            x = spikes(O{mouse},frames);
            y_hat = predict(mdl_O,x');
            rho_O = [rho_O; corr(y,y_hat)];

        end
    end

end

% Figure 11b
figure 
names = categorical({'Core','NP','EP','O'});
names = reordercats(names,{'Core','NP','EP','O'});
bar(names,[ mean(rho_Core), mean(rho_NP), mean(rho_EP), mean(rho_O)]); ylabel('Movement correlation'); title 11b;

