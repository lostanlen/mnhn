function [S1_bands, S2_bands] = invariant_scattering(waveform, archs, ...
    frequency_bands, sample_rate)
% chunk
audio_chunks = chunk(waveform, archs);

% compute scattering transform
S = sc_propagate(audio_chunks, archs);

% unchunk
gamma_subscript = ndims(S{1+1}.data);
if gamma_subscript == 3
    S = unchunk(S);
end

% get wavelet scales ("gammas") corresponding to each frequency band
band_gammas = get_band_gammas(archs, frequency_bands, sample_rate);

% extract spectrogram (S1) bands
nBands = length(band_gammas);
S1_bands = cell(1, nBands);
for band_index = 1:nBands
    gamma_start = band_gammas(1, band_index);
    gamma_stop = band_gammas(2, band_index);
    % S1 band
    S1_bands{band_index} = S{1+1}.data(:, gamma_start:gamma_stop);
end


% sum scattering coefficients (S2) within each frequency band
if length(archs{1}.banks) == 1
    S2_bands = extract_plain(S{1+2}, band_gammas);
elseif length(archs{1}.banks) == 2
    S2_bands = extract_joint(S{1+2}, band_gammas);
end
end