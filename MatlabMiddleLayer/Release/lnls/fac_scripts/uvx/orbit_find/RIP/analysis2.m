function analysis2

r = [];

fclose('all'); close('all'); clc;

r.h_weight = 1.0;
r.v_weight = 0.0;
r.change_quads = false;
r.change_dips  = false;


r.the_ring = load_lattice_model;


%r.families = get_measured_data(r, {'A2QD01', 'A2QD03', 'A2QD05', 'A2QD07', 'A2QD09', 'A2QD11', 'A2QF01', 'A2QF03', 'A2QF05', 'A2QF07', 'A2QF09', 'A2QF11', 'A6QF01', 'A6QF02'});
%r.families = get_measured_data(r, {'A2QF01','A2QF03','A2QF05', 'A2QF07', 'A2QF09', 'A2QF11','A2QD01','A2QD03','A2QD05', 'A2QD07', 'A2QD09', 'A2QD11'});
%r.families = get_measured_data(r, {'A2QF01', 'A2QF03', 'A2QF05', 'A2QF07', 'A2QF09', 'A2QF11'});
%r.families = get_measured_data(r, {'A6QF01', 'A6QF02'});

r.families = get_measured_data(r, {'A2QF01'});
%r.families = get_measured_data(r, {'A2QF01', 'A2QF03'});
%r.families = get_measured_data(r, {'A2QF01', 'A2QF03','A2QF05'});
%r.families = get_measured_data(r, {'A2QF01', 'A2QF03','A2QF05','A2QF07'});
%r.families = get_measured_data(r, {'A2QF01', 'A2QF03','A2QF05','A2QF07','A2QF09'});
%r.families = get_measured_data(r, {'A2QF01', 'A2QF03','A2QF05','A2QF07','A2QF09','A2QF11'});
%r.families = get_measured_data(r, {'A2QF01', 'A2QF03', 'A2QF05'});
%r.families = get_measured_data(r, {'A2QF01', 'A2QF03', 'A2QF05', 'A2QF07', 'A2QF09', 'A2QF11'});


% calc_cod0 = calc_cod_from_families(r);
%
% idx = getfamilydata('A2QF01', 'AT', 'ATIndex');
% r.the_ring = lnls_add_misalignmentX(-1e-6 * 50 * [1  1], idx, r.the_ring);
% calc_cod1 = calc_cod_from_families(r);
%
% idx = getfamilydata('A2QF03', 'AT', 'ATIndex');
% r.the_ring = lnls_add_misalignmentX(-1e-6 * 50 * [1  1], idx, r.the_ring);
% calc_cod2 = calc_cod_from_families(r);
%
% idx = getfamilydata('A2QF01', 'AT', 'ATIndex');
% r.the_ring = lnls_add_misalignmentX(-1e-6 * 50 * [1  1], idx, r.the_ring);
% calc_cod3 = calc_cod_from_families(r);
%
% figure; hold all; plot(calc_cod1.A2QF01.codx); plot(calc_cod3.A2QF01.codx - calc_cod2.A2QF01.codx);

%delete('the_ring_orb.mat');
if exist('the_ring_orb.mat', 'file')
    load('the_ring_orb.mat');
    r.the_ring = the_ring_orb;
end

meas_cod = r.families;

old_r    = r;
calc_cod = calc_cod_from_families(old_r);
diff     = calc_cod_diff(meas_cod, calc_cod);
old_residue  = calc_residue(diff, old_r.h_weight, old_r.v_weight);


iter = 0;
fprintf('%03i -> %6.3f\n', iter, 1e6*old_residue);

debug_plot = true;

hx = figure; hy = figure;

while (1e6*old_residue > 1)
    new_r = change_the_ring(old_r);
    calc_cod = calc_cod_from_families(new_r);
    diff     = calc_cod_diff(meas_cod, calc_cod);
    new_residue  = calc_residue(diff, new_r.h_weight, new_r.v_weight);
    iter = iter + 1;
    if (new_residue > old_residue)
        
    else
        old_r = new_r;
        old_residue = new_residue;
        fprintf('%03i -> %6.3f\n', iter, 1e6*old_residue);
        families = fieldnames(old_r.families);
        for j=1:length(families)
            family = families{j};
            idx = old_r.families.(family).idx;
            cnames = family2common(family);
            for i=1:size(idx,1);
                orbx = 1e6 * old_r.the_ring{idx(i,1)}.T1(1);
                orby = 1e6 * old_r.the_ring{idx(i,1)}.T1(3);
                fprintf('%s [um] -  H:%+8.2f  V:%+8.2f\n', cnames(i,:), orbx, orby);
            end
        end
        the_ring_orb = old_r.the_ring; save('the_ring_orb.mat', 'the_ring_orb');
        if (debug_plot), plot_cod(meas_cod, calc_cod, hx, hy); end;
    end
    
end

hx = figure; hy = figure;
visualize(old_r, hx, hy);

function plot_cod(meas_cod, calc_cod, hx, hy)

h_orb1 = []; v_orb1 = []; h_orb2 = []; v_orb2 = [];
fnames = fieldnames(meas_cod);
for i=1:length(fnames)
    family = fnames{i};
    h_orb1 = [h_orb1; meas_cod.(family).codx];
    v_orb1 = [v_orb1; meas_cod.(family).cody];
    h_orb2 = [h_orb2; calc_cod.(family).codx];
    v_orb2 = [v_orb2; calc_cod.(family).cody];
end
%figure(hx); clf; hold all; plot(1e6*h_orb1); plot(1e6*h_orb2);
figure(hx); clf; hold all;  plot(1e6*h_orb1); plot(1e6*(h_orb1-h_orb2));
%figure(hy); clf; hold all; plot(1e6*v_orb1); plot(1e6*v_orb2);


function visualize(r, hx, hy)

idx = findcells(r.the_ring, 'T1');
hoff = getcellstruct(r.the_ring, 'T1', idx, 1, 1);
voff = getcellstruct(r.the_ring, 'T1', idx, 1, 3);
idx_h = (hoff ~= 0);
idx_v = (voff ~= 0);

pos = findspos(r.the_ring, 1:length(r.the_ring));
L = findspos(r.the_ring, 1+length(r.the_ring));

figure(hx); clf; hold all; plot([0 L],[0 0], '--k'); plot(pos(idx(idx_h)), 1e6*hoff(idx_h), '.b'); xlabel('Pos [m]'); ylabel('Orbit Offset [um]'); title('Horizontal Orbit Offset w.r.t. Magnetic Centers');
miny = 1e6*min(hoff(idx_h)); maxy = 1e6*max(hoff(idx_h)); heig = (maxy -miny)/2; offs = miny - heig/2; scal = heig/3; drawlattice(offs, scal, gca);

figure(hy); clf; hold all; plot([0 L],[0 0], '--k'); plot(pos(idx(idx_v)), 1e6*voff(idx_v), '.r'); xlabel('Pos [m]'); ylabel('Orbit Offset [um]'); title('Vertical Orbit Offset w.r.t. Magnetic Centers');
miny = 1e6*min(voff(idx_v)); maxy = 1e6*max(voff(idx_v)); heig = (maxy -miny)/2; offs = miny - heig/2; scal = heig/3; drawlattice(offs, scal, gca);


function r = change_the_ring(r0)

delta_k   = 0.002;
delta_pos = 5e-6;
delta_exc = 0.002/100;

r = r0;


if r.change_dips
    dips = getfamilydata('BEND', 'AT', 'ATIndex');
    rndExc = delta_exc*2*(rand(size(dips,1),1) - 0.5);
    r.the_ring = lnls_add_excitation(rndExc, dips, r.the_ring);
end


for i=1:2
    
    fnames = fieldnames(r.families);
    idx    = randi(length(fnames));
    family = fnames{idx};
    
    
    
    idx     = r.families.(family).idx;
    
    % changes PosX
    if (r.h_weight ~= 0)
        rndPos  = delta_pos*2*(rand(size(idx,1),1) - 0.5);
        r.the_ring = lnls_add_misalignmentX(-rndPos, idx, r.the_ring);
    end
    
    % changes PosY
    if (r.v_weight ~= 0)
        rndPos  = delta_pos*2*(rand(size(idx,1),1) - 0.5);
        r.the_ring = lnls_add_misalignmentY(-rndPos, idx, r.the_ring);
    end
    
    % changes K
    if r.change_quads
        K = getcellstruct(r.the_ring, 'K', idx(:,1));
        rndK = delta_k*2*(rand(size(K,1),1) - 0.5);
        newK = K + rndK;
        for i=1:size(idx,2)
            r.the_ring = setcellstruct(r.the_ring, 'K', idx(:,i), newK);
            r.the_ring = setcellstruct(r.the_ring, 'PolynomB', idx(:,i), newK, 1, 2);
        end
    end
    
end







function the_ring = load_lattice_model

global THERING

% loads default ring model
lnls1_set_server('','','');
lnls1;

% setpv('A2QF01', 'Hardware', 169.150);
% setpv('A2QF03', 'Hardware', 169.020);
% setpv('A2QF05', 'Hardware', 169.478);
% setpv('A2QF07', 'Hardware', 169.444);
% setpv('A2QF09', 'Hardware', 170.100);
% setpv('A2QF11', 'Hardware', 169.776);
% setpv('A2QD01', 'Hardware', 184.932);
% setpv('A2QD03', 'Hardware', 185.405);
% setpv('A2QD05', 'Hardware', 183.703);
% setpv('A2QD07', 'Hardware', 182.444);
% setpv('A2QD09', 'Hardware', 182.406);
% setpv('A2QD11', 'Hardware', 183.124);
%setpv('A6QF01', 'Hardware', 118.273);
%setpv('A6QF02', 'Hardware', 117.609);

lnls1_set_id_field('AWG09', 3.5);
lnls1_set_id_field('AWG01', 2.0);
lnls1_set_id_field('AON11', 0.54);

setpv('HCM', +1.388, common2dev('ACH01A', 'HCM'), 'Hardware');
setpv('HCM', +0.784, common2dev('ACH07A', 'HCM'), 'Hardware');
setpv('HCM', +0.164, common2dev('ACH09A', 'HCM'), 'Hardware');
setpv('HCM', +0.082, common2dev('ACH05B', 'HCM'), 'Hardware');
setpv('HCM', -1.296, common2dev('ACH12' , 'HCM'), 'Hardware');
setpv('HCM', -2.246, common2dev('ACH02' , 'HCM'), 'Hardware');
setpv('HCM', -2.267, common2dev('ACH03A', 'HCM'), 'Hardware');
setpv('HCM', -2.513, common2dev('ACH01B', 'HCM'), 'Hardware');
setpv('HCM', -2.583, common2dev('ACH11A', 'HCM'), 'Hardware');
setpv('HCM', -2.808, common2dev('ACH11B', 'HCM'), 'Hardware');
setpv('HCM', -2.895, common2dev('ACH09B', 'HCM'), 'Hardware');
setpv('HCM', -3.744, common2dev('ACH07B', 'HCM'), 'Hardware');
setpv('HCM', -3.767, common2dev('ACH08' , 'HCM'), 'Hardware');
setpv('HCM', -3.896, common2dev('ACH10' , 'HCM'), 'Hardware');
setpv('HCM', -3.964, common2dev('ACH03B', 'HCM'), 'Hardware');
setpv('HCM', -4.223, common2dev('ACH05A', 'HCM'), 'Hardware');
setpv('HCM', -4.225, common2dev('ACH04' , 'HCM'), 'Hardware');
setpv('HCM', -5.760, common2dev('ACH06' , 'HCM'), 'Hardware');

the_ring = THERING;

% idx = getfamilydata('A2QD01', 'AT', 'ATIndex');
% the_ring = lnls_add_misalignmentX(-1e-6 * [-51.08 -58.70], idx, the_ring);
% the_ring = lnls_add_misalignmentY(-1e-6 * [-20.24   0.17], idx, the_ring);
%
% idx = getfamilydata('A2QD03', 'AT', 'ATIndex');
% the_ring = lnls_add_misalignmentX(-1e-6 * [-76.3 -8.40], idx, the_ring);
% the_ring = lnls_add_misalignmentY(-1e-6 * [-135.4 -164.1], idx, the_ring);

% idx = getfamilydata('A2QF01', 'AT', 'ATIndex');
% the_ring = lnls_add_misalignmentX(-1e-6 * 1 * [+67.22  -75.6], idx, the_ring);
% the_ring = lnls_add_misalignmentY(-1e-6 * 1 * [-11.00  +25.2], idx, the_ring);

%
% idx = getfamilydata('A2QF03', 'AT', 'ATIndex');
% the_ring = lnls_add_misalignmentX(-1e-6 * 1 * [ +11.84   +24.54], idx, the_ring);
% the_ring = lnls_add_misalignmentY(-1e-6 * 1 * [-138.90  -242.84], idx, the_ring);


function res = calc_cod_from_families(r)

global THERING

THERING = r.the_ring;
bpms = getfamilydata('BPMx', 'AT', 'ATIndex');
families = fieldnames(r.families);


setcavity('on');
setradiation('on');
o1 = findorbit6(THERING, 1:length(THERING));

for i=1:length(families)
    family = families{i};
    dK     = r.families.(family).dK;
    steppv(family, 'Physics', dK);
    o2   = findorbit6(THERING, 1:length(THERING));
    steppv(family, 'Physics', -dK);
    cod  = o2 - o1;
    res.(family).codx = cod(1,bpms)';
    res.(family).cody = cod(3,bpms)';
end

function r = calc_cod_diff(set1, set2)

fnames = fieldnames(set1);
for i=1:length(fnames)
    family = fnames{i};
    r.(family).codx = set1.(family).codx - set2.(family).codx;
    r.(family).cody = set1.(family).cody - set2.(family).cody;
    %figure; hold all; plot(set1.(family).codx); plot(set2.(family).codx);
end

function residue = calc_residue(set, h_weight, v_weight)

residue = 0;
fnames = fieldnames(set);
nr_families = length(fnames);
for i=1:nr_families
    family = fnames{i};
    nr_bpms = length(set.(family).codx);
    residue = residue + h_weight*sum(set.(family).codx.^2) + v_weight*sum(set.(family).cody.^2);
end
residue = sqrt(residue / ((h_weight + v_weight)*nr_bpms*nr_families));


function r = get_measured_data(r0, includes)

r = r0;
r.misallign.idx = {};

family = 'A2QD01';
if any(strcmpi(family, includes))
    data.(family).codx  = [-0.1063478695	0.0044789052	0.0328677337	0.0225981876	-0.0080438358	-0.0207514719	-0.0417932954	-0.0114421471	0.1080606032	0.0850755297	-0.0621161205	-0.051720704	0.130422251	0.132598781	-0.0456753389	-0.0605761976	0.0669192218	0.094816969	-0.0016567695	-0.0334940829	-0.0258568282	-0.0003985297	0.0395775582	0.0113621432	-0.1120534804]'/1000;
    data.(family).cody  = [-0.0520358577	-0.041524619	-0.0342872549	-0.0314754415	0.0495568526	0.104711464	0.0324089969	-0.0137516637	-0.0391845034	-0.000822192	0.0170971523	0.0459291905	0.0683291583	-0.0624459576	-0.0465235921	-0.0245315268	-0.0111180093	0.0375457044	0.0096497419	-0.036580326	-0.0495078467	0.0255399458	0.0374434145	0.0375011656	0.0386301255]'/1000;
    data.(family).dK = -0.1;
    idx = getfamilydata(family, 'AT', 'ATIndex');
    data.(family).idx = idx;
end

family = 'A2QD03';
if any(strcmpi(family, includes))
    data.A2QD03.codx  = [-0.0124593404	0.0342304741	0.0197320762	-0.0920214389	-0.0929051906	-0.0354089094	0.006838479	0.033239236	0.0156517007	-0.0126772885	-0.0293232524	-0.004284228	0.0824845502	0.0666480168	-0.043375889	-0.0370656477	0.0940326753	0.1007143317	-0.0288278952	-0.0409572281	0.0429412147	0.0622790164	0.0101424811	-0.0146725032	-0.0373458411]'/1000;
    data.A2QD03.cody  = [0.1009712417	0.0596717515	-0.0058352627	-0.0646177191	-0.1239631283	-0.1960585514	-0.0633334181	0.0194430669	0.0657048829	0.0067924256	-0.0270130564	-0.0814645603	-0.1180211168	0.1082315006	0.082874503	0.0494461187	0.0268722346	-0.0705610417	-0.0228270729	0.0514197248	0.078255711	-0.0319576444	-0.0576494324	-0.0675142841	-0.0715194013]'/1000;
    data.A2QD03.dK = -0.1;
    idx = getfamilydata('A2QD03', 'AT', 'ATIndex');
    data.(family).idx = idx;
end

family = 'A2QD05';
if any(strcmpi(family, includes))
    data.A2QD05.codx  = [0.1270281991	-0.0138069215	-0.0457491407	-0.0074318854	0.0315263049	0.0265691818	0.0410165688	0.0018353212	-0.1244318383	-0.1222556824	0.0304321411	0.0515705739	-0.0374450039	-0.0684722116	-0.012083238	0.0195840009	0.0580292292	0.0232185798	-0.0494773785	-0.0246878258	0.123382124	0.114930288	-0.0576330078	-0.0578661318	0.1071880133]'/1000;
    data.A2QD05.cody  = [-0.0698494859	-0.0611485855	-0.0454256095	-0.0378529708	0.0689882633	0.1399727698	0.0420481422	-0.0256939676	-0.0773901687	-0.0759469777	-0.0271115918	0.0364074279	0.0766585709	-0.0302907479	-0.0413869179	-0.0611240389	-0.0729175134	0.0865422574	0.0540720395	0.0035630876	-0.0279220819	-0.0276907033	0.004656121	0.0548254537	0.0841542704]'/1000;
    data.A2QD05.dK = -0.1;
    idx = getfamilydata('A2QD05', 'AT', 'ATIndex');
    data.(family).idx = idx;
end


family = 'A2QD07';
if any(strcmpi(family, includes))
    data.A2QD07.codx  = [-0.0028432312	0.0051785596	0.0033892315	-0.0152833939	-0.0150878877	-0.00027679	0.0074716225	0.0078165399	-0.0129630544	-0.0155142698	0.0020775541	0.0058940382	0.0020154625	0.0091932958	-0.0093480053	-0.0080475446	0.0186336261	0.0231104702	-0.0070159711	-0.0104182561	0.0077448013	0.0133909054	0.0011325055	-0.0025460844	-0.0084224482]'/1000;
    data.A2QD07.cody  = [0.064739276	0.0616703177	0.0571104299	0.0571076842	-0.0799000534	-0.1699513955	-0.0547801535	0.01558672	0.057006775	0.0058229624	-0.0234786813	-0.0705718792	-0.1162846083	0.0092086608	0.0349985271	0.0693167561	0.0891719953	-0.0959147543	-0.0661544828	-0.0223237371	0.0121275648	0.0474540954	0.0131089833	-0.0519784276	-0.0904511601]'/1000;
    data.A2QD07.dK = -0.1;
    idx = getfamilydata('A2QD07', 'AT', 'ATIndex');
    data.(family).idx = idx;
end

family = 'A2QD09';
if any(strcmpi(family, includes))
    data.A2QD09.codx  = [-0.0016139325	0.0011973179	0.0015917254	-0.0036372634	-0.0034534134	0.0001905549	0.0013801997	0.0016106745	-0.0027769425	-0.0024209652	2.09E-05	0.0009527747	-0.0003878335	-0.0001547095	-0.0015863025	-0.0006771191	0.0056631915	0.0073574416	-0.0015492146	-0.0028827895	0.0012775026	0.0024093962	0.001259929	0.0001451726	-0.0027514111]'/1000;
    data.A2QD09.cody  = [0.0344699642	0.0239466247	0.00721529	-0.0025617143	-0.0170922238	-0.0291880156	-0.0045130677	0.0193847859	0.0331352819	-0.0203270118	-0.0209659626	-0.0220284426	-0.0235094903	0.0346973203	0.0207681646	-0.0004646584	-0.0224263075	-0.0398658735	-0.0152727974	0.0093254877	0.0203308681	-0.001409415	-0.0122988776	-0.0247185558	-0.0312903697]'/1000;
    data.A2QD09.dK = -0.1;
    idx = getfamilydata('A2QD09', 'AT', 'ATIndex');
    data.(family).idx = idx;
end

family = 'A2QD11';
if any(strcmpi(family, includes))
    data.A2QD11.codx  = [-0.0132498841	-0.032754305	-0.0075994583	0.091132389	0.0760190695	0.0154727147	-0.0505953138	-0.0418732993	0.1008324146	0.1069148801	-0.0342052086	-0.0476312862	0.05345744	0.0759374762	0.0006304943	-0.0241346863	-0.028497869	-0.0037217386	0.0344239295	0.0126973076	-0.0948311975	-0.1035836927	0.0070080237	0.0318203589	0.0170935619]'/1000;
    data.A2QD11.cody  = [-0.0352005356	-0.0437862786	-0.0586703076	-0.0680721921	0.0750187559	0.1622812603	0.058855319	0.0048150691	-0.0252157498	-0.0340111963	0.0004941397	0.0557885798	0.0937243034	-0.0655072989	-0.0586831252	-0.0512968049	-0.0456625732	0.0732919744	0.0365411188	-0.0237081754	-0.0735144436	-0.0821842276	-0.0297837034	0.0314070938	0.0683418014]'/1000;
    data.A2QD11.dK = -0.1;
    idx = getfamilydata('A2QD11', 'AT', 'ATIndex');
    data.(family).idx = idx;
end




family = 'A2QF01';
if any(strcmpi(family, includes))
    data.A2QF01.codx  = [0.0155220489	0.0058855277	-0.0062779406	-0.0263249917	-0.0169295669	-0.0090786859	0.019304782	0.0101530777	-0.0467759831	-0.0416421699	0.022300113	0.01988952	-0.0537605012	-0.0526303799	0.0140277036	0.0204825878	-0.0196284877	-0.0304784169	-0.0032457211	0.0080517832	0.0126843362	0.0049859436	-0.0142327467	-0.0070933259	0.0317533929]'/1000;
    data.A2QF01.cody  = [0.0351148989	0.0318876989	0.0288361605	0.0277364513	-0.0447555589	-0.0934312238	-0.0282827031	0.0095003306	0.0311071285	0.0002983987	-0.0141738029	-0.0379095273	-0.0579652094	0.0493062443	0.0378238304	0.0211358646	0.0106698794	-0.0359638192	-0.0120858871	0.0261946543	0.0365749779	-0.0187995139	-0.0286927893	-0.0338119792	-0.0365235161]'/1000;
    data.A2QF01.dK = +0.1;
    idx = getfamilydata(family, 'AT', 'ATIndex');
    data.(family).idx = idx;
end


family = 'A2QF03';
if any(strcmpi(family, includes))
    data.A2QF03.codx  = [0.0023647162	0.0180584374	0.002544899	-0.0527782016	-0.0545075575	-0.0367017042	0.0067070819	0.0189164187	-0.0018977037	-0.0159249668	-0.0113411434	-0.0003610305	0.0313223214	0.0223004247	-0.0193609437	-0.0140012122	0.0380113871	0.0345647763	-0.0157872596	-0.0196698329	0.0317422229	0.03819649	-0.004312793	-0.0167139272	-0.0112045768]'/1000;
    data.A2QF03.cody  = [-0.0994297813	-0.0709331091	-0.0254396817	0.0024742928	0.0979957699	0.1976980153	0.0750908124	0.015589634	-0.0209215485	-0.0507244462	-0.0071916202	0.0642962657	0.1109754754	-0.0727426184	-0.0689882633	-0.0674920314	-0.0667522036	0.094369903	0.0490169587	-0.0241887287	-0.059679996	-0.0047838197	0.0314266974	0.0706529802	0.0933784322]'/1000;
    data.A2QF03.dK = +0.1;
    idx = getfamilydata(family, 'AT', 'ATIndex');
    data.(family).idx = idx;
end

family = 'A2QF05';
if any(strcmpi(family, includes))
    data.A2QF05.codx  = [-0.0213081104	0.0038101678	0.007036304	-0.0061290405	-0.0113828065	-0.0071696792	-0.0031943279	0.002467405	0.0084349479	0.0051294249	-0.0031676267	-0.0047068265	0.0038174046	0.0061761951	-8.95E-05	-0.0036001755	-0.0053101396	0.0013187252	0.0057465053	0.0006278452	-0.0171387738	-0.0140917566	0.008965735	0.0074785102	-0.0183640168]'/1000;
    data.A2QF05.cody  = [0.0437193916	0.0403457847	0.0344127845	0.0326892755	-0.0500321075	-0.1068285785	-0.0332689064	0.0132085908	0.0430896162	0.0534862294	0.0241256107	-0.0190159992	-0.0459434314	0.0107962878	0.0223263862	0.0425000848	0.0546382024	-0.0600197503	-0.0410541865	-0.010296131	0.0095724266	0.0247527265	0.0043424633	-0.0352933759	-0.0573729915]'/1000;
    data.A2QF05.dK = +0.1;
    idx = getfamilydata(family, 'AT', 'ATIndex');
    data.(family).idx = idx;
end

family = 'A2QF07';
if any(strcmpi(family, includes))
    data.A2QF07.codx  = [-0.0058594644	0.0030452885	0.0025859887	-0.0027927189	-0.0036271967	-0.0063063975	-5.83E-06	0.0006273153	0.0006301743	-0.0002430805	0.0015467795	0.0010817616	-0.0011105177	-0.0032038648	0.0035477226	0.0034067886	-0.0069025299	-0.0107150913	0.0046343981	0.0045999593	-0.0049368753	-0.0072688794	0.0022369302	0.0017330646	-0.0029919651]'/1000;
    data.A2QF07.cody  = [-0.1101880899	-0.089833419	-0.0588796121	-0.0414075812	0.0932066623	0.1876609698	0.0534717454	-0.044378322	-0.100332025	0.0292333605	0.0536835661	0.0954317181	0.1307650492	-0.0527882684	-0.0664191314	-0.0926323296	-0.1076540949	0.1318049711	0.0805872392	0.0028404033	-0.0438720483	-0.0361251193	0.0085604172	0.0829258963	0.1257248991]'/1000;
    data.A2QF07.dK = +0.1;
    idx = getfamilydata(family, 'AT', 'ATIndex');
    data.(family).idx = idx;
end

family = 'A2QF09';
if any(strcmpi(family, includes))
    data.A2QF09.codx  = [-0.0122698493	0.0023256212	0.0005565055	-0.0096041767	-0.0091760764	-0.0174115081	0.0008954079	0.0008360672	-0.0009325623	-0.0021301462	0.0011223193	-0.0013131402	-0.0108667548	-0.006654629	0.0049544137	0.0026009215	-0.0153062285	-0.0164457017	0.0051255478	0.0049194451	-0.0115629477	-0.0125302168	0.0025765494	0.0025278053	-0.0098007468]'/1000;
    data.A2QF09.cody  = [-0.0154965174	-0.0123433852	-0.0074662161	-0.0063838873	0.0055711325	0.0152737823	0.0058249197	-0.0057825335	-0.0124751646	0.0023854605	0.0061282094	0.0112149489	0.0132779982	-0.0167541941	-0.0119285284	-0.0043334563	0.0014410634	0.01836282	0.0103692471	-0.0012906589	-0.0082301646	-0.007136834	0.0009886575	0.0108868883	0.0163624586]'/1000;
    data.A2QF09.dK = +0.1;
    idx = getfamilydata(family, 'AT', 'ATIndex');
    data.(family).idx = idx;
end

family = 'A2QF11';
if any(strcmpi(family, includes))
    data.A2QF11.codx  = [-0.035970335	0.0161212397	0.0109650866	-0.0384707493	-0.0375811695	-0.026232486	0.0136854353	0.0152685588	-0.030142253	-0.0368646001	0.0077701998	0.0082677968	-0.0141654587	-0.0168612192	0.000588638	0.0034836135	-0.0089611349	-0.0073727339	0.0032626756	9.01E-06	-0.0157064869	-0.0146696713	0.011733552	0.0051912464	-0.0376958345]'/1000;
    data.A2QF11.cody  = [-0.011175322	0.0020140579	0.0230483703	0.0353103304	-0.0277173775	-0.0662584629	-0.0260627273	-0.0173025652	-0.0134800659	0.0297612761	0.0144377607	-0.0115078955	-0.0282853522	0.0056119292	0.0132859456	0.0258280139	0.033016933	-0.0412404488	-0.0286694769	-0.0071855158	0.0089235026	0.0314793289	0.0227099811	0.0035964667	-0.0078422729]'/1000;
    data.A2QF11.dK = +0.1;
    idx = getfamilydata(family, 'AT', 'ATIndex');
    data.(family).idx = idx;
end

family = 'A6QF01';
if any(strcmpi(family, includes))
    data.A6QF01.codx  = [-0.0557517454	0.0224486475	0.0312660351	0.0120233675	0.007095975	-0.0005342985	0.0188146919	0.0203310572	-0.0169607187	-0.0056058787	0.0445266902	0.031042635	-0.0537016904	-0.0401179819	0.0612146393	0.0517508668	-0.0816424824	-0.0766231618	0.0643077702	0.0614260404	-0.0777065191	-0.0834633259	0.053374787	0.0639268245	-0.0376603298]'/1000;
    data.A6QF01.cody  = [-0.0074659502	-0.0095915752	-0.007841608	-0.0068082789	0.0131768012	0.0258108184	0.0081937769	-0.0011778058	0.0040555089	0.0075999902	0.0016094113	-0.0036176182	-0.0071553156	0.0052023728	0.0050874003	0.0024917771	-0.0045927329	-0.0055961715	0.0040017845	0.0017754508	-0.0019119322	-0.0019381285	0.0001711342	0.006666815	0.0163600651]'/1000;
    data.A6QF01.dK = +0.03;
    idx = getfamilydata(family, 'AT', 'ATIndex');
    data.(family).idx = idx;
end


family = 'A6QF02';
if any(strcmpi(family, includes))
    data.A6QF02.codx  = [0.0118541656	0.0165780131	0.0006555728	-0.0255191246	-0.0236424769	-0.0069615714	0.0028298068	0.0113743292	-0.0097702952	-0.0226907972	-0.0152699259	-0.002253947	0.0315867052	0.0190732475	-0.0297741665	-0.022618321	0.0473702539	0.0464794461	-0.0263551919	-0.0297460856	0.0381955592	0.0451940979	-0.0150560981	-0.0322224977	-0.0108591045]'/1000;
    data.A6QF02.cody  = [-0.0007527784	0.0041076356	0.0126002952	0.0220037215	-0.0103093767	-0.0286437439	-0.0136329824	-0.0186509753	-0.0218188721	0.0285404214	0.0193770297	0.0051836792	0.0014686809	-0.0114098277	-0.0037289235	0.0100555895	0.0178045858	-0.0114363543	-0.0123041759	-0.0133278019	-0.0047576234	0.0211855063	0.0126178336	-0.0001208006	-0.0082824242]'/1000;
    data.A6QF02.dK = +0.03;
    idx = getfamilydata(family, 'AT', 'ATIndex');
    data.(family).idx = idx;
end

family = 'A6SD01';
if any(strcmpi(family, includes))
    data.A6SD01.codx  = [0.0156376052	-0.0102826526	-0.0126355339	0.011267834	0.0133511143	0.0064857824	-0.0072702881	-0.008941363	0.0007584964	0.0023518175	-0.0053763618	-0.0068058562	0.0046598298	0.003911184	-0.0087930114	-0.0058900884	0.0068599775	0.0045660047	-0.0111507422	-0.0097122615	0.0153240473	0.0148042432	-0.0136366912	-0.0119703848	0.0145578383]'/1000;
    data.A6SD01.cody  = [6.66E-05	4.20E-05	-9.49E-05	-1.80E-05	-0.0005504904	-0.0004526511	-0.0002151098	-0.0002182888	5.53E-05	2.22E-05	-3.34E-05	-5.24E-05	4.66E-05	6.57E-05	6.94E-05	0.0003030611	0.0012074241	-0.001057161	-0.0008588498	-0.0010405805	-0.000788416	0.0010094225	0.0016281588	5.09E-05	-0.0002730002]'/1000;
    data.A6SD01.dK = +0.2;
    idx = getfamilydata(family, 'AT', 'ATIndex');
    data.(family).idx = idx;
end

family = 'A6SD02';
if any(strcmpi(family, includes))
    data.A6SD02.codx  = [0.0179778538	-0.0116653394	-0.0115523096	0.0083087494	0.0105901851	0.0048366113	-0.0077418343	-0.010428058	0.0056687765	0.0075627569	-0.0068704827	-0.0064174326	0.0002633241	0.0001234497	-0.0069232514	-0.0066281376	0.0082744456	0.0061591928	-0.0113573748	-0.0076930902	0.0120078862	0.0104326498	-0.0137484847	-0.012135161	0.0177172204]'/1000;
    data.A6SD02.cody  = [-0.0004104976	-0.0005628884	-0.0005454685	0.0002400117	0.0012880098	0.0018215083	0.0006644032	-0.000199215	-0.0003956043	-5.47E-05	0.0001253966	0.0005434738	0.0011449565	-0.0004635988	-0.0005446623	-0.0002002747	-0.0004655498	0.0007279119	0.0003613421	-0.001284301	-0.0008965257	0.0003009252	0.0005812204	0.0011364792	0.0004269867]'/1000;
    data.A6SD02.dK = +0.2;
    idx = getfamilydata(family, 'AT', 'ATIndex');
    data.(family).idx = idx;
end


family = 'A6SF';
if any(strcmpi(family, includes))
    data.A6SF.codx    = [-0.0416684992	0.0370066187	0.0365404041	-0.0399441986	-0.0436635852	-0.0175597766	0.0311167485	0.0355948475	-0.023805005	-0.0287788477	0.0248863677	0.0284973371	-0.0153194222	-0.0177847079	0.0241108441	0.0238660639	-0.016768701	-0.0148914756	0.0280501089	0.0247461068	-0.0289854928	-0.0262984422	0.0358152556	0.02991669	-0.0447050114]'/1000;
    data.A6SF.cody    = [0.0012510403	0.0011729833	0.0013225815	-0.0003698193	-0.0041432483	-0.0035154925	-0.0012276095	0.001498881	0.0016624688	-0.0001263274	-0.0006186054	-0.0016701814	-0.0027842417	0.0027603994	0.002259183	0.0016313378	0.001515929	-0.002382801	-0.000502806	0.0011099879	0.00144851	-0.0001513269	-0.0013293363	-0.0013367539	-0.0017750996]'/1000;
    data.A6SF.dK   = +0.5;
    idx = getfamilydata(family, 'AT', 'ATIndex');
    data.(family).idx = idx;
end


r = data;
