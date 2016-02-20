function chunked_waveform = chunk(waveform, archs)

bank_spec = archs{1}.banks{1}.spec;
chunk_length = bank_spec.size;
unpadded_signal_size = length(waveform);

if unpadded_signal_size<=chunk_length
    % only one chunk
    nReplications = ceil(chunk_length / unpadded_signal_size);
    padded_waveform = repmat(waveform, [nReplications 1]);
    chunked_waveform = padded_waveform(1:chunk_length);  
elseif unpadded_signal_size>chunk_length
    nChunks = ceil(unpadded_signal_size/chunk_length);
    padded_signal_size = nChunks * chunk_length;
    padding_signal_size = padded_signal_size - unpadded_signal_size;
    padding_start = (nChunks-2) * chunk_length;
    padding_range = padding_start + (1:padding_signal_size);
    padding = waveform(padding_range);
    padded_waveform = cat(1, waveform, padding);

    nOdd_chunks = ceil(nChunks / 2);
    nEven_chunks = floor(nChunks / 2);
    
    % odd-numbered chunks
    odd_start = 1;
    odd_stop = odd_start - 1 + nOdd_chunks * chunk_length;
    odd_range = odd_start:odd_stop;
    odd_waveform = padded_waveform(odd_range);
    odd_waveform = reshape(odd_waveform, [chunk_length nOdd_chunks]);
    
    % even-numbered chunks
    even_start = 1 + chunk_length / 2;
    even_stop = even_start - 1 + nEven_chunks * chunk_length;
    even_range = even_start:even_stop;
    even_waveform = padded_waveform(even_range);
    even_waveform = reshape(even_waveform, [chunk_length nEven_chunks]);
    
    % isolate last chunk if the number of chunks is even
    if nOdd_chunks > nEven_chunks
        last_chunk = odd_waveform(:, end);
        odd_waveform = odd_waveform(:, 1:(end-1));
    end
    
    % interleave odd and even chunks
    chunked_waveform = cat(3, odd_waveform, even_waveform);
    chunked_waveform = permute(chunked_waveform, [1 3 2]);
    chunked_waveform = ...
        reshape(chunked_waveform, [chunk_length, 2*nEven_chunks]);
    
    % add last, odd-numbered chunk if needed
    if nOdd_chunks > nEven_chunks
        chunked_waveform = cat(2, chunked_waveform, last_chunk);
    end
end