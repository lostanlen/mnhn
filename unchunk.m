function S = unchunk(S)
S1 = S{1+1}.data;
S1 = S1((1+end/4):(3*end/4), :, :);
S1 = reshape(S1, size(S1, 1) * size(S1, 2), size(S1, 3));
S{1+1}.data = S1;
if ~iscell(S{1+1}.data)
    % unchunk plain scattering
    for gamma2_index = 1:length(S{1+2}.data)
        S2_node = S{1+2}.data{gamma2_index};
        S2_node = S2_node((1+end/4):(3*end/4), :, :);
        S2_node = reshape(S2_node, ...
            size(S2_node, 1) * size(S2_node, 2), size(S2_node, 3));
        S{1+2}.data{gamma2_index} = S2_node;
    end
else
    % unchunk joint scattering
end