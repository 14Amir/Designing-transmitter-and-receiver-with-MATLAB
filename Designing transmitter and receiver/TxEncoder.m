clear
clc

%%
s = importdata('s.jpg');
imbins = zeros(size(s,1)*size(s,2)*3,8);
for i = 1:size(s,1)
    for j = 1:size(s,2)
        for k = 1:size(s,3)
            imbins(k+3*((i-1)*size(s,2)+(j-1)),1:8)=de2bi(s(i,j,k),8,'left-msb');
        end
    end
end
Stream = reshape(imbins',1,3*8*size(s,1)*size(s,2));

%%
%Encode, interleave, Header
n = 31;
k = 26;
stream_encoded = encode(Stream, n, k); %Hamming code 
row = 31;
column = length(stream_encoded) / row;
stream_matrix = reshape(stream_encoded, row, []); % reshape the stream
stream_interleave = reshape(stream_matrix', 1, []); 

Barker_code13 = [0 0 0 0 0 1 1 0 0 1 0 1 0];
Header_App = repmat(Barker_code13, 1, 5);

Frame_App = [Header_App, stream_interleave];
%%
N_data = 256;
N_header = 127;
N_pilot = 24;
Mode_order = 8;
Phase_offset = pi/Mode_order - pi/Mode_order*(Mode_order==2);

N_zeros_insert = N_data*log2(Mode_order)*3 -...
    mod(length(Frame_App), N_data*log2(Mode_order)*3);
Frame_App_zeros = [Frame_App, zeros(1,N_zeros_insert)];

Data_mat_sym = reshape(Frame_App_zeros, log2(Mode_order), [])' * [1; 2; 4];
Data_mat = reshape(pskmod(Data_mat_sym, Mode_order, Phase_offset), N_data, [])';

%%
N_Frame = 3*N_data + 2*N_pilot + N_header;
Frame_phy_mat = zeros(size(Data_mat, 1)/3, N_Frame);

Header_physical = (-1).^(mls(N_header) > 0)';
Pilot = ones(1,N_pilot);
j = 1;
for i=1:size(Frame_phy_mat, 1)
   
    Frame_phy_mat(i, :) = [Header_physical, Data_mat(j, :), Pilot, ...
        Data_mat(j + 1, :), Pilot, Data_mat(j + 2, :)];
    j = j + 3; 
end

data_sequence = reshape(Frame_phy_mat', 1, []);
%%
%% initialized the some parameters for simulink
Sps = 8;
Span = 20;
alpha = 0.2;
Rs = 1e6;
Mode_order = 8; % MPSK
ESN0 = 20; %[db]
Phase_offset = pi/Mode_order - pi/Mode_order*(Mode_order==2);

N_data = 256;
N_header = 127;
N_pilot = 24;

Header = (-1).^(mls(N_header) > 0)';
filter_coeff = fliplr(Header(2:end).*conj(Header(1:end-1)));

