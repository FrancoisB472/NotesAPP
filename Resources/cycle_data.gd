extends Resource
class_name CycleData

@export var cycles: Array = []

@export var estimated_cycle_length: float = 28.0
@export var estimated_period_length: float = 5.0

@export var last_flow: String = "medium"
@export var last_pain: float = 5.0
@export var current_day: int = 0
@export var current_cycle_start: int = 0

const FLOW_VALUES = ["light", "medium", "heavy"]
const FLOW_MAP = {"light": 1.0, "medium": 2.0, "heavy": 3.0}

func log_period(start_time: int, end_time: int, flow: String, pain: float) -> void:
	if start_time <= 0 or end_time <= start_time:
		push_warning("log_period: invalid times start=%d end=%d, skipping" % [start_time, end_time])
		return
	if not FLOW_VALUES.has(flow):
		flow = "medium"
	pain = clamp(pain, 0.0, 10.0)
	cycles.append({
		"start": start_time,
		"end": end_time,
		"flow": flow,
		"pain": pain
	})
	last_flow = flow
	last_pain = pain
	recalculate()

func recalculate() -> void:
	var valid = cycles.filter(func(c): return c["start"] > 0 and c["end"] > c["start"])
	if valid.size() < 2:
		return

	# Cycle length = average gap between period start dates
	var total_cycle = 0.0
	for i in range(1, valid.size()):
		total_cycle += (valid[i]["start"] - valid[i - 1]["start"]) / 86400.0
	estimated_cycle_length = total_cycle / (valid.size() - 1)

	# Period length = average of (end - start) per period
	var total_period = 0.0
	for c in valid:
		total_period += (c["end"] - c["start"]) / 86400.0
	estimated_period_length = total_period / valid.size()

func predict_next_period() -> Dictionary:
	var base_time := 0

	if not cycles.is_empty():
		base_time = cycles[-1]["start"]
	elif current_cycle_start != 0:
		base_time = current_cycle_start
	else:
		return {}

	var next = int(base_time + estimated_cycle_length * 86400.0)

	return {
		"next_start": next,
		"cycle_length_days": estimated_cycle_length,
		"period_length_days": estimated_period_length
	}

func get_current_phase() -> Dictionary:
	if cycles.is_empty() and current_cycle_start == 0:
		return {"phase": "unknown", "day_in_cycle": 0, "next_phase": "unknown", "days_until_next": 0, "next_period_in_days": 0}
	
	var last_start: int
	if current_cycle_start != 0:
		last_start = current_cycle_start
	else:
		last_start = cycles[-1]["start"]
	
	var now := int(Time.get_unix_time_from_system())
	var day_in_cycle := int((now - last_start) / 86400.0) + 1

	# Phase boundaries derived from estimates
	var period_end := int(estimated_period_length)
	var ovulation_day := int(estimated_cycle_length / 2.0)
	var luteal_day := ovulation_day + 4  # roughly 4 days after ovulation

	var phase: String
	var next_phase: String
	var next_phase_day: int

	if day_in_cycle <= period_end:
		phase = "Menstruation"
		next_phase = "Follicular"
		next_phase_day = period_end + 1
	elif day_in_cycle <= ovulation_day - 1:
		phase = "Follicular"
		next_phase = "Ovulation"
		next_phase_day = ovulation_day
	elif day_in_cycle <= luteal_day:
		phase = "Ovulation"
		next_phase = "Luteal"
		next_phase_day = luteal_day + 1
	else:
		phase = "Luteal"
		next_phase = "Menstruation"
		next_phase_day = int(estimated_cycle_length) + 1

	var days_until_next := next_phase_day - day_in_cycle

	return {
		"phase": phase,
		"day_in_cycle": day_in_cycle,
		"next_phase": next_phase,
		"days_until_next": days_until_next,
		"next_period_in_days": maxi(0, int(estimated_cycle_length) - day_in_cycle + 1)
	}
	
func predict_symptoms() -> Dictionary:
	if cycles.is_empty():
		return {"flow": "medium", "pain": 5.0}

	var flow_counts = {"light": 0, "medium": 0, "heavy": 0}
	var pain = 0.0

	for c in cycles:
		if flow_counts.has(c["flow"]):
			flow_counts[c["flow"]] += 1
		pain += c["pain"]

	var best = "medium"
	var maxc = 0

	for k in flow_counts.keys():
		if flow_counts[k] > maxc:
			maxc = flow_counts[k]
			best = k

	return {
		"flow": best,
		"pain": pain / max(1, cycles.size())
	}
