function info = collect_info_coup(the_ring, coup, nper)

if ~exist('nper','var'), nper = 1; end
stepK0 = 0.001;

fprintf('nr skewcorr: %03i\n', length(coup.scm_idx));

% Test hysteresis
hyster = 0.0;
stepK = stepK0*(1-hyster);% Test hysteresis

len_scms= length(coup.scm_idx)/nper;
len_bpm = length(coup.bpm_idx)/nper;
len_hcm = length(coup.hcm_idx)/nper;
len_vcm = length(coup.vcm_idx)/nper;
if logical(mod(len_scms,1))
    len_scms = len_scms*nper;
    len_bpm = len_bpm*nper;
    len_hcm = len_hcm*nper;
    len_vcm = len_vcm*nper;
    nper = 1;
end

info = cell(1,len_scms*nper);

lnls_create_waitbar('Colecting Info for Optics Response Matrix Calculation',0.5,len_scms);
K = getcellstruct(the_ring, 'PolynomA', coup.scm_idx(1:len_scms), 1, 2);
the_ring_calc = the_ring;
for i1=1:len_scms
    the_ring_calc = setcellstruct(the_ring_calc, 'PolynomA', coup.scm_idx(i1), K(i1) + stepK/2, 1, 2);
    [Mp, Dispp, tunep] = get_matrix_disp(the_ring_calc, coup.bpm_idx, coup.hcm_idx, coup.vcm_idx);
    the_ring_calc = setcellstruct(the_ring_calc, 'PolynomA', coup.scm_idx(i1), K(i1) - stepK, 1, 2);
    [Mn, Dispn, tunen] = get_matrix_disp(the_ring_calc, coup.bpm_idx, coup.hcm_idx, coup.vcm_idx);
    the_ring_calc = setcellstruct(the_ring_calc, 'PolynomA', coup.scm_idx(i1), K(i1) + stepK/2, 1, 2);
    
    info{i1} = struct('M',(Mp-Mn)/stepK0,'Disp',(Dispp-Dispn)/stepK0, 'Tune',(tunep-tunen)/stepK0);
    lnls_update_waitbar(i1)
end
lnls_delete_waitbar;


if nper ~= 1
    for i1=1:len_scms
        M = mat2cell(info{i1}.M, nper*len_bpm*[1 1], nper*[len_hcm len_vcm]);
        Mxx = M{1,1};
        Mxy = M{1,2};
        Myx = M{2,1};
        Myy = M{2,2};
        Disp = info{i1}.Disp;
        for i2=1:(nper-1)
            Mxx = circshift(Mxx,[len_bpm, len_hcm]);
            Myx = circshift(Myx,[len_bpm, len_hcm]);
            Mxy = circshift(Mxy,[len_bpm, len_vcm]);
            Myy = circshift(Myy,[len_bpm, len_vcm]);
            Disp = circshift(Disp,[0,len_bpm]);
            info{i1+len_scms*i2}.M = [Mxx,Mxy;Myx,Myy];
            info{i1+len_scms*i2}.Disp = Disp;
            info{i1+len_scms*i2}.Tune = info{i1}.Tune;
        end
    end
end