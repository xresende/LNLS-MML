#!/usr/bin/env python3 

import fieldmaptrack as fmaptrack
import fieldmaptrack.dipole_analysis as analysis
import numpy as np

config = analysis.Config()

# config.config_label          = 'bc_model2_controlgap_50mm_modelo_mecanico' # identification label
# config.fmap_filename         = '/home/fac_files/data/sirius/si/magnet_modelling/bc/fieldmaps/2014-10-07_Dipolo_Anel_BC_Modelo2_gap_lateral_50mm_modelo_mecanico_-50_50mm_-2000_2000mm.txt' # parameter
# config.beam_energy           = 3.0     # [GeV] electron beam energy 
# config.model_hardedge_length = 125.394 # [mm]  model hard-edge length of the magnet 
# config.model_nominal_angle   = 1.4     # [deg] model nominal deflection angle of the magnet
# config.traj_rk_s_step        = 1.0     # [mm]  step in s for the 4th-order RK integration
# config.traj_center_sagitta_flag = True # centers trajectory sagitta in good field region of the magnet
# config.traj_force_midplane_flag = True # forces trajectory on midplane (setting ry = py = 0)
# config.traj_init_rx             = None # initial rx
# config.traj_save                = True # whether to save reference trajectory in a file

config.config_label          = 'bc_model2_controlgap_0mm_modelo_mecanico' # identification label
config.fmap_filename         = '/home/fac_files/data/sirius/si/magnet_modelling/bc/fieldmaps/2014-10-08_Dipolo_Anel_BC_Modelo2_gap_lateral_0mm_modelo_mecanico_-50_50mm_-2000_2000mm.txt' # parameter
config.beam_energy           = 3.0     # [GeV] electron beam energy 
config.model_hardedge_length = 125.394 # [mm]  model hard-edge length of the magnet 
config.model_nominal_angle   = 1.4     # [deg] model nominal deflection angle of the magnet
config.traj_rk_s_step        = 1.0     # [mm]  step in s for the 4th-order RK integration
config.traj_center_sagitta_flag = True # centers trajectory sagitta in good field region of the magnet
config.traj_force_midplane_flag = True # forces trajectory on midplane (setting ry = py = 0)
config.traj_init_rx             = None # initial rx
config.traj_load_filename       = "/home/ximenes/fac_files/data/sirius/si/magnet_modelling/bc/2014-10-07_modelo2_gap_lateral_50mm_modelo_mecanico/trajectory.txt"

config.multipoles_perpendicular_grid = np.linspace(-10,10,41) # grid of points on perpendicular line to ref trajectory [mm]
config.multipoles_fitting_monomials  = (0,1,2,3,4,5,6,7,8,9,10)    # monomials to include in the polynomial fit of multipoles
config.multipoles_r0                 = 11.7 # [mm] horizontal position at which polynomial fields are calculated relative to the principal multipole

if __name__ == "__main__":
    
    print('DIPOLE ANALYSIS')
    print('===============')
         
    print('{0:<35s} {1}'.format('label:', config.config_label))
    
    config = analysis.raw_fieldmap_analysis(config)
    config = analysis.trajectory_analysis(config)
    config = analysis.multipoles_analysis(config)
