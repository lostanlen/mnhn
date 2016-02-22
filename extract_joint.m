function S2_bands = extract_joint(S2, band_gammas)
gamma_subscript = ...
    S2{1,1}.variable_tree.time{1}.gamma{1}.leaf.subscripts;
nBands = length(band_gammas);
S2_bands = cell(1, nBands);
for band_index = 1:nBands
    gamma_start = band_gammas(1, band_index);
    gamma_stop = band_gammas(2, band_index);
    % psi-psi bands
    nGamma2s = length(S2{1,1}.data);
    psipsi_bands = cell(1, nGamma2s);
    for gamma2_index = 1:nGamma2s
        nGamma_gammas = length(S2{1,1}.data{gamma2_index});
        nNodes = 2*nGamma_gammas;
        gamma2_bands = cell(1, nNodes);
        for gamma_gamma_index = 1:nGamma_gammas
            tensor = S2{1,1}.data{gamma2_index}{gamma_gamma_index};
            gamma_range = S2{1,1}.ranges{1+0}{gamma2_index}{ ...
                gamma_gamma_index}(:, gamma_subscript);
            assert(gamma_range(1)==1);
            down_band = tensor(:, gamma_start:min(gamma_stop, end), 1);
            if ~isempty(down_band)
                gamma2_bands{1+2*(gamma_gamma_index-1)} = sum(down_band, 2);
                up_band = tensor(:, gamma_start:min(gamma_stop, end), 2);
                gamma2_bands{2*gamma_gamma_index} = sum(up_band, 2);
            end
        end
        psipsi_bands{gamma2_index} = [gamma2_bands{:}];
    end
    % psi-phi bands
    nGamma2s = length(S2{1,2}.data);
    psiphi_bands = cell(1, nGamma2s);
    for gamma2_index = 1:nGamma2s
        gamma_range = S2{1,2}.ranges{1+0}{gamma2_index}(:, gamma_subscript);
        assert(gamma_range(1)==1);
        psiphi_band = ...
            S2{1,2}.data{gamma2_index}(:, gamma_start:min(gamma_stop, end));
        if ~isempty(psiphi_band)
            psiphi_bands{gamma2_index} = sum(psiphi_band, 2);
        end
    end
    S2_bands{band_index} = cat(2, psipsi_bands, psiphi_bands);
    S2_bands{band_index} = [S2_bands{band_index}{:}].';
end
end