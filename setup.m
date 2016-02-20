% nFilters_per_octave is an integer
% sample_rate is an integer in Hertz, usually 44100
% ROI_duration is the duration in seconds of the region of interest
% scattering_modulations is a structure with two fields:
% - scattering_modulations.nTemporal_modulations is an integer
% - scattering_modulations.nSpectral_modulations (optional) is an integer
% If scattering_modulations.nSpectral_modulations is absent, the setup performs
% plain scattering along time. Otherwise, it performs joint time-frequency
% scattering (see Andén et al. 2015).
function archs = setup(...
    nFilters_per_octave, ...
    ROI_duration, ...
    sample_rate, ...
    scattering_modulations)
T = pow2(nextpow2(round(ROI_duration * sample_rate * 0.5)));

% Wavelet transform
opts{1}.time.nFilters_per_octave = nFilters_per_octave;
opts{1}.time.T = T;
opts{1}.time.size = 4*T;
opts{1}.time.gamma_bounds = [1 nFilters_per_octave*8];
opts{1}.time.is_chunked = false;

% Time scattering
opts{2}.time.nFilters_per_octave = 1;
opts{2}.time.sibling_mask_factor = 2; % controls the inequality j1 < j2
opts{2}.time.T = T;
opts{2}.time.gamma_bounds = [1 scattering_modulations.nTemporal_modulations];

% Frequential scattering if required
if isfield(scattering_modulations, 'nSpectral_modulations')
    opts{2}.gamma.T = 2^(scattering_modulations.nSpectral_modulations);
end

archs = sc_setup(opts);
end