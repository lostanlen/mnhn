function S = unchunk(S)
S1 = S{1+1}.data;
S1 = S1((1+end/4):(3*end/4), :, :);
S1 = reshape(S1, size(S1, 1) * size(S1, 2), size(S1, 3));
S{1+1}.data = S1;
if ~iscell(S{1+2})
    % unchunk plain scattering
    for gamma2_index = 1:length(S{1+2}.data)
        S2_node = S{1+2}.data{gamma2_index};
        S2_node = S2_node((1+end/4):(3*end/4), :, :);
        S2_node = reshape(S2_node, ...
            size(S2_node, 1) * size(S2_node, 2), ...
            size(S2_node, 3));
        S{1+2}.data{gamma2_index} = S2_node;
    end
else
    % unchunk joint scattering
    % unchunk psi-psi
    for gamma2_index = 1:length(S{1+2}{1,1}.data)
        gamma2_node = S{1+2}{1,1}.data{gamma2_index};
        for gamma_gamma_index = 1:length(gamma2_node)
            S2_node = gamma2_node{gamma_gamma_index};
            S2_node = S2_node((1+end/4):(3*end/4), :, :, :);
            S2_node = reshape(S2_node, ...
                size(S2_node, 1) * size(S2_node, 2), ...
                size(S2_node, 3), ...
                size(S2_node, 4));
            gamma2_node{gamma_gamma_index} = S2_node;
        end
        S{1+2}{1,1}.data{gamma2_index} = gamma2_node;
    end
    % unchunk psi-phi
    for gamma_gamma_index = 1:length(S{1+2}{1,2}.data)
        S2_node = S{1+2}{1,2}.data{gamma_gamma_index};
        S2_node = S2_node((1+end/4):(3*end/4), :, :);
        S2_node = reshape(S2_node, ...
            size(S2_node, 1) * size(S2_node, 2), ...
            size(S2_node, 3));
        S{1+2}{1,2}.data{gamma_gamma_index} = S2_node;
    end
end