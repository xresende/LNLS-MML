%% Valores obtidos do modelo1. Ja incluem as contribuicoes da borda (e1=e2=0, na definicao de B)
% Definido como opt_2 em 2013-05-21 em funcao da aprovacao do modelo1:

B_strength = -0.21755;
B_sext     = -1.70867; % Colocamos um kicks quad e sextupolar na borda do dipolo
mb_quad    =  0.00133; % para calcular os tune as chrom mais precisamente
mb_sext    = -0.2545;  % Quad = B_strength + 2*mb_quad/1.152 = 0.2152
                       % Sext = B_sext     + 2*mb_sext/1.152 = 2.1505
                       
qf_strength = 1.8821 - 0.001;
qd_strength = (0.0 + 0.0102)/2; % tanto o QD como os sextupolos dobraram de tamanho
sf_strength = 12.700515/2;
sd_strength = 0;





%% Para avaliacao dos multipolos do QD.
%alterei a sintonia mudando o gradiente do dipolo e corrigi com QD e QF.
% B_strength = -0.22755;
% B_sext     = -1.70867; % Colocamos um kicks quad e sextupolar na borda do dipolo
% mb_quad    =  0.00133; % para calcular os tune as chrom mais precisamente
% mb_sext    = -0.2545;  % Quad = B_strength + 2*mb_quad/1.152 = 0.2152
%                        % Sext = B_sext     + 2*mb_sext/1.152 = 2.1505
%                        
% qf_strength = 1.876;
% qd_strength = 0.15738; % tanto o QD como os sextupolos dobraram de tamanho
% sf_strength = 12.700515/2;
% sd_strength = 0;