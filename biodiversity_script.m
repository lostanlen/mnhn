%% params in script
hertz_bands = ...
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
scattering_modulations.nTemporal_modulations = 14;

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

%% chunk
audio_chunks = chunk(waveform, archs);

%%
[S, U] = sc_propagate(audio_chunks, archs);

%% get gamma bands
gamma_min = min(gamma_bands(:));
gamma_max = max(gamma_bands(:));
archs{1}.banks{1}.behavior.gamma_bounds = [gamma_min gamma_max];
[band_refs, gamma_bands] = get_band_refs(archs, hertz_bands, sample_rate);

%% First-order coefficients
S1 = S{1+1};
%% Setup gamma bands
gamma_bounds = archs{1}.banks{1}.behavior.gamma_bounds;
min_gamma = max(gamma_bounds(1), 1);
max_gamma = min(gamma_bounds(2), length(archs{1}.banks{1}.metas));
resolutions = [archs{1}.banks{1}.metas(min_gamma:max_gamma).resolution];
frequencies = archs{1}.banks{1}.spec.mother_xi * sample_rate * resolutions;
nGammas = length(frequencies);

nBands = size(hertz_bands, 2);
gamma_bands = zeros(2, nBands);
for band_index = 1:nBands
    band_min_gamma = (min_gamma - 1) + ...
        find(frequencies < hertz_bands(2, band_index), 1);
    band_min_gamma(isempty(band_min_gamma)) = min_gamma;
    gamma_bands(1, band_index) = band_min_gamma;
    band_max_gamma = (min_gamma - 1) + ...
        find(frequencies > hertz_bands(1, band_index), 1, 'last'); 
    band_max_gamma(isempty(band_max_gamma)) = max_gamma;
    gamma_bands(2, band_index) = band_max_gamma;
end


%% Stack scattering coefficients according to bands
nBands = length(band_refs);
bands = cell(1, nBands);
nTime_frames = size(S{1+2}{1}.data{1}{1}, 1);
refs = generate_refs(S{1+2}{1}.data, 1, S{1+2}{1}.ranges{1+0});
for band_index = 1:nBands
    nCoefficients = length(band_refs{band_index});
    band = zeros(nTime_frames, nCoefficients);
    for coefficient_index = 1:nCoefficients
        ref = refs(:, band_refs{band_index}(coefficient_index));
        band(:, coefficient_index) = subsref(S{1+2}{1}.data, ref);
    end
    bands{band_index} = band;
end
