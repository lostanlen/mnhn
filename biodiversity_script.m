%% params in script
band_freqs = ...
    [125 250 ; ...
    200 500 ; ...
    400 1000 ; ...
    800 2000 ; ...
    1600 4000 ; ...
    3200 8000 ; ...
    7200 16000].';
sample_rate = 44100;
nFilters_per_octave = 12;
ROI_duration = 0.5; % in seconds
clear scattering_modulations;
scattering_modulations.nTemporal_modulations = 8;

archs = setup( ...
    nFilters_per_octave, ...
    ROI_duration, ...
    sample_rate, ...
    scattering_modulations);


%% load (in script)
waveform_path = '~/MATLAB/mnhn/test_sound_tropicalforest.wav';
[waveform, sample_rate] = audioread_compat(waveform_path);

% take left channel
waveform = waveform(:, 1);

% chunk
audio_chunks = chunk(waveform, archs);

%%
[S, U] = sc_propagate(audio_chunks, archs);

%% get gamma bands
band_gammas = get_band_gammas(archs, band_freqs, sample_rate);

%% Plain case
% unchunk S1
gamma_subscript = ndims(S{1+1}.data);
if gamma_subscript == 3
    S1 = S{1+1}.data;
    S1 = S1((1+end/4):(3*end/4), :, :);
    S1 = reshape(S1, size(S1, 1) * size(S1, 2), size(S1, 3));
    S{1+1}.data = S1;
end

% unchunk S2
if gamma_subscript == 3
    for gamma2_index = 1:length(S{1+2}.data)
        S2_node = S{1+2}.data{gamma2_index};
        S2_node = S2_node((1+end/4):(3*end/4), :, :);
        S2_node = reshape(S2_node, ...
            size(S2_node, 1) * size(S2_node, 2), size(S2_node, 3));
        S{1+2}.data{gamma2_index} = S2_node;
    end
end

%%
nBands = length(band_gammas);
S1_bands = cell(1, nBands);
S2_bands = cell(1, nBands);

for band_index = 1:nBands
    gamma_start = band_gammas(1, band_index);
    gamma_stop = band_gammas(2, band_index);
    % S1 band
    S1_bands{band_index} = S{1+1}.data(:, gamma_start:gamma_stop);
    % S2 band
    nGamma2s = length(S{1+2}.data);
    S2_bands{band_index} = cell(1, nGamma2s);
    for gamma2_index = 1:length(S{1+2}.data)
        gamma_range = S{1+2}.ranges{1+0}{gamma2_index}(:, gamma_subscript);
        assert(gamma_range(1)==1);
        S2_band = S{1+2}.data{gamma2_index}(:, ...
            gamma_start:min(gamma_stop, end));
        if ~isempty(S2_band)
            S2_bands{band_index}{gamma2_index} = sum(S2_band, 2);
        end
    end
    S2_bands{band_index} = [S2_bands{band_index}{:}];
end

%% Concatenate S1 bands and S2 bands
S_bands = cell(1, nBands);
for band_index = 1:nBands
    S_bands{band_index} = cat(2, S1_bands{band_index}, S2_bands{band_index});
end