%% params in script
frequency_bands = ...
    [125 250 ; ...
    200 500 ; ...
    400 1000 ; ...
    800 2000 ; ...
    1600 4000 ; ...
    3200 8000 ; ...
    7200 16000].';
sample_rate = 44100;
nFilters_per_octave = 12;
ROI_duration = 1.0; % in seconds
clear scattering_modulations;
scattering_modulations.nTemporal_modulations = 10;
scattering_modulations.nSpectral_modulations = 3;

archs = setup( ...
    nFilters_per_octave, ...
    ROI_duration, ...
    sample_rate, ...
    scattering_modulations);

%% load (in script)
waveform_path = 'test_sound_tropicalforest.wav';
[waveform, sample_rate] = audioread_compat(waveform_path);

% take left channel
waveform = waveform(:, 1);

%%
% Plain scattering is 3x real-time on a single core
% Joint scattering is 0.2x real-time on a single core
tic();
[S1_bands, S2_bands] = invariant_scattering(waveform, archs, ...
    frequency_bands, sample_rate);
toc();

%% Concatenation
S_bands = cell(1, length(S1_bands));
for band_index = 1:length(S1_bands)
    S_bands{band_index} = cat(2, S1_bands{band_index}, S2_bands{band_index}).';
end