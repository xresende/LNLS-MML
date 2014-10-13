#ifndef _TRACKCPP_H
#define _TRACKCPP_H

#include <iostream>
#include <vector>
#include <sstream>
#include <string>

#include "Python.h"

#include "../auxiliary.h"
#include "../pos.h"
#include "../accelerator.h"
#include "../elements.h"
#include "../passmethods.h"
#include "../lattice.h"
#include "../tracking.h"

// auxiliary functions
int trackcpp_read_particles   (PyObject *py_particles,   std::vector<Pos<double> >&  pos);
int trackcpp_read_lattice     (PyObject *py_lattice,     std::vector<Element>& pos);
int trackcpp_read_accelerator (PyObject *py_accelerator, Accelerator& accelerator);

// exposed functionalities
PyObject*  trackcpp_linepass (PyObject *Self, PyObject *args);
PyObject*  trackcpp_ringpass (PyObject *Self, PyObject *args);
PyObject*  trackcpp_findm66  (PyObject *Self, PyObject *args);

#endif