function reconstructed = phase_space_reconstruct(time_series, dim, tau)
    m = length(time_series) - (dim - 1) * tau;
    reconstructed = zeros(m, dim);
    for i = 1:dim
        reconstructed(:, i) = time_series(1 + (i - 1) * tau : 1 + (i - 1) * tau + m - 1);
    end
    return;
end