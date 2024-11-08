class_name MachineContainer extends Node

var _machines :Array[Machine] = []

func remove_machine_by_type(type:Machine.Type) -> Machine:
	for i in _machines.size():
		if _machines[i]._type == type:
			return _machines.pop_at(i)
		
	return null

func has_machine_of_type(type:Machine.Type) -> bool:
	var match_type := func (m:Machine) -> bool:
		return m._type == type
	
	return _machines.any(match_type)
