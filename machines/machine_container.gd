class_name MachineContainer extends Node

var _machines :Array[Machine] = []


func add_machine_by_type(type:Machine.Type) -> Machine:
	_machines.append(MachineFactory.new_machine(type))
	return _machines.back()

func remove_machine_by_type(type:Machine.Type) -> Machine:
	for i in _machines.size():
		if _machines[i]._type == type:
			return _machines.pop_at(i)
		
	return null

func has_machine_of_type(type:Machine.Type) -> bool:
	var match_type := func (m:Machine) -> bool:
		return m._type == type
	
	return _machines.any(match_type)

func get_all_machines() -> Dictionary:
	var machine_types_index :Dictionary = {}
	var machines_list :Dictionary = {}
	
	for m in _machines:
		# Save a reference to a machine of every type present in the container
		var machine_ref :Machine = machine_types_index.get_or_add(m._type, m)
		
		machines_list[machine_ref] = machines_list.get_or_add(machine_ref, 0) + 1
		
	return machines_list
