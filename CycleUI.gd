extends MarginContainer

@onready var list: VBoxContainer = $VBoxContainer
@onready var popup: PanelContainer = $Popup
@onready var pain_graph: Graph2D = $VBoxContainer/VBoxContainer/PainGraph
@onready var flow_graph: Graph2D = $VBoxContainer/VBoxContainer/FlowGraph
@onready var end_period: Button = $VBoxContainer/Panel/MarginContainer/HBoxContainer2/VBoxContainer/ButtonRow/EndPeriod

@export var tracker: CycleTracker

@export var cycle_length_lbl : Label
@export var period_length_lbl : Label
@export var current_lbl : Label
@export var flow_lbl : Label
@export var pain_lbl : Label
@export var pain_box : SpinBox
@export var flow_edit : OptionButton
@export var current_phase_lbl : Label
@export var day_in_cycle_lbl : Label
@export var next_phase_lbl : Label
@export var next_period_lbl : Label

var _graph_origin: int = 0  # unix time of first cycle, used as day-0

func _ready() -> void:
	pain_graph.remove_all()
	flow_graph.remove_all()
	call_deferred("populate_graph")
	set_label_values()

func _process(delta: float) -> void:
	set_label_values()

func set_label_values():
	if tracker == null or tracker.data == null:
		return
	
	cycle_length_lbl.text = str(snapped(tracker.data.estimated_cycle_length, 0.1))
	period_length_lbl.text = str(snapped(tracker.data.estimated_period_length, 0.1))

	current_lbl.text = str(tracker.data.current_day)
	
	var pred = tracker.get_prediction()
	
	var sym = tracker.get_symptom_prediction()
	flow_lbl.text = sym["flow"]
	pain_lbl.text = str(snapped(sym["pain"], 0.1))
	
	end_period.disabled = !tracker.has_active_period()

	var phase := tracker.get_current_phase()
	current_phase_lbl.text = phase["phase"]
	day_in_cycle_lbl.text = "Day %d of ~%d" % [phase["day_in_cycle"], int(tracker.data.estimated_cycle_length)]
	next_phase_lbl.text = "%s in ~%d days" % [phase["next_phase"], phase["days_until_next"]]
	next_period_lbl.text = "Next period in ~%d days" % phase["next_period_in_days"]

func populate_graph():
	print("cycles count: ", tracker.data.cycles.size())
	if tracker == null or tracker.data == null:
		return
	if tracker.data.cycles.is_empty():
		return
	
	pain_graph.remove_all()
	flow_graph.remove_all()
	
	_graph_origin = tracker.data.cycles[0]["start"]
	var pain_plot := pain_graph.add_plot_item("Pain", Color.RED)
	var flow_plot := flow_graph.add_plot_item("Flow", Color.CYAN)
	
	# set axis ranges based on data
	var last_day : float = (tracker.data.cycles[-1]["start"] - _graph_origin) / 86400.0
	var pad : float = tracker.data.estimated_cycle_length  # padding in days
	
	# Give x padding, estimated cycle before and after
	pain_graph.x_min = -pad
	pain_graph.x_max = last_day + pad
	pain_graph.y_min = 0.0
	pain_graph.y_max = 10.0

	flow_graph.x_min = -pad
	flow_graph.x_max = last_day + pad
	flow_graph.y_min = 0.0
	flow_graph.y_max = 3.0
	
	for cycle in tracker.data.cycles:
		var day: float = (cycle["start"] - _graph_origin) / 86400.0
		pain_plot.add_point(Vector2(day, cycle["pain"]))
		var flow_val: float = tracker.data.FLOW_MAP.get(cycle["flow"], 2.0)
		flow_plot.add_point(Vector2(day, flow_val))

func format_time(unix_time: int) -> String:
	var dt = Time.get_datetime_dict_from_unix_time(unix_time)
	return "%02d-%02d-%d" % [dt.day, dt.month, dt.year]

func _on_start_period_pressed() -> void:
	
	tracker.start_period()

func _on_end_period_pressed() -> void:
	popup.visible = true

func _on_button_pressed() -> void:
	var flow_id := flow_edit.get_selected_id()
	var flow_text := flow_edit.get_item_text(flow_id)
	tracker.end_period(flow_text.to_lower(), pain_box.value)
	set_label_values()
	populate_graph()
	popup.visible = false

func _on_button_2_pressed() -> void:
	popup.visible = false

func _on_reset_data_pressed() -> void:
	tracker.reset_data()
	pain_graph.remove_all()
	flow_graph.remove_all()
