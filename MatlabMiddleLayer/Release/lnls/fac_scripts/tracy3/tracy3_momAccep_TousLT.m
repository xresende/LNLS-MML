function tracy3_momAccep_TousLT(the_ring, varargin)

n_calls = 1;
if nargin >= 1
    n_calls = varargin{1};
end

twi = calctwiss(the_ring);
params.emit0 = 2.8e-10;
params.E     = 3e9;
params.N     = 100e-3/864/1.601e-19*1.72e-6;
params.sigE  = 0.8e-3;
params.sigS  = 3.5e-3;
params.K     = 0.01;
accepRF      = 0.05;

color = {'b','r','g','m','c','k','y'};
esp_lin = 5;
size_font = 24;
scrsz = get(0,'ScreenSize');
xi = scrsz(4)/6;
yi = scrsz(4)/10;
xf = xi + scrsz(4)*(2/3);
yf = yi + scrsz(4)*(2/3);


path = '/home/fac_files/data/sirius_tracy/';
pl = zeros(1,2*n_calls);
text_leg = cell(1,n_calls);
for i=1:n_calls
    path = uigetdir(path,'Em qual pasta estao os dados?');
    if (path==0);
        return
    end;
    % full_name = '/home/fac_files/data/sirius_tracy/sr/calcs/v500/ac10_5/test_momAccep_fun/tracy3/momAccept.out';
    
    [~, result] = system(['ls ' path '| grep rms | wc -l']);
    n_pastas = str2double(result);
    rms_mode = true;
    if n_pastas == 0
        rms_mode = false;
        n_pastas = 1;
    end
    
    text_leg(i) = inputdlg('Digite a legenda','Legenda',1);
    
    j=0;
    for k = 1:n_pastas
        if rms_mode
            full_name = fullfile(path, sprintf('rms%02d/momAccept.out',k));
        else
            full_name = fullfile(path,'momAccept.out');
        end
        
        try
            a = importdata(full_name, ' ', 3);
            j = j + 1;
        catch
            fprintf('%-d-%-3d: nao carregou',i,k);
        end
        
        spos  = str2num(char(a.textdata{:,2}))'; spos = spos(1:end/2);
        accep(j,:) = str2num(char(a.textdata{:,3}));
        accep2 = reshape(accep(j,:), length(accep(j,:))/2, 2)';
        
        Accep(1,:) = spos;
        Accep(2,:) = min(min(abs(accep2)), accepRF);
        % não estou usando alguns outputs
        LT = lnls_tau_touschek_inverso(params,Accep,twi);
        lifetime(j) = 1/LT.AveRate/60/60; % em horas
        
        n_lost(j,:) = a.data(:,2);
        sLost(j,:) = str2num(char(a.textdata{:,4}));
    end
    
    aveAccep = mean(accep,1)*100; % em %
    aveAccep = reshape(aveAccep, length(aveAccep)/2, 2)';
    if rms_mode; 
        rmsAccep = std(accep,0,1)*100;
        rmsAccep = reshape(rmsAccep, length(rmsAccep)/2, 2)';
    end
    
    aveLT = mean(lifetime);
    if rms_mode; rmsLT = std(lifetime); end;
    
    sLost = sLost(:)';
    modSLost = mod(sLost,518.396/10);
    
    clear sLost n_lost lifetime accep Accep
    %% exposicao dos resultados
    
    %imprime o tempo de vida
    fprintf('\n Configuração:        %-s  \n',upper(text_leg{i}));
    fprintf(' Tempo de vida médio: %10.5f h \n',aveLT);
    if rms_mode; fprintf(' Desvio Padrão:       %10.5f h \n',rmsLT); end;
    
    
    % [~, ele] = hdrload('MA_ele.txt');
    
    if i == 1
        f=figure('OuterPosition',[xi yi xf yf]);
        fa = axes('Parent',f,'YGrid','on','XGrid','on','FontSize',size_font);
        box(fa,'on');
        hold(fa,'all');
        xlim([0, 52])
        xlabel('Pos [m]','FontSize',size_font);
        ylabel('Momentum Acceptance [%]','FontSize',size_font);
    end
    pl([2*i-1, 2*i]) = plot(fa,spos,aveAccep, 'Marker','.','LineWidth',...
        esp_lin,'Color',color{i}, 'LineStyle','-');
    if rms_mode;
        plot(fa,spos,aveAccep + rmsAccep, 'Marker','.','Color', color{i},'LineWidth',2,'LineStyle','--');
        plot(fa,spos,aveAccep - rmsAccep, 'Marker','.','Color', color{i},'LineWidth',2,'LineStyle','--');
    end
    % plot(ele(:,1), ele(:,[2 4])*100,'r','Marker','.','DisplayName',{'elegantpos', 'elegantneg'});
    
    
    
    % figure; semilogy(spos,n_lost, 'Marker','.','DisplayName',{'tracypos', 'tracyneg'});
    % hold all
    % % semilogy(ele(:,1), ele(:,[3 5]),'r','Marker','.','DisplayName',{'elegantpos', 'elegantneg'});
    % xlim([0, 52])
    % xlabel('Pos [m]'); ylabel('Turn loss[%]');
    % legend('show')
    
    f2=figure('OuterPosition',[xi yi xf yf]);
    fb = axes('Parent',f2,'FontSize',size_font);
    [n, xout] = hist(modSLost',12); bar(fb,xout,n);
    xlim([0, 52]);
    xlabel('Pos [m]','FontSize',size_font);
    ylabel('Number of particles lost','FontSize',size_font);
    title(fb,['Histograma - ' text_leg{i}]);
end

legend(pl(1:2:end),'show',text_leg, 'Location','Best');
title(fa,'Comparação de aberturas em momemtum');


