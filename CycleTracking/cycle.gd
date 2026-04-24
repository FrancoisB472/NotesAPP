extends Node
class_name CycleTracker

const SAVE_PATH := "user://cycle_data.tres"
const SECONDS_PER_DAY := 86400

@export var data: CycleData
var save_timer := 0.0

func _ready() -> void:
	data = load_data()

func _process(delta: float) -> void:
	update_cycle()

	save_timer += delta
	if save_timer > 30.0:
		save()
		save_timer = 0.0

func update_cycle() -> void:
	if data.cycles.is_empty():
		return

	var last = data.cycles[-1]
	var now = Time.get_unix_time_from_system()

	data.current_day = int((now - last["start"]) / SECONDS_PER_DAY) + 1

func end_period(flow: String, pain: float) -> void:
	if data.current_cycle_start == 0:
		push_warning("end_period called with no active period, ignoring")
		return
	var now = Time.get_unix_time_from_system()
	data.log_period(data.current_cycle_start, now, flow, pain)
	data.current_cycle_start = 0
	save()

func start_period() -> void:
	if data.current_cycle_start != 0:
		push_warning("start_period called while period already active, ignoring")
		return
	data.current_cycle_start = Time.get_unix_time_from_system()
	save()

func has_active_period() -> bool:
	return data.current_cycle_start != 0

func get_prediction() -> Dictionary:
	return data.predict_next_period()

func get_symptom_prediction() -> Dictionary:
	return data.predict_symptoms()

func get_current_phase() -> Dictionary:
	return data.get_current_phase()

func save() -> void:
	ResourceSaver.save(data, SAVE_PATH)

func load_data() -> CycleData:
	if ResourceLoader.exists(SAVE_PATH):
		var d = ResourceLoader.load(SAVE_PATH)
		if d is CycleData:
			return d
	return CycleData.new()

func reset_data() -> void:
	data = CycleData.new()
	save()
