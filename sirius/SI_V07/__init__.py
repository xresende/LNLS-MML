from . import _lattice
from . import _accelerator

create_lattice = _lattice.create_lattice
create_accelerator = _accelerator.create_accelerator

# -- default accelerator values for SI_V07 --

energy = _accelerator._energy
harmonic_number = _accelerator._harmonic_number
default_cavity_on = _accelerator._default_cavity_on
default_radiation_on = _accelerator._default_cavity_on
default_vchamber_on = _accelerator._default_vchamber_on
default_optics_mode = _lattice._default_optics_mode.label
