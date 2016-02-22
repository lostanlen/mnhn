% NB: Before running this script, the scattering.m toolbox must be in the path.
% To do so:
% system('git clone https://github.com/lostanlen/scattering.m');
% addpath(genpath('scattering.m'));

%% Parameters
% left and right cutoff of each frequency band, in Hertz
frequency_bands = ...
    [125 250 ; ...
    200 500 ; ...
    400 1000 ; ...
    800 2000 ; ...
    1600 4000 ; ...
    3200 8000 ; ...
    7200 16000].';

% sampling rate, in Hertz
sample_rate = 44100;

% number of filters per octave: an integer typically between 4 and 16.
nFilters_per_octave = 8;

% number of octaves.
% At a sampling rate of 44100 Hz, the lowest frequency of the wavelet scalogram
% is given by the formula:
% 22050 / 2^nOctaves
% That is 83 Hz for 8 octaves.
nOctaves = 8;

% duration of the region of interest (ROI), in seconds
ROI_duration = 1.0;

% for the scattering transform:
clear scattering_modulations;
% nTemporal_modulations (integer) is the base-2 logarithm of the
% maximal scattering time scale.
% 15 means that the modulation scales go up to 2 * 2^15 = 65k coefficients,
% that is 1.5 second approximately. This is the maximal value for a ROI
% duration of 1 second.
% Reducing this number would provide less scattering coefficients and a faster
% transform.
scattering_modulations.nTemporal_modulations = 15;

% nSpectral_modulations (integer) is the base-2 logarithm of the
% maximal scattering scale along neighboring log-frequencies.
% 3 means that the modulation scales go up to 2 * 2^3 = 16 log-frequencies,
% that is 2 octaves if nFilters_per_octaves == 8.
% Reducing this number would provide less joint scattering coefficients and
% a faster transform. On the contrary, increasing it would provide more
% coefficients and a slower transform.
% IMPORTANT: to replace joint time-frequency scattering by "plain" time-only
% scattering, just comment out the line below.
scattering_modulations.nSpectral_modulations = 3;

%% Setup
% The function below sets up wavelets for the scattering transform
archs = setup( ...
    nFilters_per_octave, ...
    nOctaves, ...
    ROI_duration, ...
    sample_rate, ...
    scattering_modulations);

%% Extraction and conversion to mono
waveform_path = 'test_sound_tropicalforest.wav';
[waveform, sample_rate] = audioread_compat(waveform_path);

% The scattering transform works on monophonic signals
% Therefore, stereophonic signals must be split ? or converted to mono ?
% before running the transform.
% Here, we take the half-sum of left and right channels.
waveform = 0.5 * (waveform(:, 1) + waveform(:, 2));

%% Scattering transform
% Plain scattering is 3x real-time on a single core
% Joint scattering is 0.2x real-time on a single core
tic();
[S1_bands, S2_bands] = invariant_scattering(waveform, archs, ...
    frequency_bands, sample_rate);
toc();

%% Concatenation of first- and second-order coefficients
S_bands = cell(1, length(S1_bands));
for band_index = 1:length(S1_bands)
    S_bands{band_index} = cat(1, S1_bands{band_index}, S2_bands{band_index});
end