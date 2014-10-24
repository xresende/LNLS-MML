function sirius_calc_stats(N,thering0,save_fig,arqConfig,arqConfig_extra,scale)
% Script que calcula estatistica das orbitas e otica da maquina e faz o
% grafico da orbita fechada para N maquinas com erros aleatorios e
% correcao. As variaveis de entrada obrigatorias sao:
%   N - quantidades de mauiqnas a serem avaliada;
% Variaveis que podem ser utlizadas:
%   thering0 - modelo sem error da maquina;
%   save_fig - salav o grafico em uma figura com extensao .png.
%   arqConfig - arquivo CONFIG.mat (ou outros nome) onde estao armazenados
%   parametros principais das maquinas simuladas.
%   arqConfig_extra - arquivo com as maquina com error e correcaoes
%   desejadas.
%   scale - escala para os graficos. Usualmente no caso de maquinas sem
%   correcao de orbita deve ser 1e3, com correcao de orbita 1e6 e no caso
%   de testes apenar com erros dinamicos 1e9. 


    %Seleciona e carrega os arquivos para analise
    if exist('arqConfig', 'var')==0
        [FileName,PathName] = uigetfile('*.mat','Select the MATLAB Config.mat file');
        load([PathName FileName]);
    end;
    
    if exist('arqConfig_extra', 'var')==0
        [FileName,PathName] = uigetfile('*.mat','Select the MATLAB file with the stats to be analyzed');
        load([PathName FileName]);
    end; 
    
    % Define uma escala para os graficos
    if exist('scale', 'var')==0
        scale = 1e6;
    end;
    
    % Se um modelo de anel não é passado, usa o do arquivo de configs.
    if ~exist('thering0','var')
        thering0 = r.params.the_ring;
    end
    
    %Calcula parametros de twiss da rede sem erros
    twiss0 = calctwiss(thering0);
    
    %Armazena todos os valoes de twiss das N maquina num vetor de cells
    for i=1:N
        if scale==1e3
            sext_idx = getappdata(0, 'Sextupole_Idx');
            sext_str = getcellstruct(machine{i}, 'PolynomB', sext_idx, 1, 3);
            machine{i} = set_sextupoles(machine{i}, 0, sext_str);
            twiss(i)=calctwiss(machine{i});
        else
            twiss(i)=calctwiss(machine{i});
        end
    end
    
    %Calcula rms da orbita entre as maquinas
    if scale==1e3
        fprintf('where|   codx[mm]    |   cody[mm]     \n');
    elseif scale==1e6 
        fprintf('where|   codx[um]    |   cody[um]     \n');
    else 
        fprintf('where|   codx[nm]    |   cody[nm]     \n');
    end
    fprintf('     | (max)  (std)  | (max)  (std)   \n');
    formatSpec=' %3s | %4.2f  %4.2f | %4.2f  %4.2f  \n';  
    
    if (scale==1e6 || scale==1e3)
        bpm = r.params.static.bpm_idx;
        ch=r.params.static.hcm_idx;
        cv=r.params.static.vcm_idx;
    else 
        bpm = r.params.dynamic.bpm_idx;
        ch=r.params.dynamic.hcm_idx;
        cv=r.params.dynamic.vcm_idx;
    end

    
    for i=1:length(twiss0.cox)
        % Calcula estatisticas ponto a ponto na maquina
        for k=1:N
            posx(k)=twiss(k).cox(i);
            posy(k)=twiss(k).coy(i);
        end
        codx_max(i)=max(abs(posx))*scale;
        codx_std(i)=std(posx)*scale;
        cody_max(i)=max(abs(posy))*scale;
        cody_std(i)=std(posy)*scale;      
    end
    fprintf(formatSpec,'all',max(codx_max),max(codx_std),max(cody_max),max(cody_std));
    fprintf(formatSpec,'bpm',max(codx_max(bpm)),max(codx_std(bpm)),max(cody_max(bpm)),max(cody_std(bpm)));
    fprintf('\n\n\n')

    % Calcula estatisticas da forca das corretoras
    if scale==1e3
        fprintf('id |  kickX[mrad]   |  kickY[mrad]     \n');
    elseif scale==1e6
        fprintf('id |  kickX[urad]   |  kickY[urad]     \n');
    else
        fprintf('id |  kickX[nrad]   |  kickY[nrad]     \n');
    end
    fprintf('   |  (max)  (std)  |  (max)  (std)    \n');
    formatSpec=' %3d | %4.2f  %4.2f | %4.2f  %4.2f \n';  
    
    
    for i=1:N
        kick_x(i)=max(abs(getcellstruct(twiss(i).THERING,'KickAngle',ch,1)))*scale;
        kick_y(i)=max(abs(getcellstruct(twiss(i).THERING,'KickAngle',cv,2)))*scale;
        std_kickx(i)=std(getcellstruct(twiss(i).THERING,'KickAngle',ch,1))*scale;
        std_kicky(i)=std(getcellstruct(twiss(i).THERING,'KickAngle',cv,2))*scale;
        fprintf(formatSpec,i,kick_x(i),std_kickx(i),kick_y(i),std_kicky(i));
    end
    fprintf('----------------------------------------------------\n');
    formatSpec=' %4s| %4.2f  %4.2f | %4.2f  %4.2f \n';
    fprintf(formatSpec,'stat',max(kick_x),max(std_kickx),max(kick_y),max(std_kicky));
    fprintf('\n\n\n')

                
    %Calcula estatisticas e o beta-beat em X e Y da cada maquina simulada
    fprintf('ind | b-beat X (%%) | b-beat Y (%%)  \n');    
    formatSpec='%3d |     %4.2f    |     %4.2f \n';  
    
    for i=1:N
        beatx(i) = mean(abs(twiss0.betax-twiss(i).betax)./twiss0.betax)*100;
        beaty(i) = mean(abs(twiss0.betay-twiss(i).betay)./twiss0.betay)*100;
        fprintf(formatSpec,i,beatx(i),beaty(i));
    end
    fprintf('----------------------------------------------------\n');
    formatSpec='%4s|  %4.2f  | %4.2f \n';  
    fprintf(formatSpec,'stat',mean(beatx),mean(beaty));
    fprintf('\n\n\n');
    
    %Calcula variacao de orbita total
    if scale==1e3
        fprintf('ind |     cod X (mm)    |     cod Y (mm)    \n');
    elseif scale==1e6
        fprintf('ind |     cod X (um)    |     cod Y (um)    \n');
    else
        fprintf('ind |     cod X (nm)    |     cod Y (nm)    \n');    
    end
    fprintf('    |  (max)    (std)   |  (max)    (std)\n');
    formatSpec='%3d |   %4.2f     %4.2f   |  %4.2f     %4.2f\n';    
       
    for i=1:N
        %calcula maximo e desvio padrao da orbita fechada no BC
        maxBCx(i)  = max(abs(twiss(i).cox))*scale;
        stdBCx(i)  = std(twiss(i).cox)*scale;
        codx_sigmax(i)  = max(abs(twiss(i).cox)./sqrt(0.2772*1e-9*twiss(i).betax+0.00083^2*twiss(i).etax.^2));
        codxp_sigmaxp(i)  = max(abs(twiss(i).coxp)./sqrt(0.2772*1e-9*(1+twiss(i).alphax.^2)./twiss(i).betax+0.00083^2*twiss(i).etaxl.^2));
        maxBCy(i)  = max(abs(twiss(i).coy))*scale;
        stdBCy(i)  = std(twiss(i).coy)*scale;
        cody_sigmay(i)  = max(abs(twiss(i).coy)./sqrt(0.0028*1e-9*twiss(i).betay));
        codyp_sigmayp(i)  = max(abs(twiss(i).coyp)./sqrt(0.0028*1e-9*(1+twiss(i).alphay.^2)./twiss(i).betay));
        fprintf(formatSpec,i,maxBCx(i),stdBCx(i),maxBCy(i),stdBCy(i));
    end
    fprintf('----------------------------------------------------\n');
    formatSpec='%4s|   %4.2f     %4.2f   |  %4.2f     %4.2f\n';    
    fprintf(formatSpec,'stat',mean(maxBCx),mean(stdBCx),mean(maxBCy),mean(stdBCy));
    fprintf('\n\n\n')
    
    formatSpec=' %4.2f     %4.2f   e  %4.2f     %4.2f\n'; 
    fprintf('Distorcao em relacao ao tamanho do feixe (X e Y):');
    fprintf(formatSpec,mean(codx_sigmax),mean(codxp_sigmaxp),mean(cody_sigmay),mean(codyp_sigmayp));
    fprintf('\n\n\n')
    

    %Calcula variacao de orbita no BC
    if scale==1e3
        fprintf('ind |      cod BC X (mm)      |      cod BC Y (mm)    \n');    
    elseif scale==1e6
        fprintf('ind |      cod BC X (um)      |      cod BC Y (um)    \n');    
    else
        fprintf('ind |      cod BC X (nm)      |      cod BC Y (nm)    \n');    
    end
    fprintf('    |         pos            angle        |         pos            angle       \n');
    fprintf('    |  (max)     (std)    (max)    (std)  |  (max)     (std)    (max)    (std) \n');
    formatSpec='%3d |  %5.3f    %5.3f   %5.3f    %5.3f  |  %5.3f    %5.3f   %5.3f    %5.3f  \n';  
    
    %seleciona posicao dos marcadores do centro do BC (mc)
    mc = findcells(thering0,'FamName','mc');
    
    for i=1:N
        %calcula maximo e desvio padrao da orbita fechada e do angulo no BC
        maxBCx(i)  = max(abs(twiss(i).cox(mc)))*scale;
        maxBCxp(i)  = max(abs(twiss(i).coxp(mc)))*scale;
        stdBCx(i)  = std(twiss(i).cox(mc))*scale;
        stdBCxp(i)  = std(twiss(i).coxp(mc))*scale;
        maxBCy(i)  = max(abs(twiss(i).coy(mc)))*scale;
        maxBCyp(i)  = max(abs(twiss(i).coyp(mc)))*scale;
        stdBCy(i)  = std(twiss(i).coy(mc))*scale;
        stdBCyp(i)  = std(twiss(i).coyp(mc))*scale;
        fprintf(formatSpec,i,maxBCx(i),stdBCx(i),maxBCxp(i),stdBCxp(i),maxBCy(i),stdBCy(i),maxBCyp(i),stdBCyp(i));
    end
    fprintf('---------------------------------------------------------------------------\n');
    formatSpec='%4s|  %5.3f    %5.3f   %5.3f    %5.3f  |  %5.3f    %5.3f   %5.3f    %5.3f \n';  
    fprintf(formatSpec,'stat',mean(maxBCx),mean(stdBCx),mean(maxBCxp),mean(stdBCxp),mean(maxBCy),mean(stdBCy),mean(maxBCyp),mean(stdBCyp));
    fprintf('\n\n\n')
    
    %Faz o grafico das orbitas e rms de 1 setor
    mib = findcells(thering0,'FamName','mib');
    mia = findcells(thering0,'FamName','mia');
    ini=1;
    fim=mib(1);
    posz=twiss0.pos; 
    CODfig=figure;
    set(CODfig, 'Position', [1 1 1000 350]);
    axes('FontSize',14);
    hold on;
    for i=1:N
        plot(posz(ini:fim),abs(twiss(i).cox(ini:fim)*scale),'Color', [0.4 0.69 1]);
        plot(posz(ini:fim),-abs(twiss(i).coy(ini:fim)*scale),'Color', [1 0.6 0.6]);
    end
    plot(posz(ini:fim),abs(codx_std(ini:fim)),'LineWidth',3,'Color',[0 0 0.8]);
    plot(posz(ini:fim),-abs(cody_std(ini:fim)),'LineWidth',3,'Color',[1 0 0]);

    offset=0;
    top=0;
    for i=1:N
        offset=max(offset,max(abs(twiss(i).coy(ini:fim)))*scale);
        top=max(top,max(abs(twiss(i).cox(ini:fim)))*scale);
    end
    %Faz grafico da rede
    Delta=(top+offset)*0.1/3;
    offset=-offset-2*Delta;
    lnls_drawlattice(thering0,20,offset,1,Delta);
    offset=offset-2*Delta;
    ylim([offset top+2]);

    % Creat mirror axes
    box('on');
    grid 'on';

    % Create xlabel
    xlabel({'s [m]'},'FontSize',14);
    
    title_str = inputdlg('Plot title:', 'Input name',1);
    title(title_str,'FontSize',16,'FontWeight','bold');

    % Create ylabel
    if scale==1e3
        ylabel({'COD [mm]'},'FontSize',14);
    elseif scale==1e6
        ylabel({'COD [um]'},'FontSize',14);
    else
        ylabel({'COD [mm]'},'FontSize',14);
    end

    % Create textbox
    annotation('textbox', [0.75 0.87 0.05 0.05],'String',{'Horizontal'},'FontSize',16,'FontWeight','bold','FitBoxToText','off','LineStyle','none');

    % Create textbox
    annotation('textbox',[0.75 0.30 0.05 0.05],'String',{'Vertical'},'FontSize',16,'FontWeight','bold','FitBoxToText','off','LineStyle','none');

    hold off;

    if exist('save_fig', 'var')
        print('-dpng','COD.png');
    end
   
end