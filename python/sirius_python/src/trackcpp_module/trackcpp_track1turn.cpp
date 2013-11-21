#include "trackcpp.h"

// Exception object
extern PyObject *TrackcppError;
extern std::string TrackcppErrorMsg;

PyObject*  trackcpp_track1turn(PyObject *self, PyObject *args) {

	//std::cout << "aqui1" << std::endl;

	PyObject *py_lattice, *py_pos;
	if (!PyArg_ParseTuple(args, "OO", &py_lattice, &py_pos))
		return NULL;

	Py_INCREF(py_lattice);
	Py_INCREF(py_pos);

	// reads pyring particles coordinates in phase space into trackc++ vector
	std::vector<Pos<double> > pos;
	if (trackcpp_read_particles(py_pos, pos)) {
		Py_DECREF(py_lattice);
		Py_DECREF(py_pos);
		return NULL;
	}
	//Py_RETURN_NONE;

	//std::cout << "aqui2" << std::endl;

	// reads pyring lattice into trackc++ lattice
	std::vector<Element> lattice;
	if (trackcpp_read_lattice(py_lattice, lattice)) {
		Py_DECREF(py_lattice);
		Py_DECREF(py_pos);
		return NULL;
	}
	//Py_RETURN_NONE;


	// Does tracking
//	int element_idx = -1;
//	Status::type ret = track1turn(lattice, pos, &element_idx);
//	if (ret != Status::success) {
//		if (ret == Status::passmethod_not_defined) {
//			//std::string str = "Passmethod '" + pm_dict[lattice[element_idx].pass_method] + "' in element #" + std::to_string(element_idx) + " not defined";
//			TrackcppErrorMsg = "teste1";
//		}
//		if (ret == Status::passmethod_not_implemented) {
//			//std::string str = "Passmethod '' in element #" + std::to_string(element_idx) + " not implemented";
//			//PyErr_SetString(TrackcppError, str.c_str());
//			std::string pmname = pm_dict[lattice[element_idx].pass_method];
//			TrackcppErrorMsg = "Passmethod '" + pmname + "' in element #" + std::to_string(element_idx) + " not implemented";
//		}
//		PyErr_SetString(TrackcppError, TrackcppErrorMsg.c_str());
//		Py_DECREF(py_lattice);
//		Py_DECREF(py_pos);
//		return NULL;
//	}

//	Py_DECREF(py_lattice);
//
//	for (unsigned int p = 0; p < pos.size(); p++) {
//		PyObject *py_rx = PyFloat_FromDouble(pos[p].rx);
//		PyObject *py_px = PyFloat_FromDouble(pos[p].px);
//		PyObject *py_ry = PyFloat_FromDouble(pos[p].ry);
//		PyObject *py_py = PyFloat_FromDouble(pos[p].py);
//		PyObject *py_de = PyFloat_FromDouble(pos[p].de);
//		PyObject *py_dl = PyFloat_FromDouble(pos[p].dl);
//
//	    PyList_SET_ITEM(py_pos, 6*p+0, py_rx);   // reference to py_rx stolen
//	    PyList_SET_ITEM(py_pos, 6*p+1, py_px);   // reference to num stolen
//	    PyList_SET_ITEM(py_pos, 6*p+2, py_ry);   // reference to num stolen
//	    PyList_SET_ITEM(py_pos, 6*p+3, py_py);   // reference to num stolen
//	    PyList_SET_ITEM(py_pos, 6*p+4, py_de);   // reference to num stolen
//	    PyList_SET_ITEM(py_pos, 6*p+5, py_dl);   // reference to num stolen
//	}

//	//Py_DECREF(py_pos);
//
//	return py_pos;


//	PyTuple_SET_ITEM(args, 1, py_pos);
//	//Py_DECREF(py_pos);
//	return PyTuple_GET_ITEM(args, 1);

	Py_DECREF(py_lattice);
	Py_DECREF(py_pos);

	PyObject *lst = PyList_New(6*pos.size());
	if (!lst) return NULL;
	for (unsigned int p = 0; p < pos.size(); p++) {
		PyObject *py_rx = PyFloat_FromDouble(pos[p].rx);
		PyObject *py_px = PyFloat_FromDouble(pos[p].px);
		PyObject *py_ry = PyFloat_FromDouble(pos[p].ry);
		PyObject *py_py = PyFloat_FromDouble(pos[p].py);
		PyObject *py_de = PyFloat_FromDouble(pos[p].de);
		PyObject *py_dl = PyFloat_FromDouble(pos[p].dl);
	    if (!py_rx or !py_px or !py_ry or !py_py or !py_de or !py_dl)  {
	        Py_DECREF(lst);
	        return NULL;
	    }
	    PyList_SET_ITEM(lst, 6*p+0, py_rx);   // reference to num stolen
	    PyList_SET_ITEM(lst, 6*p+1, py_px);   // reference to num stolen
	    PyList_SET_ITEM(lst, 6*p+2, py_ry);   // reference to num stolen
	    PyList_SET_ITEM(lst, 6*p+3, py_py);   // reference to num stolen
	    PyList_SET_ITEM(lst, 6*p+4, py_de);   // reference to num stolen
	    PyList_SET_ITEM(lst, 6*p+5, py_dl);   // reference to num stolen
	}

	return lst;


}