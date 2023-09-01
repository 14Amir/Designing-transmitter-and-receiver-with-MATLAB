clc
tmp = load("out.mat");
data_Rx_sym= de2bi(tmp.out.simout, log2(Mode_order), 'right-msb');
data_Rx = reshape(data_Rx_sym', 1, []);

packet_corr = upfirdn((-1).^data_Rx, fliplr((-1).^Header_App) );
[~, max_indx] = max(abs(packet_corr));

stream_interleave_Rx =  data_Rx(max_indx + 1:max_indx + length(stream_interleave));
%isequal(stream_interleave, stream_interleave_Rx);

stream_matrix_Rx = reshape(stream_interleave_Rx, column, []);
stream_encoded_Rx = reshape(stream_matrix_Rx', 1, []);
%isequal(stream_encoded_Rx, stream_encoded)

Stream_Rx = decode(stream_encoded_Rx, n, k);
Stream_Rx = Stream_Rx(1:end-8);

%% Image Reconstruction
StackedBins   = reshape(Stream_Rx,8,3*128^2)';
RxImage = zeros(128,128,3);
for i = 1:size(RxImage,1)
    for j = 1:size(RxImage,2)
        for k = 1:size(RxImage,3)
            RxImage(i,j,k) = bi2de(StackedBins(k+3*((i-1)*size(RxImage,2)+(j-1)),1:8),'left-msb');
        end
    end
end
RxImage = uint8(RxImage);
imshow(RxImage)














