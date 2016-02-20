function gamma_bands = get_gamma_bands(archs, hertz_bands, sample_rate)
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
end

