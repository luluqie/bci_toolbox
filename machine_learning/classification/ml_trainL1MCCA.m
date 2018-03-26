function [model] = ml_trainL1MCCA(features, alg, cv)
%ML_TRAINL1MCCA Summary of this function goes here
%   Detailed explanation goes here


% created 03-21-2016
% last modification -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>
[samples,~,epochs] = size(features.signal);
stimuli_count = length(features.stimuli_frequencies);
reference_signals = cell(1, stimuli_count);
epochs_per_stimuli = round(epochs / stimuli_count);
iniw3 = ones(epochs_per_stimuli,1);
w1 = cell(stimuli_count);
w3 = cell(stimuli_count);
op_refer = cell(stimuli_count, 1);
stimuli_count = max(features.events);
eeg = permute(features.signal, [2 1 3]);

if (cv.nfolds == 0)
    %     learn projections
    for stimulus=1:stimuli_count
        reference_signals{stimulus} = refsig(features.stimuli_frequencies(stimulus),...
            features.fs, samples, ...
            alg.options.harmonics);
        [w1{stimulus}, w3{stimulus}] = smcca(reference_signals{stimulus}, ...
            eeg(:,:,features.events==stimulus), alg.options.max_iter, iniw3,...
            alg.options.n_comp, ...
            alg.options.lambda);
        op_refer{stimulus} = ttm(tensor(eeg(:,:,features.events==stimulus)), w3{stimulus}', 3);
        op_refer{stimulus} = tenmat(op_refer{stimulus}, 1);
        op_refer{stimulus} = op_refer{stimulus}.data;
        op_refer{stimulus} = w1{stimulus}'*op_refer{stimulus};       
    end
else
    %     TODO
    % folds = ml_crossValidation(cv, epochs);
end
model.alg.learner = 'L1MCCA';
model.ref = op_refer;
end
