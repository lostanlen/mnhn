function S2_bands = extract_plain(S2, band_gammas)
nBands = length(band_gammas);
S2_bands = cell(1, nBands);
for band_index = 1:nBands
    gamma_start = band_gammas(1, band_index);
    gamma_stop = band_gammas(2, band_index);
    % S2 band
    nGamma2s = length(S2.data);
    S2_bands{band_index} = cell(1, nGamma2s);
    for gamma2_index = 1:length(S2.data)
        gamma_range = S2.ranges{1+0}{gamma2_index}(:, 2);
        assert(gamma_range(1)==1);
        S2_band = S2.data{gamma2_index}(:, gamma_start:min(gamma_stop, end));
        if ~isempty(S2_band)
            S2_bands{band_index}{gamma2_index} = sum(S2_band, 2);
        end
    end
    S2_bands{band_index} = [S2_bands{band_index}{:}];
end
end