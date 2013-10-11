function spear2
% Lattice definition file
% Created 11/21/99 
% Simplified SPEAR-II lattice
% no BPMs, no correctors


global FAMLIST THERING GLOBVAL

GLOBVAL.E0 = 3e9;
GLOBVAL.LatticeFile = 'spear2new';

FAMLIST = cell(0);

disp(' ');
disp('** Loading SPEAR lattice in spear2.m **');

BPM = monitor('BPM','AperturePass');
AP = aperture('AP', [-0.05, 0.05, -0.05, 0.05],'AperturePass');

DR01   =    drift('DR01' ,1.344800,'DriftPass');
DR02   =    drift('DR02' ,0.860000,'DriftPass');
DR03   =    drift('DR03' ,6.413180,'DriftPass');
DR04   =    drift('DR04' ,0.611890,'DriftPass');
DR04A  =    drift('DR04A',0.617123,'DriftPass');
DR05   =    drift('DR05' ,2.823700,'DriftPass');
DR06A  =    drift('DR06A',0.151205,'DriftPass');
DR06B  =    drift('DR06B',0.229935,'DriftPass');
DR07A  =    drift('DR07A',0.229948,'DriftPass');
DR07B  =    drift('DR07B',0.151205,'DriftPass');
DR08A  =    drift('DR08A',0.151205,'DriftPass');
DR08B  =    drift('DR08B',0.227335,'DriftPass');
DR09   =    drift('DR09' ,2.981660,'DriftPass');


% octupoles are inserted in drift DR03 between Q2 and Q1
%OCT_Q1 =    drift('OCT_Q1' ,1.0056578,'DriftPass');
%OCT_Q2 =    drift('OCT_Q2' ,5.1267822,'DriftPass');
%OCT    =	sextupole('OCT'  , 0.28194, 0,'StrThickMPole4thOrderPass');
%OCT   =		drift('OCT' ,0.28194,'DriftPass');



%QF and QD valus set to have the tune at (7.13,5.23)
Q3     =    quadrupole('Q3'  , 1.00000, 0.0000000,'QuadLinearPass');
Q2     =    quadrupole('Q2'  , 1.34274, 0.0790090,'QuadLinearPass');
Q1     =    quadrupole('Q1'  , 0.51834,-0.2595850,'QuadLinearPass');
QFA    =    quadrupole('QFA' , 0.51834, 0.7931150,'QuadLinearPass');
QFAH   =    quadrupole('QFAH', 0.25917, 0.7931150,'QuadLinearPass');
QDA    =    quadrupole('QDA' , 0.51834,-0.6546270,'QuadLinearPass');
QFB    =    quadrupole('QFB' , 0.51834, 0.5169680,'QuadLinearPass');
QF     =    quadrupole('QF'  , 0.51834,  0.4498960277 ,'QuadLinearPass');
QD     =    quadrupole('QD' , 0.51834,-0.669244391,'QuadLinearPass');



% Fitted values to produce normalized chromaticities 0,0 
SF     =    sextupole('SF'  , 0.23335, 1.6768688886,'StrMPoleSymplectic4Pass');
SDA    =    sextupole('SDA' , 0.23335,-1.29030148931,'StrMPoleSymplectic4Pass');
SDB    =    sextupole('SDB' , 0.23335,-1.29030148931,'StrMPoleSymplectic4Pass');


%drift representation for linear modeling
%SF     =    drift('SF'  , 0.23335,'DriftPass');
%SDA    =   	drift('SF'  , 0.23335,'DriftPass');
%SDB    =    drift('SF'  , 0.23335,'DriftPass');



BB     =    rbend('BB'  ,2.35785400,  ...
   0.1848, 0.0924, 0.0924, 0,'BendLinearPass');

B      =    rbend('B'   ,1.17766900,   ...
   				0.0924, 0.0462, 0.0462, 0,'BendLinearPass');

BS1 = rbend('BS1'   ,1.17766900/10,   ...
   0.0924/10, 0.0462, 0, 0,'BendLinearPass');
BS2 = rbend('BS2'   ,1.17766900/10,   ...
   0.0924/10, 0, 0.0462, 0,'BendLinearPass');

BS = rbend('BS'   ,1.17766900/10,   ...
   0.0924/10, 0, 0, 0,'BendLinearPass');


%BB     =    rbend('BB'  ,2.35785400,  ...
%            0.1848, 0.0924, 0.0924, 0,'BendLinearPass');

%B      =    rbend('B'   ,1.17766900,   ...
%            0.0924, 0.0462, 0.0462, 0,'BendLinearPass');


% Begin Lattice

BBB = [BS1 BS BS BS BS BS BS BS BS BS2];


SWSE =[	DR01 Q3 DR02 Q2 DR03 ...
      Q1 DR04 BB DR04A ...
      BB DR05 QFA DR06A ...
   	SF DR06B BBB DR07A SDA DR07B QDA DR08A ...
   	SDA DR08B BB DR08B SF DR08A QFB DR09 ...
   	QF DR04 BB DR08B SDB DR08A ...
      QD DR08A SDB DR08B BB DR08B ...
      SF DR08A QF DR09 QF ...
      DR04 BB DR08B SDA DR08A QD ...
      DR08A SDA DR08B BB DR04 QF ...
      DR09 QF DR08A SF DR08B BB ...
    	DR08B SDB DR08A QD DR08A SDB DR08B BB ...
      DR08B SF DR08A QF DR09 QF ...
     	DR04 BB DR08B SDA DR08A QD ...
      DR08A SDA DR08B BB DR04 ...
      QF DR09 QF DR08A SF DR08B BB ...
      DR08B SDB DR08A QD DR08A SDB ...
      DR08B BB DR04 QF DR09 QFB DR08A ...
      SF DR08B BB DR08B SDA DR08A QDA ...
      DR07B SDA DR07A B DR06B ...
      SF DR06A QFA DR05 BB DR04A BB DR04 Q1 DR03...
      Q2 DR02 Q3 DR01 ];

NENW =  [ DR01 Q3 DR02 Q2 DR03...
      Q1 DR04 BB DR04A ...
      BB DR05 QFA DR06A ...
      SF DR06B B DR07A SDA DR07B QDA DR08A ...
      SDA DR08B BB DR08B SF DR08A QFB DR09 ...
      QF DR04 BB DR08B SDB DR08A QD ...
      DR08A SDB DR08B BB DR08B ...
      SF DR08A QF DR09 QF ...
      DR04 BB DR08B SDA DR08A QD ...
      DR08A SDA DR08B BB DR04 QF ... 
      DR09 QF DR08A SF DR08B BB ...
      DR08B SDB DR08A QD ...
 		DR08A SDB DR08B BB ...
      DR08B SF DR08A QF DR09 QF ...
      DR04 BB DR08B SDA DR08A  ...
      QD DR08A SDA DR08B BB DR04 ...
      QF DR09 QF DR08A SF DR08B BB ...
      DR08B SDB DR08A QD DR08A SDB ...
      DR08B BB DR04 QF DR09 QFB DR08A ...
      SF DR08B BB DR08B SDA DR08A QDA ...
      DR07B SDA DR07A B DR06B ...
      SF DR06A QFA DR05 BB DR04A BB DR04 Q1 DR03 ...
      Q2 DR02 Q3 DR01 ];
     
      
      
ELIST =  [SWSE NENW AP]; 

ELIST = reverse(ELIST);

THERING=cell(size(ELIST));
for i=1:length(THERING)
   THERING{i} = FAMLIST{ELIST(i)}.ElemData;
   FAMLIST{ELIST(i)}.NumKids=FAMLIST{ELIST(i)}.NumKids+1;
   FAMLIST{ELIST(i)}.KidsList = [FAMLIST{ELIST(i)}.KidsList i];
end


evalin('caller','global THERING FAMLIST GLOBVAL');
disp('** Done **');








