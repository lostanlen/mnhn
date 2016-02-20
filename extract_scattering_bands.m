function [S1_bands, S2_bands] = extract_scattering_bands(waveform, archs)
% chunk
audio_chunks = chunk(waveform, archs);

% compute scattering transform
S = sc_propagate(audio_chunks, archs);

% unchunk
gamma_subscript = ndims(S{1+1}.data);
if gamma_subscript == 3
    S = unchunk(S);
end

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
end