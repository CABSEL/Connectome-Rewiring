clc; clear; close all;

% load the date
load('neuron_group.mat');
all_spikes = load('all_spikes.mat');
all_spikes = all_spikes.th_pyr_spikes;
trial_frames = load('frames_84_bout.mat');
trial_frames = trial_frames.all_movement_bouts_frames;
lever_position = load('lever_force.mat');

rho_Core = [];
rho_EP = [];
rho_NP = [];
rho_O = [];

mouse = 1;

%% Training
kk = 0;

X_Core = {}; X_EP = {}; X_NP = {}; X_O = {}; Y = [];

for session = 10:14
    
    if ~isempty(trial_frames{mouse,session})

        spikes = all_spikes{mouse,session};
        spikes(isnan(spikes)) = 0;
        spikes = movmean(spikes,5,2);

        trials = length(trial_frames{mouse,session});

        for t = 1:trials

            kk = kk +1;
            frames = trial_frames{mouse,session}{t};
            
            X_all{kk} = spikes(:,frames)';
            X_Core{kk} = spikes(Core,frames)';
            X_NP{kk} = spikes(NP,frames)';
            X_EP{kk} = spikes(EP,frames)';
            X_O{kk} = spikes(O,frames)';

            Y = [Y;lever_position{mouse,session}(frames)];

        end

    end
end

mdl_Core = fitlm(vertcat(X_Core{:}),Y);
mdl_NP = fitlm(vertcat(X_NP{:}),Y);
mdl_EP = fitlm(vertcat(X_EP{:}),Y);
mdl_O = fitlm(vertcat(X_O{:}),Y);

%% Testing

for session = 14:14
    spikes = all_spikes{mouse,session};
    spikes(isnan(spikes)) = 0;
    spikes = movmean(spikes,5,2);
    for t = 1:length(trial_frames{mouse,session})

        frames = trial_frames{mouse,session}{t};
        y = lever_force_resample{mouse,session}(frames);

        x = spikes(Core,frames);
        y_hat = predict(mdl_Core,x');
        rho_Core = [rho_Core; corr(y,y_hat)];

        x = spikes(NP,frames);
        y_hat = predict(mdl_NP,x');
        rho_NP = [rho_NP; corr(y,y_hat)];

        x = spikes(EP,frames);
        y_hat = predict(mdl_EP,x');
        rho_EP = [rho_EP; corr(y,y_hat)];

        x = spikes(O,frames);
        y_hat = predict(mdl_O,x');
        rho_O = [rho_O; corr(y,y_hat)];
    end
end