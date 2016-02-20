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
scattering_modulations.nTemporal_modulations = 12;

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
[S1_bands, S2_bands] = invariant_scattering(waveform, archs, ...
    frequency_bands, sample_rate);